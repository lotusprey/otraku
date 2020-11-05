import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/pages/pushable/setting_menus/app_settings_page.dart';
import 'package:otraku/pages/pushable/setting_menus/list_settings_page.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/providers/collections.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static const padding = const EdgeInsets.symmetric(horizontal: 5);

  final Map<String, dynamic> changes = {};

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        callOnPop: () {
          if (changes.keys.length > 0) {
            Provider.of<Users>(context, listen: false)
                .updateSettings(changes)
                .then((_) {
              if (changes.containsKey('splitCompletedAnime')) {
                Provider.of<Collections>(context, listen: false).fetchMyAnime();
              }
              if (changes.containsKey('splitCompletedManga')) {
                Provider.of<Collections>(context, listen: false).fetchMyManga();
              }
            });
          }
        },
      ),
      body: ListView(
        padding: AppConfig.PADDING,
        children: [
          ListTile(
            contentPadding: padding,
            leading: Icon(
              FluentSystemIcons.ic_fluent_phone_link_setup_regular,
              color: Theme.of(context).dividerColor,
            ),
            title: Text('App', style: Theme.of(context).textTheme.bodyText1),
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (ctx) => AppSettingsPage(),
                )),
          ),
          ListTile(
            contentPadding: padding,
            leading: Icon(
              FluentSystemIcons.ic_fluent_text_bullet_list_regular,
              color: Theme.of(context).dividerColor,
            ),
            title: Text('Lists', style: Theme.of(context).textTheme.bodyText1),
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (ctx) => ListSettingsPage(changes),
                )),
          ),
        ],
      ),
    );
  }
}
