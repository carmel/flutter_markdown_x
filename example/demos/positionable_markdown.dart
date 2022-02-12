// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_x/flutter_markdown_x.dart';
import 'package:flutter_markdown_x/src/scroll_to.dart';
import 'package:markdown/markdown.dart' as md;

import '../shared/markdown_extensions.dart';

class PositionableMarkdownDemo extends StatefulWidget {
  const PositionableMarkdownDemo({Key? key}) : super(key: key);

  @override
  _PositionableMarkdownDemoState createState() => _PositionableMarkdownDemoState();
}

class _PositionableMarkdownDemoState extends State<PositionableMarkdownDemo> {
  final _title = 'Positionable Markdown Demo';
  Future<String> get data => rootBundle.loadString('assets/markdown_help.md');
  MarkdownExtensionSet _extensionSet = MarkdownExtensionSet.githubFlavored;
  late AutoScrollController controller;
  double _offset = 0;
  double _visible = 0;
  final double fontSize = 20;
  final _wrapAlignment = WrapAlignment.start;

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical)
      ..addListener(() {
        switch (controller.position.userScrollDirection) {
          case ScrollDirection.forward:
            if (_visible == 0) {
              setState(() {
                _visible = 1;
              });
            }
            break;
          case ScrollDirection.reverse:
            if (_visible == 1) {
              setState(() {
                _visible = 0;
              });
            }
            break;
          default:
        }
      });
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        controller.jumpTo(controller.position.maxScrollExtent * 60.2 / 100);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Visibility(
            visible: _visible == 1,
            // opacity: _visible,
            // duration: Duration(milliseconds: 300),
            // curve: Curves.elasticInOut,
            child: Container(
                margin: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'toc',
                      tooltip: 'toc',
                      onPressed: () {
                        // scroll to the specified position by offset pixels
                        controller.animateTo(_offset + 1000,
                            curve: Curves.linear, duration: Duration(milliseconds: 500));
                        // scroll to the specified position by index
                        controller.scrollToIndex(20, preferPosition: AutoScrollPosition.begin);
                      },
                      child: Icon(Icons.toc),
                    ),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'setting',
                      tooltip: 'setting',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Current Index is: $_offset')));
                      },
                      child: Icon(Icons.settings),
                    )
                  ],
                ))),
        body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                _offset = scrollNotification.metrics.pixels;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    width: 84,
                    elevation: 0,
                    backgroundColor: Color(0x99000000),
                    duration: const Duration(milliseconds: 800),
                    // padding: const EdgeInsets.all(0),
                    // margin: const EdgeInsets.only(top: 20, bottom: 0),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    content: Text(
                      '${(_offset * 100 / scrollNotification.metrics.maxScrollExtent).toStringAsFixed(1)}%',
                      textAlign: TextAlign.center,
                    )));
              }
              return true;
            },
            child: CustomScrollView(
              shrinkWrap: true,
              controller: controller,
              slivers: <Widget>[
                FutureBuilder<String>(
                    future: data,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return PositionableMarkdown(
                          key: Key(_extensionSet.name),
                          controller: controller,
                          data: snapshot.data ?? '',
                          selectable: true,
                          // bulletBuilder: ,
                          imageDirectory: 'https://raw.githubusercontent.com',
                          inlineSyntaxes: [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                          blockSyntaxes: [...md.ExtensionSet.gitHubFlavored.blockSyntaxes],
                          // extensionSet: md.ExtensionSet(
                          // <md.BlockSyntax>[], <md.InlineSyntax>[SubscriptSyntax()]),
                          builders: <String, MarkdownElementBuilder>{},
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            blockSpacing: 14,
                            p: TextStyle(fontSize: fontSize),
                            listBullet: TextStyle(fontSize: fontSize),
                            listIndent: 34,
                            a: TextStyle(letterSpacing: 5),
                            textAlign: _wrapAlignment,
                            h1Align: _wrapAlignment,
                            h2Align: _wrapAlignment,
                            h3Align: _wrapAlignment,
                            h4Align: _wrapAlignment,
                            h5Align: _wrapAlignment,
                            h6Align: _wrapAlignment,
                            unorderedListAlign: _wrapAlignment,
                            orderedListAlign: _wrapAlignment,
                            blockquoteAlign: _wrapAlignment,
                            codeblockAlign: _wrapAlignment,
                          ),
                          onTapLink: (String text, String? href, String title) =>
                              linkOnTapHandler(context, text, href, title),
                          appbar: SliverAppBar(
                            floating: true,
                            elevation: 4,
                            automaticallyImplyLeading: false,
                            // backgroundColor: Color(0xf0EBEDEE),
                            // expandedHeight: 120.0,
                            // iconTheme: IconThemeData(color: Colors.black38),
                            leading: IconButton(
                                icon: Icon(Icons.arrow_back_ios, color: Colors.black38),
                                onPressed: () => Navigator.pop(context)),
                            title: Text(_title),
                            // bottom: Layout.appBar(ctx: context, title: 'testw'),
                            actions: <Widget>[
                              // IconButton(icon: Icon(Icons.settings), disabledColor: Colors.grey, onPressed: null),
                              PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  padding: EdgeInsets.zero,
                                  elevation: 5,
                                  itemBuilder: (_) => <PopupMenuEntry<int>>[
                                        PopupMenuDivider(
                                          height: 0.5,
                                        ),
                                        PopupMenuItem<int>(
                                            value: 1,
                                            child: ListTile(
                                              dense: true,
                                              leading: Icon(Icons.sync),
                                              title: Text('同步更新'),
                                            )),
                                        PopupMenuDivider(
                                          height: 0.5,
                                        ),
                                        PopupMenuItem<int>(
                                            value: 2,
                                            child: ListTile(
                                              dense: true,
                                              leading: Icon(Icons.bookmark_add_outlined),
                                              title: Text('保存书签'),
                                            )),
                                      ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 1:
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('同步更新')));
                                        break;
                                      case 2:
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text('保存书签: $_offset')));
                                        break;
                                    }
                                  }),
                            ],
                          ),
                          notifyHandler: (idx, maxScroll, offset) {},
                        );
                      } else {
                        return SliverToBoxAdapter(child: const CircularProgressIndicator());
                      }
                    })
              ],
            )));
  }

  // Handle the link. The [href] in the callback contains information
  // from the link. The url_launcher package or other similar package
  // can be used to execute the link.
  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) => _createDialog(context, text, href, title),
    );
  }

  Widget _createDialog(BuildContext context, String text, String? href, String title) => AlertDialog(
        title: const Text('Reference Link'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'See the following link for more information:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                'Link text: $text',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link destination: $href',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link title: $title',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );
}
