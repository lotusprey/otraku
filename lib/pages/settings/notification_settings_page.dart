import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

class NotificationSettingsTab extends StatelessWidget {
  const NotificationSettingsTab();

  @override
  Widget build(BuildContext context) {
    final options = Get.find<Settings>().model!.notificationOptions;
    final values = <bool>[];
    for (int i = 0; i < NotificationType.values.length - 2; i++)
      values.add(options[describeEnum(NotificationType.values[i])] ?? false);

    const gridDelegate = SliverGridDelegateWithMinWidthAndFixedHeight(
      height: Config.MATERIAL_TAP_TARGET_SIZE,
      mainAxisSpacing: 0,
      minWidth: 200,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        semanticChildCount: 12, // 14,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          ..._segment(
            title: 'Users',
            ctx: context,
            gridDelegate: gridDelegate,
            indexOffset: 0,
            count: 1,
            values: values,
          ),
          ..._segment(
            title: 'Activities',
            ctx: context,
            gridDelegate: gridDelegate,
            indexOffset: 1,
            count: 6,
            values: values,
          ),
          ..._segment(
            title: 'Forum',
            ctx: context,
            gridDelegate: gridDelegate,
            indexOffset: 7,
            count: 5,
            values: values,
          ),
          // ..._segment(
          //   title: 'Media',
          //   ctx: context,
          //   gridDelegate: gridDelegate,
          //   indexOffset: 12,
          //   count: 2,
          //   values: values,
          // ),
          SliverToBoxAdapter(
            child: SizedBox(height: NavBar.offset(context)),
          ),
        ],
      ),
    );
  }

  List<Widget> _segment({
    required String title,
    required BuildContext ctx,
    required SliverGridDelegate gridDelegate,
    required int indexOffset,
    required int count,
    required List<bool> values,
  }) =>
      [
        SliverToBoxAdapter(
          child: Text(title, style: Theme.of(ctx).textTheme.headline5),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final index = indexOffset + i;
              return CheckboxField(
                title: NotificationType.values[index].text,
                initialValue: values[index],
                onChanged: (val) {
                  values[index] = val;
                  const key = 'notificationOptions';
                  final settings = Get.find<Settings>();

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
                },
              );
            },
            childCount: count,
            semanticIndexOffset: indexOffset,
          ),
          gridDelegate: gridDelegate,
        ),
      ];
}
