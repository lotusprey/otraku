import 'package:flutter/material.dart';
import 'package:otraku/tools/loader.dart';

class InboxPage extends StatelessWidget {
  const InboxPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Loader(),
    );
  }
}
