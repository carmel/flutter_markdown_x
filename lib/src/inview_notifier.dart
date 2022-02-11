import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_x/src/inview_state.dart';
import 'package:flutter_markdown_x/src/scroll_tag.dart';
import 'package:flutter_markdown_x/src/scroll_to.dart';

import 'package:stream_transform/stream_transform.dart';

class InViewNotifier extends StatefulWidget {
  ///The String list of ids of the child widgets that should be initialized as inView
  ///when the list view is built for the first time.

  ///The widget that should be displayed in the [InViewNotifier].

  ///The distance from the bottom of the list where the [onListEndReached] should be invoked.
  final double endNotificationOffset;

  final Function(int currentViewIndex, double maxScroll, double offset) notifyHandler;

  ///The function that is invoked when the list scroll reaches the end
  ///or the [endNotificationOffset] if provided.
  final VoidCallback? onListEndReached;

  ///The duration to be used for throttling the scroll notification.
  ///Defaults to 200 milliseconds.
  final Duration throttleDuration;

  ///The function that defines the area within which the widgets should be notified
  ///as inView.
  final InViewPortCondition inViewPortCondition;
  // final ScrollController controller;
  final List<Widget>? slivers;
  final SliverAppBar appbar;
  final EdgeInsets sliverPadding;
  final AutoScrollController controller;

  const InViewNotifier({
    Key? key,
    this.endNotificationOffset = 0.0,
    this.onListEndReached,
    this.throttleDuration = const Duration(milliseconds: 200),
    this.slivers,
    required this.inViewPortCondition,
    required this.controller,
    required this.appbar,
    required this.notifyHandler,
    this.sliverPadding = const EdgeInsets.only(top: 4, bottom: 24, left: 15, right: 15),
  })  : assert(endNotificationOffset >= 0.0),
        super(key: key);

  @override
  _InViewNotifierState createState() => _InViewNotifierState();

  static InViewState? of(BuildContext context) {
    final InheritedInViewWidget widget =
        context.getElementForInheritedWidgetOfExactType<InheritedInViewWidget>()!.widget as InheritedInViewWidget;
    return widget.inViewState;
  }
}

class _InViewNotifierState extends State<InViewNotifier> {
  InViewState? _inViewState;
  StreamController<ScrollNotification>? _streamController;
  int _currentViewIndex = 1;

  @override
  void initState() {
    super.initState();
    _initializeInViewState();
    _startListening();
  }

  @override
  void didUpdateWidget(InViewNotifier oldWidget) {
    if (oldWidget.throttleDuration != widget.throttleDuration) {
      //when throttle duration changes, close the existing stream controller if exists
      //and start listening to a stream that is throttled by new duration.
      _streamController?.close();
      _startListening();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _inViewState?.dispose();
    _inViewState = null;
    _streamController?.close();
    super.dispose();
  }

  void _startListening() {
    _streamController = StreamController<ScrollNotification>();

    _streamController!.stream.audit(widget.throttleDuration).listen(_inViewState!.onScroll);
  }

  void _initializeInViewState() {
    _inViewState = InViewState(
      inViewCondition: widget.inViewPortCondition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InheritedInViewWidget(
      inViewState: _inViewState,
      child: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: widget.controller,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          slivers: <Widget>[
            widget.appbar,
            SliverPadding(
              padding: widget.sliverPadding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final idx = i + 1;
                    return InViewNotifierWidget(
                        id: idx,
                        builder: (BuildContext context, bool isInView, Widget? child) {
                          if (isInView) {
                            _currentViewIndex = idx;
                          }
                          if (widget.slivers![i] is! SizedBox) {
                            return AutoScrollTag(
                              key: ValueKey(idx),
                              controller: widget.controller,
                              index: idx,
                              child: widget.slivers![i],
                            );
                          }
                          return const SizedBox();
                        });
                  },
                  childCount: widget.slivers?.length,
                ),
              ),
            ),
          ],
        ),
        onNotification: (ScrollNotification notification) {
          final double maxScroll = notification.metrics.maxScrollExtent;
          final offset = notification.metrics.pixels;

          //end of the listview reached
          if (maxScroll - offset <= widget.endNotificationOffset) {
            if (widget.onListEndReached != null) {
              widget.onListEndReached!();
            }
          }

          //when user is not scrolling
          if (notification is UserScrollNotification && notification.direction == ScrollDirection.idle) {
            if (!_streamController!.isClosed) {
              _streamController!.add(notification);
            }
          }

          // if (!_streamController!.isClosed && isScrollDirection) {
          //   _streamController!.add(notification);
          // }
          if (notification is ScrollEndNotification) {
            widget.notifyHandler(_currentViewIndex, maxScroll, offset);
          }
          return false;
        },
      ),
    );
  }
}

///The function that defines the area within which the widgets should be notified
///as inView.
typedef InViewPortCondition = bool Function(
  double deltaTop,
  double deltaBottom,
  double viewPortDimension,
);

typedef InViewNotifierWidgetBuilder = Widget Function(
  BuildContext context,
  bool isInView,
  Widget? child,
);

class InViewNotifierWidget extends StatefulWidget {
  ///a required String property. This should be unique for every widget
  ///that wants to get notified.
  final int id;

  ///The function that defines and returns the widget that should be notified
  ///as inView.
  ///
  ///The `isInView` tells whether the returned widget is in view or not.
  ///
  ///The child should typically be part of the returned widget tree.
  final InViewNotifierWidgetBuilder builder;

  ///The child widget to pass to the builder.
  final Widget? child;

  const InViewNotifierWidget({
    Key? key,
    required this.id,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  _InViewNotifierWidgetState createState() => _InViewNotifierWidgetState();
}

class _InViewNotifierWidgetState extends State<InViewNotifierWidget> {
  late final InViewState state;

  @override
  void initState() {
    super.initState();
    state = InViewNotifier.of(context)!;
    state.addContext(context: context, id: widget.id);
  }

  @override
  void dispose() {
    state.removeContext(context: context);
    super.dispose();
  }

  @override
  void didUpdateWidget(InViewNotifierWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      state.removeContext(context: context);
      state.addContext(context: context, id: widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final bool isInView = state.inView(widget.id);

        return widget.builder(context, isInView, child);
      },
    );
  }
}

class InheritedInViewWidget extends InheritedWidget {
  final InViewState? inViewState;

  const InheritedInViewWidget({Key? key, this.inViewState, required Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedInViewWidget oldWidget) => false;
}
