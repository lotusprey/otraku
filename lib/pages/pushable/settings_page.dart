import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _box = SizedBox(width: 10, height: 10);

  Palette _palette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: ViewConfig.PADDING,
        children: [
          Text('Theme', style: _palette.detail),
          _box,
          _ThemeDropDown(),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }
}

class _ThemeDropDown extends StatefulWidget {
  @override
  _ThemeDropDownState createState() => _ThemeDropDownState();
}

class _ThemeDropDownState extends State<_ThemeDropDown> {
  Theming provider;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < Palette.SWATCHES.length; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(
          Palette.SWATCHES[i].name,
          style: i != provider.swatchIndex
              ? provider.palette.paragraph
              : provider.palette.exclamation,
        ),
      ));
    }

    return DropdownButton(
      value: provider.swatchIndex,
      items: items,
      onChanged: (index) => setState(() => provider.swatchIndex = index),
      iconEnabledColor: provider.palette.faded,
      dropdownColor: provider.palette.foreground,
      underline: const SizedBox(),
    );
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<Theming>(context, listen: false);
  }
}
