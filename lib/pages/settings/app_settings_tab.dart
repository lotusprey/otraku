import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/tools/fields/drop_down_field.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';

class AppSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
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
                  onChanged: (value) {
                    Config.storage.write(Config.THEME_MODE, value);
                    Config.updateTheme();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: DropDownField(
                  title: 'Startup Page',
                  initialValue: Config.storage.read(Config.STARTUP_PAGE) ??
                      HomePage.ANIME_LIST,
                  items: {
                    'Feed': HomePage.FEED,
                    'Anime List': HomePage.ANIME_LIST,
                    'Manga List': HomePage.MANGA_LIST,
                    'Explore': HomePage.EXPLORE,
                    'Profile': HomePage.PROFILE,
                  },
                  onChanged: (val) =>
                      Config.storage.write(Config.STARTUP_PAGE, val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                .map((t) => FnHelper.clarifyEnum(describeEnum(t)))
                .toList(),
            leftValue: Config.storage.read(Config.LIGHT_THEME) ?? 0,
            rightValue: Config.storage.read(Config.DARK_THEME) ?? 0,
            onChangedLeft: (value) {
              Config.storage.write(Config.LIGHT_THEME, value);
              Config.updateTheme();
            },
            onChangedRight: (value) {
              Config.storage.write(Config.DARK_THEME, value);
              Config.updateTheme();
            },
          ),
          SizedBox(height: CustomNavBar.offset(context)),
        ],
      );
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
      itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
    );
  }

  @override
  void initState() {
    super.initState();
    _leftValue = widget.leftValue;
    _rightValue = widget.rightValue;
  }
}
