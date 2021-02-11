import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/tools/fields/three_state_field.dart';
import 'package:otraku/tools/fields/two_state_field.dart';

class OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final int index;
  final Function(int) onTap;

  OptionSheet({
    @required this.title,
    @required this.options,
    @required this.index,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sideMargin = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;
    return Container(
      height: options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50.0,
      margin: EdgeInsets.only(
        left: sideMargin,
        right: sideMargin,
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
      ),
      padding: Config.PADDING,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 46, bottom: 10),
            child: Text(title, style: Theme.of(context).textTheme.subtitle1),
          ),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(
                  options[i],
                  style: i != index
                      ? Theme.of(context).textTheme.bodyText1
                      : Theme.of(context).textTheme.bodyText2,
                ),
                trailing: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i != index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor,
                  ),
                ),
                onTap: () {
                  onTap(i);
                  Navigator.pop(context);
                },
              ),
              itemCount: options.length,
              itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectionSheet<T> extends StatelessWidget {
  final List<String> options;
  final List<T> values;
  final List<T> inclusive;
  final List<T> exclusive;
  final Function(List<T>, List<T>) onDone;

  SelectionSheet({
    @required this.onDone,
    @required this.options,
    @required this.values,
    @required this.inclusive,
    this.exclusive,
  });

  @override
  Widget build(BuildContext context) {
    final sideMargin = MediaQuery.of(context).size.width > 420
        ? (MediaQuery.of(context).size.width - 400) / 2
        : 20.0;
    return Container(
      margin: EdgeInsets.only(
        left: sideMargin,
        right: sideMargin,
        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: Config.PHYSICS,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (_, index) => exclusive == null
                  ? TwoStateField(
                      title: options[index],
                      initial: inclusive.contains(values[index]),
                      onChanged: (val) {
                        if (val)
                          inclusive.add(values[index]);
                        else
                          inclusive.remove(values[index]);
                      },
                    )
                  : ThreeStateField(
                      title: options[index],
                      initialState: inclusive.contains(values[index])
                          ? 1
                          : exclusive.contains(values[index])
                              ? 2
                              : 0,
                      onChanged: (state) {
                        if (state == 0) {
                          exclusive.remove(values[index]);
                        } else if (state == 1) {
                          inclusive.add(values[index]);
                        } else {
                          inclusive.remove(values[index]);
                          exclusive.add(values[index]);
                        }
                      },
                    ),
              itemCount: options.length,
              itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
            ),
          ),
          FlatButton.icon(
            onPressed: () {
              onDone(inclusive, exclusive);
              Navigator.pop(context);
            },
            icon: Icon(
              FluentSystemIcons.ic_fluent_checkmark_filled,
              color: Theme.of(context).accentColor,
              size: Styles.ICON_SMALLER,
            ),
            label: Text('Done', style: Theme.of(context).textTheme.headline5),
          ),
        ],
      ),
    );
  }
}
