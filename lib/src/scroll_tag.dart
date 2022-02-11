import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_x/src/scroll_to.dart';

class AutoScrollTag extends StatefulWidget {
  final AutoScrollController controller;
  final int index;
  final Widget child;
  final bool disabled;

  const AutoScrollTag(
      {required Key key, required this.controller, required this.index, required this.child, this.disabled = false})
      : super(key: key);

  @override
  AutoScrollTagState createState() => AutoScrollTagState();
}

class AutoScrollTagState extends State<AutoScrollTag> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    if (!widget.disabled) {
      register(widget.index);
    }
  }

  @override
  void dispose() {
    if (!widget.disabled) {
      unregister(widget.index);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AutoScrollTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.key != widget.key || oldWidget.disabled != widget.disabled) {
      if (!oldWidget.disabled) unregister(oldWidget.index);

      if (!widget.disabled) register(widget.index);
    }
  }

  void register(int index) {
    // the caller in initState() or dispose() is not in the order of first dispose and init
    // so we can't assert there isn't a existing key
    // assert(!widget.controller.tagMap.keys.contains(index));
    widget.controller.tagMap[index] = this;
  }

  void unregister(int index) {
    // the caller in initState() or dispose() is not in the order of first dispose and init
    // so we can't assert there isn't a existing key
    // assert(widget.controller.tagMap.keys.contains(index));
    if (widget.controller.tagMap[index] == this) widget.controller.tagMap.remove(index);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
