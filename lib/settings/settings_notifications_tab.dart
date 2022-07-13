import 'package:flutter/material.dart';
import 'package:otraku/notifications/notification_model.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class SettingsNotificationsTab extends StatelessWidget {
  SettingsNotificationsTab(this.scrollCtrl, this.settings, this.shouldUpdate);

  final ScrollController scrollCtrl;
  final UserSettings settings;
  final void Function() shouldUpdate;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    widgets.add(_Title('Users'));
    widgets.add(_Grid(
      from: 0,
      to: 1,
      options: settings.notificationOptions,
      onChanged: shouldUpdate,
    ));
    widgets.add(_Title('Activities'));
    widgets.add(_Grid(
      from: 1,
      to: 7,
      options: settings.notificationOptions,
      onChanged: shouldUpdate,
    ));
    widgets.add(_Title('Forum'));
    widgets.add(_Grid(
      from: 7,
      to: 12,
      options: settings.notificationOptions,
      onChanged: shouldUpdate,
    ));
    widgets.add(_Title('Media'));
    widgets.add(_Grid(
      from: 12,
      to: 16,
      options: settings.notificationOptions,
      onChanged: shouldUpdate,
    ));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: PageLayout.of(context).topOffset),
          ),
          ...widgets,
          const SliverFooter(),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: Theme.of(context).textTheme.headline2),
        ),
      );
}

class _Grid extends StatelessWidget {
  _Grid({
    required this.from,
    required this.to,
    required this.options,
    required this.onChanged,
  });

  final int from;
  final int to;
  final Map<NotificationType, bool> options;
  final void Function() onChanged;

  @override
  Widget build(BuildContext context) {
    const gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      height: 40,
      minWidth: 200,
      mainAxisSpacing: 0,
    );

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          i += from;
          final e = options.entries.elementAt(i);
          return CheckBoxField(
            title: Convert.clarifyEnum(e.key.name)!,
            initial: e.value,
            onChanged: (val) {
              options[e.key] = val;
              onChanged();
            },
          );
        },
        childCount: to - from,
      ),
      gridDelegate: gridDelegate,
    );
  }
}
