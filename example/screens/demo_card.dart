// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

class DemoCard extends StatelessWidget {
  const DemoCard({Key? key, required this.title, required this.description, required this.onTap}) : super(key: key);

  final String title;
  final String description;
  final VoidCallback onTap;
  // final MarkdownDemoWidget widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50, minWidth: 425, maxWidth: 425),
          child: Card(
              color: Colors.blue,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).primaryTextTheme.headline5,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
