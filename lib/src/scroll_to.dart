import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_x/src/scroll_tag.dart';

import 'util.dart';

typedef ViewportBoundaryGetter = Rect Function();
typedef AxisValueGetter = double Function(Rect rect);

Rect defaultViewportBoundaryGetter() => Rect.zero;

const scrollAnimationDuration = Duration(milliseconds: 250);
const defaultDurationUnit = 40;
const _millisecond = Duration(milliseconds: 1);
const defaultScrollDistanceOffset = 100.0;

enum AutoScrollPosition { begin, middle, end }

class SimpleAutoScrollController extends ScrollController with AutoScrollControllerMixin {
  @override
  final ViewportBoundaryGetter viewportBoundaryGetter;
  @override
  final AxisValueGetter beginGetter;
  @override
  final AxisValueGetter endGetter;

  SimpleAutoScrollController(
      {double initialScrollOffset = 0.0,
      bool keepScrollOffset = true,
      this.viewportBoundaryGetter = defaultViewportBoundaryGetter,
      required this.beginGetter,
      required this.endGetter,
      AutoScrollController? copyTagsFrom,
      String? debugLabel})
      : super(initialScrollOffset: initialScrollOffset, keepScrollOffset: keepScrollOffset, debugLabel: debugLabel) {
    if (copyTagsFrom != null) tagMap.addAll(copyTagsFrom.tagMap);
  }
}

abstract class AutoScrollController implements ScrollController {
  factory AutoScrollController(
      {double initialScrollOffset = 0.0,
      bool keepScrollOffset = true,
      // double? suggestedRowHeight,
      ViewportBoundaryGetter viewportBoundaryGetter = defaultViewportBoundaryGetter,
      Axis? axis,
      String? debugLabel,
      AutoScrollController? copyTagsFrom}) {
    return SimpleAutoScrollController(
        initialScrollOffset: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        // suggestedRowHeight: suggestedRowHeight,
        viewportBoundaryGetter: viewportBoundaryGetter,
        beginGetter: (r) => r.top,
        endGetter: (r) => r.bottom,
        copyTagsFrom: copyTagsFrom,
        debugLabel: debugLabel);
  }

  /// used to quick scroll to a index if the row height is the same
  // double? get suggestedRowHeight;

  /// used to make the additional boundary for viewport
  /// e.g. a sticky header which covers the real viewport of a list view
  ViewportBoundaryGetter get viewportBoundaryGetter;

  /// used to choose which direction you are using.
  /// e.g. axis == Axis.horizontal ? (r) => r.left : (r) => r.top
  AxisValueGetter get beginGetter;
  AxisValueGetter get endGetter;

  /// detect if it's in scrolling (scrolling is a async process)
  bool get isAutoScrolling;

  /// all layout out states will be put into this map
  Map<int, AutoScrollTagState> get tagMap;

  /// used to chaining parent scroll controller
  set parentController(ScrollController parentController);

  /// check if there is a parent controller
  bool get hasParentController;

  /// scroll to the giving index
  Future scrollToIndex(int index, {Duration duration = scrollAnimationDuration, AutoScrollPosition? preferPosition});

  /// check if the state is created. that is, is the indexed widget is layout out.
  /// NOTE: state created doesn't mean it's in viewport. it could be a buffer range, depending on flutter's implementation.
  bool isIndexStateInLayoutRange(int index);
}

