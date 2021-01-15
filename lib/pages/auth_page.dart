import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/pages/loading_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/helpers/network.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  const AuthPage();

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _triedConnecting = false;
  StreamSubscription _subscription;

  Future<void> _authenticate() async {
    const String _redirectUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token';
    if (await canLaunch(_redirectUrl)) {
      await launch(_redirectUrl);
    } else {
      throw 'Could not launch authentication url';
    }

    _subscription = getLinksStream().listen(
      (final String link) {
        final int start = link.indexOf('=') + 1;
        final int end = link.indexOf('&');
        final String accessToken = link.substring(start, end);
        // final int expiration =
        //     int.parse(link.substring(link.lastIndexOf('=') + 1));
        Network.accessToken = accessToken;
        Get.offAll(LoadingPage(), transition: Transition.fadeIn);
      },
      onError: (error) => print('error: $error'),
    );

    setState(() => _triedConnecting = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !_triedConnecting
            ? RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: Config.BORDER_RADIUS,
                ),
                color: Theme.of(context).accentColor,
                child: Text('Connect'),
                onPressed: _authenticate,
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
