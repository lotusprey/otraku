import 'package:flutter/material.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/widgets/fields/checkbox_field.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';

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
            height: MediaQuery.of(context).padding.top + TopBar.height + 10,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: settings.notificationOptions.length,
            (context, i) {
              final e = settings.notificationOptions.entries.elementAt(i);

              return CheckBoxField(
                title: Convert.clarifyEnum(e.key.name)!,
                initial: e.value,
                onChanged: (val) {
                  settings.notificationOptions[e.key] = val;
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