mixin AutoScrollControllerMixin on ScrollController implements AutoScrollController {
  @override
  final Map<int, AutoScrollTagState> tagMap = <int, AutoScrollTagState>{};

  @override
  ViewportBoundaryGetter get viewportBoundaryGetter;
  @override
  AxisValueGetter get beginGetter;
  @override
  AxisValueGetter get endGetter;

  bool __isAutoScrolling = false;
  set _isAutoScrolling(bool isAutoScrolling) {
    __isAutoScrolling = isAutoScrolling;
    if (!isAutoScrolling && hasClients) {
      notifyListeners();
    }
  }

  @override
  bool get isAutoScrolling => __isAutoScrolling;

  ScrollController? _parentController;
  @override
  set parentController(ScrollController parentController) {
    if (_parentController == parentController) return;

    final isNotEmpty = positions.isNotEmpty;
    if (isNotEmpty && _parentController != null) {
      for (final p in _parentController!.positions) {
        if (positions.contains(p)) _parentController!.detach(p);
      }
    }

    _parentController = parentController;

    if (isNotEmpty && _parentController != null) {
      for (final p in positions) {
        _parentController!.attach(p);
      }
    }
  }

  @override
  bool get hasParentController => _parentController != null;

  @override
  void attach(ScrollPosition position) {
    super.attach(position);

    _parentController?.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    _parentController?.detach(position);

    super.detach(position);
  }

  static const maxBound = 30; // 0.5 second if 60fps
  @override
  Future scrollToIndex(int index,
      {Duration duration = scrollAnimationDuration, AutoScrollPosition? preferPosition}) async {
    return co(this, () => _scrollToIndex(index, duration: duration, preferPosition: preferPosition));
  }

  Future _scrollToIndex(int index,
      {Duration duration = scrollAnimationDuration, AutoScrollPosition? preferPosition}) async {
    assert(duration > Duration.zero);

    // In listView init or reload case, widget state of list item may not be ready for query.
    // this prevent from over scrolling becoming empty screen or unnecessary scroll bounce.
    Future makeSureStateIsReady() async {
      for (var count = 0; count < maxBound; count++) {
        if (_isEmptyStates) {
          await _waitForWidgetStateBuild();
        } else {
          return null;
        }
      }

      return null;
    }

    await makeSureStateIsReady();

    if (!hasClients) return null;

    // two cases,
    // 1. already has state. it's in viewport layout
    // 2. doesn't have state yet. it's not in viewport so we need to start scrolling to make it into layout range.
    if (isIndexStateInLayoutRange(index)) {
      _isAutoScrolling = true;

      await _bringIntoViewportIfNeed(index, preferPosition, (double offset) async {
        await animateTo(offset, duration: duration, curve: Curves.ease);
        await _waitForWidgetStateBuild();
        return null;
      });

      _isAutoScrolling = false;
    } else {
      // the idea is scrolling based on either
      // 1. suggestedRowHeight or
      // 2. testDistanceOffset
      double prevOffset = offset - 1;
      double currentOffset = offset;
      bool contains = false;
      Duration spentDuration = const Duration();
      double lastScrollDirection = 0.5; // alignment, default center;
      final moveDuration = duration ~/ defaultDurationUnit;

      _isAutoScrolling = true;

      while (prevOffset != currentOffset && !(contains = isIndexStateInLayoutRange(index))) {
        prevOffset = currentOffset;
        final nearest = _getNearestIndex(index);
        final moveTarget = _forecastMoveUnit(index, nearest)!;
        if (moveTarget < 0) {
          return null;
        }

        lastScrollDirection = moveTarget - prevOffset > 0 ? 1 : 0;
        currentOffset = moveTarget;
        spentDuration += moveDuration;
        final oldOffset = offset;
        await animateTo(currentOffset, duration: moveDuration, curve: Curves.ease);
        await _waitForWidgetStateBuild();
        if (!hasClients || offset == oldOffset) {
          // already scroll to begin or end
          contains = isIndexStateInLayoutRange(index);
          break;
        }
      }
      _isAutoScrolling = false;

      if (contains && hasClients) {
        await _bringIntoViewportIfNeed(index, preferPosition ?? _alignmentToPosition(lastScrollDirection),
            (finalOffset) async {
          if (finalOffset != offset) {
            _isAutoScrolling = true;
            final remaining = duration - spentDuration;
            await animateTo(finalOffset,
                duration: remaining <= Duration.zero ? _millisecond : remaining, curve: Curves.ease);
            await _waitForWidgetStateBuild();

            // not sure why it doesn't scroll to the given offset, try more within 3 times
            if (hasClients && offset != finalOffset) {
              const count = 3;
              for (var i = 0; i < count && hasClients && offset != finalOffset; i++) {
                await animateTo(finalOffset, duration: _millisecond, curve: Curves.ease);
                await _waitForWidgetStateBuild();
              }
            }
            _isAutoScrolling = false;
          }
        });
      }
    }

    return null;
  }

  @override
  bool isIndexStateInLayoutRange(int index) => tagMap[index] != null;

  /// this means there is no widget state existing, usually happened before build.
  /// we should wait for next frame.
  bool get _isEmptyStates => tagMap.isEmpty;

  /// wait until the [SchedulerPhase] in [SchedulerPhase.persistentCallbacks].
  /// it means if we do animation scrolling to a position, the Future call back will in [SchedulerPhase.midFrameMicrotasks].
  /// if we want to search viewport element depending on Widget State, we must delay it to [SchedulerPhase.persistentCallbacks].
  /// which is the phase widget build/layout/draw
  Future _waitForWidgetStateBuild() => SchedulerBinding.instance!.endOfFrame;

  /// NOTE: this is used to forcase the nearestIndex. if the the index equals targetIndex,
  /// we will use the function, calling _directionalOffsetToRevealInViewport to get move unit.
  double? _forecastMoveUnit(int targetIndex, int? currentNearestIndex) {
    assert(targetIndex != currentNearestIndex);
    currentNearestIndex = currentNearestIndex ?? 0; //null as none of state

    final alignment = targetIndex > currentNearestIndex ? 1.0 : 0.0;
    double? absoluteOffsetToViewport;

    if (tagMap[currentNearestIndex] == null) return -1;

    final offsetToLastState = _offsetToRevealInViewport(currentNearestIndex, alignment);

    absoluteOffsetToViewport = offsetToLastState?.offset;
    absoluteOffsetToViewport ??= defaultScrollDistanceOffset;

    return absoluteOffsetToViewport;
  }

  int? _getNearestIndex(int index) {
    final list = tagMap.keys;
    if (list.isEmpty) return null;

    final sorted = list.toList()..sort((int first, int second) => first.compareTo(second));
    final min = sorted.first;
    final max = sorted.last;
    return (index - min).abs() < (index - max).abs() ? min : max;
  }

  /// bring the state node (already created but all of it may not be fully in the viewport) into viewport
  Future _bringIntoViewportIfNeed(
      int index, AutoScrollPosition? preferPosition, Future Function(double offset) move) async {
    if (preferPosition != null) {
      double targetOffset = _directionalOffsetToRevealInViewport(index, _positionToAlignment(preferPosition));

      // The content preferred position might be impossible to reach
      // for items close to the edges of the scroll content, e.g.
      // we cannot put the first item at the end of the viewport or
      // the last item at the beginning. Trying to do so might lead
      // to a bounce at either the top or bottom, unless the scroll
      // physics are set to clamp. To prevent this, we limit the
      // offset to not overshoot the extent in either direction.
      targetOffset = targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent);

      await move(targetOffset);
    } else {
      final begin = _directionalOffsetToRevealInViewport(index, 0);
      final end = _directionalOffsetToRevealInViewport(index, 1);

      final alreadyInViewport = offset < begin && offset > end;
      if (!alreadyInViewport) {
        double value;
        if ((end - offset).abs() < (begin - offset).abs()) {
          value = end;
        } else {
          value = begin;
        }

        await move(value > 0 ? value : 0);
      }
    }
  }

  double _positionToAlignment(AutoScrollPosition position) {
    return position == AutoScrollPosition.begin
        ? 0
        : position == AutoScrollPosition.end
            ? 1
            : 0.5;
  }

  AutoScrollPosition _alignmentToPosition(double alignment) => alignment == 0
      ? AutoScrollPosition.begin
      : alignment == 1
          ? AutoScrollPosition.end
          : AutoScrollPosition.middle;

  /// return offset, which is a absolute offset to bring the target index object into the location(depends on [direction]) of viewport
  /// see also: _offsetYToRevealInViewport()
  double _directionalOffsetToRevealInViewport(int index, double alignment) {
    assert(alignment == 0 || alignment == 0.5 || alignment == 1);
    // 1.0 bottom, 0.5 center, 0.0 begin if list is vertically from begin to end
    final tagOffsetInViewport = _offsetToRevealInViewport(index, alignment);

    if (tagOffsetInViewport == null) {
      return -1;
    } else {
      double absoluteOffsetToViewport = tagOffsetInViewport.offset;
      if (alignment == 0.5) {
        return absoluteOffsetToViewport;
      } else if (alignment == 0) {
        return absoluteOffsetToViewport - beginGetter(viewportBoundaryGetter());
      } else {
        return absoluteOffsetToViewport + endGetter(viewportBoundaryGetter());
      }
    }
  }

  /// return offset, which is a absolute offset to bring the target index object into the center of the viewport
  /// see also: _directionalOffsetToRevealInViewport()
  RevealedOffset? _offsetToRevealInViewport(int index, double alignment) {
    final ctx = tagMap[index]?.context;
    if (ctx == null) return null;

    final renderBox = ctx.findRenderObject()!;
    assert(Scrollable.of(ctx) != null);
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderBox)!;
    final revealedOffset = viewport.getOffsetToReveal(renderBox, alignment);

    return revealedOffset;
  }
}
