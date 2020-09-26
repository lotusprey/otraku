import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/pages/pushable/settings_page.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (ctx) => SettingsPage(),
            )),
      ),
    );
  }
}
