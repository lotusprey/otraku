import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatelessWidget {
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
            'Otraku - v. 1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        Text(
          'An unofficial AniList app',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 30),
        Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          _privacyPolicy,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {
              try {
                launch('https://anilist.co/terms');
              } catch (err) {
                Toast.show(context, 'Couldn\'t open link: $err');
              }
            },
            child: Text('AniList Terms and Privacy'),
          ),
        ),
        SizedBox(height: NavBar.offset(context)),
      ],
    );
  }

  static const _privacyPolicy =
      'All settings and tokens are stored onto the device.\n'
      'Otraku does not transfer or use your data online.\n'
      'Otraku uses the AniList API to read and mutate data and requires you to have an AniList account with which to log in, in order for you to use the app.\n'
      'You can read the AniList terms & privacy policy down below.';
}
