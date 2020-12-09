import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/users.dart';
import 'package:otraku/tools/fields/checkbox_field.dart';
import 'package:otraku/tools/navigators/custom_app_bar.dart';

class NotificationSettingsPage extends StatelessWidget {
  static const List<String> _notificationNames = const [
    'New followers',
    'New messages',
    'Replies to my activities',
    'Replies to activities I have replied to',
    'Replies to my forum comments',
    'Activity mentions',
    'Forum mentions',
    'Comments on a subscribed thread',
    'Likes on my activities',
    'Likes on my activity replies',
    'Likes on my forum threads',
    'Likes on my forum comments',
    // 'Airings of anime I am watching',
    // 'New media related to me',
  ];

  static const List<String> _notificationTypes = const [
    'FOLLOWING',
    'ACTIVITY_MESSAGE',
    'ACTIVITY_REPLY',
    'ACTIVITY_REPLY_SUBSCRIBED',
    'THREAD_COMMENT_REPLY',
    'ACTIVITY_MENTION',
    'THREAD_COMMENT_MENTION',
    'THREAD_SUBSCRIBED',
    'ACTIVITY_LIKE',
    'ACTIVITY_REPLY_LIKE',
    'THREAD_LIKE',
    'THREAD_COMMENT_LIKE',
    // 'AIRING',
    // 'RELATED_MEDIA_ADDITION',
  ];

  final Map<String, dynamic> changes;

  NotificationSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) {
    final options = Get.find<Users>().settings.notificationOptions;
    List<bool> values = [];
    for (int i = 0; i < _notificationTypes.length; i++) {
      values.add(options[_notificationTypes[i]] ?? false);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
      ),
      body: ListView.builder(
        shrinkWrap: true,
        physics: Config.PHYSICS,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemBuilder: (_, index) => CheckboxField(
          title: _notificationNames[index],
          initialValue: values[index],
          onChanged: (value) {
            values[index] = value;
            const key = 'notificationOptions';

            if (changes.containsKey(key)) {
              for (int i = 0; i < values.length; i++) {
                changes[key][i]['enabled'] = values[i];
              }
            } else {
              final List<dynamic> newOptions = [];
              for (int i = 0; i < values.length; i++) {
                newOptions.add({
                  'type': _notificationTypes[i],
                  'enabled': values[i],
                });
              }
              changes[key] = newOptions;
            }
          },
        ),
        itemCount: _notificationNames.length,
      ),
    );
  }
}
