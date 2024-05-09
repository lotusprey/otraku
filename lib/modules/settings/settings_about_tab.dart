import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/viewer/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/utils/toast.dart';

class SettingsAboutTab extends StatelessWidget {
  const SettingsAboutTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final lastNotificationFetch =
        Options().lastBackgroundWork?.millisecondsSinceEpoch;

    return Align(
      alignment: Alignment.center,
      child: ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.only(
          top: padding.top + TopBar.height + 10,
          bottom: padding.bottom + 10,
        ),
        children: [
          Image.asset(
            'assets/icons/about.png',
            color: Theme.of(context).colorScheme.primary,
            width: 180,
            height: 180,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Otraku - v.$versionCode',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Text(
            'An unofficial AniList app',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Ionicons.logo_discord),
            title: const Text('Discord'),
            onTap: () => Toast.launch(context, 'https://discord.gg/YN2QWVbFef'),
          ),
          ListTile(
            leading: const Icon(Ionicons.logo_github),
            title: const Text('Source Code'),
            onTap: () =>
                Toast.launch(context, 'https://github.com/lotusprey/otraku'),
          ),
          ListTile(
            leading: const Icon(Ionicons.cash_outline),
            title: const Text('Donate'),
            onTap: () => Toast.launch(context, 'https://ko-fi.com/lotusgate'),
          ),
          ListTile(
            leading: const Icon(Ionicons.finger_print),
            title: const Text('Privacy Policy'),
            onTap: () => Toast.launch(
              context,
              'https://sites.google.com/view/otraku/privacy-policy',
            ),
          ),
          ListTile(
            leading: const Icon(Ionicons.log_out_outline),
            title: const Text('Accounts'),
            onTap: () {
              Api.unselectAccount();
              context.go(Routes.auth);
            },
          ),
          const ListTile(
            leading: Icon(Ionicons.trash_bin_outline),
            title: Text('Clear Image Cache'),
            onTap: clearImageCache,
          ),
          const ListTile(
            leading: Icon(Ionicons.refresh_outline),
            title: Text('Reset Options'),
            onTap: Options.resetOptions,
          ),
          if (lastNotificationFetch != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Text(
                'Performed a notification check around ${DateTimeUtil.formattedDateTimeFromSeconds((lastNotificationFetch / 1000).truncate())}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
