import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';

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
        padding: AppConfig.PADDING,
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
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final currentThemeIndex = box.read('theme') ?? 0;
    List<DropdownMenuItem> items = [];

    for (final theme in Themes.values) {
      items.add(DropdownMenuItem(
        value: theme,
        child: Text(
          clarifyEnum(describeEnum(theme)),
          style: theme.index != currentThemeIndex
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.bodyText2,
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: AppConfig.BORDER_RADIUS,
      ),
      child: DropdownButton(
        value: Themes.values[currentThemeIndex],
        items: items,
        onChanged: (theme) => setState(() {
          box.write('theme', (theme as Themes).index);
          Get.changeTheme((theme as Themes).themeData);
        }),
        iconEnabledColor: Theme.of(context).disabledColor,
        dropdownColor: Theme.of(context).primaryColor,
        underline: const SizedBox(),
        // isExpanded: true,
      ),
    );
  }
}
