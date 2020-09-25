import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  static const String _clientId = '3535';
  static const String _authUrl = 'https://anilist.co/api/v2/oauth/authorize';

  static const String _redirectUrl =
      '$_authUrl?client_id=$_clientId&response_type=token';

  const AuthPage();

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _triedConnecting = false;
  StreamSubscription _subscription;

  Future<void> _authenticate() async {
    if (await canLaunch(AuthPage._redirectUrl)) {
      await launch(AuthPage._redirectUrl);
    } else {
      throw 'Could not launch the url: ${AuthPage._authUrl}';
    }

    _subscription = getLinksStream().listen(
      (String link) {
        int start = link.indexOf('=') + 1;
        int end = link.indexOf('&');
        String accessToken = link.substring(start, end);
        Provider.of<Auth>(context, listen: false).setAccessToken(accessToken);
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
                  borderRadius: ViewConfig.RADIUS,
                ),
                color: Theme.of(context).accentColor,
                child: Text('Connect'),
                onPressed: _authenticate,
              )
            : const Center(child: BlossomLoader()),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
