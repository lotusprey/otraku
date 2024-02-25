import 'package:flutter/material.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/widgets/fields/stateful_tiles.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/modules/settings/settings_model.dart';

class SettingsNotificationsTab extends StatelessWidget {
  const SettingsNotificationsTab(
    this.scrollCtrl,
    this.settings,
    this.scheduleUpdate,
  );

  final ScrollController scrollCtrl;
  final Settings settings;
  final void Function() scheduleUpdate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top + TopBar.height,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: settings.notificationOptions.length,
            (context, i) {
              final e = settings.notificationOptions.entries.elementAt(i);

              return StatefulCheckboxListTile(
                title: Text(e.key.name.noScreamingSnakeCase),
                value: e.value,
                onChanged: (v) {
                  settings.notificationOptions[e.key] = v!;
                  scheduleUpdate();
                },
              );
            },
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}
