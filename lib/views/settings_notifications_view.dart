import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings_controller.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class SettingsNotificationsView extends StatelessWidget {
  const SettingsNotificationsView();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final options = settings.model.notificationOptions;
    final siteValues = <bool>[];
    for (int i = 0; i < NotificationType.values.length - 2; i++)
      siteValues.add(
        options[describeEnum(NotificationType.values[i])] ?? false,
      );

    final siteOptions = <Widget>[];

    siteOptions.add(_Title('Users'));
    siteOptions.add(
      _Grid(from: 0, to: 1, values: siteValues, onChanged: changeSiteOption),
    );
    siteOptions.add(_Title('Activities'));
    siteOptions.add(
      _Grid(from: 1, to: 7, values: siteValues, onChanged: changeSiteOption),
    );
    siteOptions.add(_Title('Forum'));
    siteOptions.add(
      _Grid(from: 7, to: 12, values: siteValues, onChanged: changeSiteOption),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          ...siteOptions,
          SliverToBoxAdapter(
            child: SizedBox(height: NavBar.offset(context)),
          ),
        ],
      ),
    );
  }

  void changeSiteOption(List<bool> values) {
    const key = 'notificationOptions';
    final settings = Get.find<SettingsController>();

    if (settings.changes.containsKey(key))
      for (int i = 0; i < values.length; i++)
        settings.changes[key][i]['enabled'] = values[i];
    else {
      final newOptions = [];
      for (int i = 0; i < values.length; i++)
        newOptions.add({
          'type': describeEnum(NotificationType.values[i]),
          'enabled': values[i],
        });
      settings.changes[key] = newOptions;
    }
  }
}

class _Title extends StatelessWidget {
  final String title;
  const _Title(this.title);

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: Theme.of(context).textTheme.headline6),
        ),
      );
}

class _Grid extends StatelessWidget {
  final int from;
  final int to;
  final List<bool> values;
  final Function(List<bool>) onChanged;
  _Grid({
    required this.from,
    required this.to,
    required this.values,
    required this.onChanged,
  });

  static const _gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
    height: 40,
    minWidth: 200,
    mainAxisSpacing: 0,
  );

  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            i += from;
            return CheckBoxField(
              title: NotificationType.values[i].text,
              initial: values[i],
              onChanged: (val) {
                values[i] = val;
                onChanged(values);
              },
            );
          },
          childCount: to - from,
        ),
        gridDelegate: _gridDelegate,
      );
}
