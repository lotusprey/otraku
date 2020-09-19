import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
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
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: Padding(
        padding: ViewConfig.PADDING,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Theme', style: _palette.smallTitle),
            const SizedBox(height: 5),
            TitleSegmentedControl(
              value: Provider.of<Theming>(context).isDark ? true : false,
              pairs: const {'Light': false, 'Dark': true},
              onNewValue: (toDark) =>
                  Provider.of<Theming>(context, listen: false)
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
