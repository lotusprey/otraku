import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class SettingsAboutTab extends StatelessWidget {
  SettingsAboutTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final offset = PageOffset.of(context);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: offset.top + 10,
        bottom: offset.bottom + 10,
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
            'Otraku - v.1.1.8+3',
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
              label: Text('Discord'),
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
              label: Text('Source Code'),
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
              label: Text('Donate'),
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
              label: Text('Privacy Policy'),
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
              label: Text('Accounts'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.error,
                ),
                foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.onError,
                ),
                overlayColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.errorContainer.withAlpha(100),
                ),
              ),
              onPressed: Client.logOut,
            ),
          ),
        ),
        SizedBox(height: NavLayout.offset(context)),
      ],
    );
  }
}
