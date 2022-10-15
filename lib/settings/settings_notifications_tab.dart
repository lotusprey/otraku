import 'package:flutter/material.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class SettingsNotificationsTab extends StatelessWidget {
  const SettingsNotificationsTab(
    this.scrollCtrl,
    this.settings,
    this.scheduleUpdate,
  );

  final ScrollController scrollCtrl;
  final UserSettings settings;
  final void Function() scheduleUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: PageLayout.of(context).topOffset),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              height: 40,
              minWidth: 200,
              mainAxisSpacing: 0,
            ),
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
      ),
    );
  }
}
