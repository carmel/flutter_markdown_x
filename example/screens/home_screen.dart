// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../demos/basic_markdown_demo.dart';
import '../demos/centered_header_demo.dart';
import '../demos/extended_emoji_demo.dart';
import '../demos/minimal_markdown_demo.dart';
import '../demos/original_demo.dart';
import '../demos/positionable_markdown.dart';
import '../demos/subscript_syntax_demo.dart';
import '../demos/wrap_alignment_demo.dart';
import '../screens/demo_card.dart';
import '../shared/markdown_demo_widget.dart';
import 'demo_screen.dart';

// ignore_for_file: public_member_api_docs

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/homeScreen';

  final List<MarkdownDemoWidget> _demos = <MarkdownDemoWidget>[
    const MinimalMarkdownDemo(),
    const BasicMarkdownDemo(),
    const WrapAlignmentDemo(),
    const SubscriptSyntaxDemo(),
    const ExtendedEmojiDemo(),
    OriginalMarkdownDemo(),
    const CenteredHeaderDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('Markdown Demos'),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black12,
          child: ListView(
            children: <Widget>[
              // DemoCard(
              //   title: 'InviewNotifierListDemo Demo',
              //   description: 'Shows markdown article get index of element in current viewport',
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              //       return CSVExample();
              //     }));
              //   },
              // ),
              DemoCard(
                title: 'PositionableMarkdownDemo Demo',
                description: 'Shows markdown article which can scroll to specified postion',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                    return PositionableMarkdownDemo();
                  }));
                },
              ),
              for (MarkdownDemoWidget demo in _demos)
                DemoCard(
                  title: demo.title,
                  description: demo.description,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      DemoScreen.routeName,
                      arguments: demo,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
