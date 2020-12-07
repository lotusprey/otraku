import 'package:flutter/material.dart';
import 'package:otraku/tools/loader.dart';

class InboxTab extends StatelessWidget {
  const InboxTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Loader(),
    );
  }
}
