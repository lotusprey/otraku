import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/switch_tile.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsAppView extends StatelessWidget {
  const SettingsAppView();

  @override
  Widget build(BuildContext context) => ListView(
        physics: Config.PHYSICS,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        children: [
          Row(
            children: [
              Flexible(
                child: DropDownField<ThemeMode>(
                  title: 'Theme Mode',
                  value: Theming.it.mode,
                  items: const {
                    'Auto': ThemeMode.system,
                    'Light': ThemeMode.light,
                    'Dark': ThemeMode.dark,
                  },
                  onChanged: (val) => Theming.it.mode = val,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: DropDownField<int>(
                  title: 'Startup Page',
                  value: Config.storage.read(Config.STARTUP_PAGE) ??
                      HomeView.ANIME_LIST,
                  items: {
                    'Feed': HomeView.FEED,
                    'Anime List': HomeView.ANIME_LIST,
                    'Manga List': HomeView.MANGA_LIST,
                    'Explore': HomeView.EXPLORE,
                    'Profile': HomeView.PROFILE,
                  },
                  onChanged: (val) =>
                      Config.storage.write(Config.STARTUP_PAGE, val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: DropDownField<int>(
                  title: 'Default Explore Option',
                  value: Config.storage.read(Config.DEFAULT_EXPLORE) ?? 0,
                  items: Map.fromIterable(
                    Explorable.values,
                    key: (e) => Convert.clarifyEnum(describeEnum(e))!,
                    value: (e) => e.index,
                  ),
                  onChanged: (val) =>
                      Config.storage.write(Config.DEFAULT_EXPLORE, val),
                ),
              ),
              const SizedBox(width: 10),
              const Flexible(child: SizedBox()),
            ],
          ),
          SwitchTile(
            title: 'Left-Handed Mode',
            initialValue: Config.storage.read(Config.LEFT_HANDED) ?? false,
            onChanged: (val) => Config.storage.write(Config.LEFT_HANDED, val),
          ),
          SwitchTile(
            title: '12 Hour Clock',
            initialValue: Config.storage.read(Config.CLOCK_TYPE) ?? false,
            onChanged: (val) => Config.storage.write(Config.CLOCK_TYPE, val),
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
            options: Theming.names,
            leftValue: Theming.it.light,
            rightValue: Theming.it.dark,
            onChangedLeft: (val) => Theming.it.light = val,
            onChangedRight: (val) => Theming.it.dark = val,
          ),
          SizedBox(height: NavBar.offset(context)),
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
    required this.options,
    required this.leftValue,
    required this.rightValue,
    required this.onChangedLeft,
    required this.onChangedRight,
  });

  @override
  __RadioState createState() => __RadioState();
}

class __RadioState extends State<_Radio> {
  late int _leftValue;
  late int _rightValue;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Radio<int>(
            value: index,
            groupValue: _leftValue,
            onChanged: (_) {
              widget.onChangedLeft(index);
              setState(() => _leftValue = index);
            },
          ),
          Text(widget.options[index]),
          Radio<int>(
            value: index,
            groupValue: _rightValue,
            onChanged: (_) {
              widget.onChangedRight(index);
              setState(() => _rightValue = index);
            },
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
