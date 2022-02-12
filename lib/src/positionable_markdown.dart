import 'package:flutter/material.dart';
import 'package:flutter_markdown_x/src/inview_notifier.dart';
import 'package:flutter_markdown_x/src/scroll_to.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';

class PositionableMarkdown extends MarkdownWidget {
  const PositionableMarkdown({
    Key? key,
    required this.controller,
    required this.appbar,
    required this.notifyHandler,
    required String data,
    this.padding = const EdgeInsets.only(top: 4, bottom: 24, left: 15, right: 15),
    bool selectable = false,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders = const <String, MarkdownElementBuilder>{},
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment = MarkdownListItemCrossAxisAlignment.baseline,
  }) : super(
          key: key,
          data: data,
          selectable: selectable,
          styleSheet: styleSheet,
          styleSheetTheme: styleSheetTheme,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          onTapText: onTapText,
          imageDirectory: imageDirectory,
          blockSyntaxes: blockSyntaxes,
          inlineSyntaxes: inlineSyntaxes,
          extensionSet: extensionSet,
          imageBuilder: imageBuilder,
          checkboxBuilder: checkboxBuilder,
          builders: builders,
          listItemCrossAxisAlignment: listItemCrossAxisAlignment,
          bulletBuilder: bulletBuilder,
        );

  final AutoScrollController controller;
  final EdgeInsets padding;
  final SliverAppBar appbar;
  final void Function(int, double, double) notifyHandler;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return InViewNotifier(
      appbar: appbar,
      controller: controller,
      inViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
        final goldenSelection = viewPortDimension - 0.618 * viewPortDimension;
        return deltaTop < goldenSelection && deltaBottom > goldenSelection;
      },
      sliverPadding: padding,
      slivers: children,
      notifyHandler: notifyHandler,
    );
  }
}
