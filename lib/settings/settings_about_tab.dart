import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class SettingsAboutTab extends StatelessWidget {
  const SettingsAboutTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final pageLayout = PageLayout.of(context);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: pageLayout.topOffset + 10,
        bottom: pageLayout.bottomOffset + 10,
      ),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: Consts.borderRadiusMin,
            child: Image.asset(
              'assets/icons/about_icon.png',
              fit: BoxFit.contain,
              width: 200,
              height: 200,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'Otraku - v.1.2.1',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        const Text('An unofficial AniList app', textAlign: TextAlign.center),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.logo_discord),
              label: const Text('Discord'),
              onPressed: () =>
                  Toast.launch(context, 'https://discord.gg/YN2QWVbFef'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.logo_github),
              label: const Text('Source Code'),
              onPressed: () =>
                  Toast.launch(context, 'https://github.com/lotusgate/otraku'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.cash_outline),
              label: const Text('Donate'),
              onPressed: () =>
                  Toast.launch(context, 'https://ko-fi.com/lotusgate'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.finger_print),
              label: const Text('Privacy Policy'),
              onPressed: () => Toast.launch(
                context,
                'https://sites.google.com/view/otraku/privacy-policy',
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.log_out_outline),
              label: const Text('Accounts'),
              onPressed: Api.logOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
