import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsAboutView extends StatelessWidget {
  const SettingsAboutView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: Config.PHYSICS,
      padding: Config.PADDING,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: Config.BORDER_RADIUS,
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
            'Otraku - v. 1.1.5',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Text(
          'An unofficial AniList app',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Ionicons.logo_discord),
              label: Text('Discord'),
              onPressed: () {
                try {
                  launch('https://discord.gg/YN2QWVbFef');
                } catch (err) {
                  Toast.show(context, 'Couldn\'t open link: $err');
                }
              },
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
              onPressed: () {
                try {
                  launch('https://github.com/lotusgate/otraku');
                } catch (err) {
                  Toast.show(context, 'Couldn\'t open link: $err');
                }
              },
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
              onPressed: () {
                try {
                  launch('https://ko-fi.com/lotusgate');
                } catch (err) {
                  Toast.show(context, 'Couldn\'t open link: $err');
                }
              },
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
              onPressed: () {
                try {
                  launch('https://sites.google.com/view/otraku/privacy-policy');
                } catch (err) {
                  Toast.show(context, 'Couldn\'t open link: $err');
                }
              },
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
