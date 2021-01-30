import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/settings.dart';
import 'package:otraku/enums/notification_type.dart';
import 'package:otraku/tools/fields/checkbox_field.dart';

class NotificationSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<Settings>();
    final options = settings.data.notificationOptions;
    final List<bool> values = [];
    for (int i = 0; i < NotificationType.values.length - 2; i++)
      values.add(options[describeEnum(NotificationType.values[i])] ?? false);

    return ListView.builder(
      physics: Config.PHYSICS,
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 50),
      itemBuilder: (_, index) => CheckboxField(
        title: NotificationType.values[index].text,
        initialValue: values[index],
        onChanged: (value) {
          values[index] = value;
          const key = 'notificationOptions';

          if (settings.changes.containsKey(key))
            for (int i = 0; i < values.length; i++)
              settings.changes[key][i]['enabled'] = values[i];
          else {
            final List<dynamic> newOptions = [];
            for (int i = 0; i < values.length; i++)
              newOptions.add({
                'type': describeEnum(NotificationType.values[i]),
                'enabled': values[i],
              });
            settings.changes[key] = newOptions;
          }
        },
      ),
      itemCount: NotificationType.values.length - 2,
    );
  }
}
