import 'package:flutter/material.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: ViewConfig.PADDING,
        children: [
          InputFieldStructure(title: 'Theme', body: _ThemeDropdown()),
        ],
      ),
    );
  }
}

class _ThemeDropdown extends StatefulWidget {
  @override
  _ThemeDropdownState createState() => _ThemeDropdownState();
}

class _ThemeDropdownState extends State<_ThemeDropdown> {
  Design provider;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = [];

    for (final swatch in Swatch.values) {
      items.add(DropdownMenuItem(
        value: swatch,
        child: Text(
          swatch.name,
          style: swatch != provider.swatch
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.bodyText2,
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: ViewConfig.BORDER_RADIUS,
      ),
      child: DropdownButton(
        value: provider.swatch,
        items: items,
        onChanged: (swatch) => setState(() => provider.swatch = swatch),
        iconEnabledColor: Theme.of(context).disabledColor,
        dropdownColor: Theme.of(context).primaryColor,
        underline: const SizedBox(),
        // isExpanded: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<Design>(context, listen: false);
  }
}
