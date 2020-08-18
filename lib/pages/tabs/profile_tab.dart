import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/pages/pushable/settings_page.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return Center(
      child: IconButton(
        icon: Icon(Icons.settings),
        color: palette.faded,
        iconSize: Palette.ICON_MEDIUM,
        onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (ctx) => SettingsPage(),
            )),
      ),
    );
  }
}
