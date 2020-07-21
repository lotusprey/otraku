import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/color_grid.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Palette _palette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: _palette.primary,
        actionsForegroundColor: _palette.accent,
        middle: Text('Settings', style: _palette.titleInactive),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Theme', style: _palette.titleSmall),
            const SizedBox(height: 5),
            TitleSegmentedControl(
              pairs: {'Light': false, 'Dark': true},
              startIndex:
                  Provider.of<Theming>(context, listen: false).isDark ? 1 : 0,
              function: (toDark) => Provider.of<Theming>(context, listen: false)
                  .setTheme(toDark: toDark),
            ),
            const SizedBox(height: 5),
            ColorGrid(_palette),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }
}
