import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/helpers/network.dart';
import 'package:otraku/tools/loader.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  static const ROUTE = '/auth';

  const AuthPage();

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _loading = true;
  StreamSubscription _subscription;

  void _verify() => Network.logIn().then((loggedIn) {
        if (loggedIn) {
          Network.initViewerId().then((ok) {
            if (ok) Get.offAllNamed(HomePage.ROUTE);
          });
        } else {
          setState(() => _loading = false);
        }
      });

  Future<void> _requestAccessToken() async {
    setState(() => _loading = true);

    const _redirectUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token';

    if (await canLaunch(_redirectUrl)) {
      await launch(_redirectUrl);
    } else {
      Get.defaultDialog(
        radius: 5,
        backgroundColor: Get.theme.backgroundColor,
        titleStyle: Get.theme.textTheme.headline3,
        title: 'Could not connect to AniList',
        content: Text(
          'Could not launch authentication url',
          style: Get.theme.textTheme.bodyText1,
        ),
        actions: [
          FlatButton(
            child: Text('Oh No', style: Get.theme.textTheme.bodyText2),
            onPressed: Get.back,
          ),
        ],
      );
      setState(() => _loading = false);
      return;
    }

    _subscription = getLinksStream().listen(
      (final String link) {
        final int start = link.indexOf('=') + 1;
        final int end = link.indexOf('&');
        final String accessToken = link.substring(start, end);
        // final int expiration =
        //     int.parse(link.substring(link.lastIndexOf('=') + 1));
        Network.accessToken = accessToken;
        _verify();
      },
      onError: (error) {
        setState(() => _loading = false);
        Get.defaultDialog(
          radius: 5,
          backgroundColor: Get.theme.backgroundColor,
          titleStyle: Get.theme.textTheme.headline3,
          title: 'Could not connect to AniList',
          content: Text(error.toString(), style: Get.theme.textTheme.bodyText1),
          actions: [
            FlatButton(
              child: Text('Oh No', style: Get.theme.textTheme.bodyText2),
              onPressed: Get.back,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const Loader()
            : SafeArea(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          'An unofficial AniList app.',
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              .copyWith(fontSize: Styles.FONT_BIG),
                        ),
                      ),
                      RaisedButton(
                        padding: Config.PADDING,
                        shape: const RoundedRectangleBorder(
                          borderRadius: Config.BORDER_RADIUS,
                        ),
                        color: Theme.of(context).accentColor,
                        child: Text(
                          'Connect to AniList',
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: _requestAccessToken,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _verify();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
