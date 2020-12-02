import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'App',
        ),
        body: ListView(
          physics: Config.PHYSICS,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: [
            Row(
              children: [
                Flexible(
                  child: DropDownField(
                    title: 'Theme',
                    initialValue: Config.storage.read(Config.THEME_MODE) ?? 0,
                    items: {'Auto': 0, 'Light': 1, 'Dark': 2},
                    onChanged: (val) {
                      Config.storage.write(Config.THEME_MODE, val);
                      _updateTheme();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: DropDownField(
                    title: 'Startup Page',
                    initialValue: Config.storage.read(Config.STARTUP_PAGE),
                    items: {
                      'Inbox': TabManager.INBOX,
                      'Anime List': TabManager.ANIME_LIST,
                      'Manga List': TabManager.MANGA_LIST,
                      'Explore': TabManager.EXPLORE,
                      'Profile': TabManager.PROFILE,
                    },
                    onChanged: (val) =>
                        Config.storage.write(Config.STARTUP_PAGE, val),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Light Theme',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  'Dark Theme',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            _Radio(
              options: Themes.values
                  .map((t) => clarifyEnum(describeEnum(t)))
                  .toList(),
              leftValue: Config.storage.read(Config.LIGHT_THEME) ?? 0,
              rightValue: Config.storage.read(Config.DARK_THEME) ?? 0,
              onChangedLeft: (val) => _switchTheme(val, false),
              onChangedRight: (val) => _switchTheme(val, true),
            ),
          ],
        ),
      );

  void _switchTheme(int value, bool isDark) {
    if (isDark) {
      Config.storage.write(Config.DARK_THEME, value);
    } else {
      Config.storage.write(Config.LIGHT_THEME, value);
    }

    _updateTheme();
  }

  void _updateTheme() {
    final themeMode = Config.storage.read(Config.THEME_MODE) ?? 0;
    if (themeMode == 0) {
      if (Get.isPlatformDarkMode) {
        Get.changeTheme(
          Themes.values[Config.storage.read(Config.DARK_THEME) ?? 0].themeData,
        );
      } else {
        Get.changeTheme(
          Themes.values[Config.storage.read(Config.LIGHT_THEME) ?? 0].themeData,
        );
      }
    } else {
      if (themeMode == 1) {
        Get.changeTheme(
          Themes.values[Config.storage.read(Config.LIGHT_THEME) ?? 0].themeData,
        );
      } else {
        Get.changeTheme(
          Themes.values[Config.storage.read(Config.DARK_THEME) ?? 0].themeData,
        );
      }
    }
  }
}

class _Radio extends StatefulWidget {
  final List<String> options;
  final int leftValue;
  final int rightValue;
  final Function(int) onChangedLeft;
  final Function(int) onChangedRight;

  _Radio({
    @required this.options,
    @required this.leftValue,
    @required this.rightValue,
    @required this.onChangedLeft,
    @required this.onChangedRight,
  });

  @override
  __RadioState createState() => __RadioState();
}

class __RadioState extends State<_Radio> {
  int _leftValue;
  int _rightValue;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Radio(
            value: index,
            groupValue: _leftValue,
            onChanged: (_) {
              widget.onChangedLeft(index);
              setState(() => _leftValue = index);
            },
            activeColor: Theme.of(context).accentColor,
          ),
          Text(
            widget.options[index],
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Radio(
            value: index,
            groupValue: _rightValue,
            onChanged: (_) {
              widget.onChangedRight(index);
              setState(() => _rightValue = index);
            },
            activeColor: Theme.of(context).accentColor,
          ),
        ],
      ),
      itemCount: widget.options.length,
    );
  }

  @override
  void initState() {
    super.initState();
    _leftValue = widget.leftValue;
    _rightValue = widget.rightValue;
  }
}
