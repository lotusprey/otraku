import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  static const String _clientId = '3535';

  static const String _baseUrl = 'https://anilist.co/api/v2/oauth/authorize';

  static const String _redirectUrl =
      '$_baseUrl?client_id=$_clientId&response_type=token';

  const AuthPage();

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _triedConnecting = false;
  TextEditingController _controller = TextEditingController();
  Palette _palette;

  Future<void> _redirectRequest() async {
    if (await canLaunch(AuthPage._redirectUrl)) {
      await launch(AuthPage._redirectUrl);
    } else {
      throw 'Could not launch the url: ${AuthPage._baseUrl}';
    }

    setState(() => _triedConnecting = true);
  }

  void _acceptToken() {
    final accessToken = _controller.text.trim();

    if (accessToken == '') return;

    Provider.of<Auth>(context, listen: false).setAccessToken(accessToken);
  }

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_triedConnecting) {
      return Scaffold(
        backgroundColor: _palette.background,
        body: Center(
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: _palette.accent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.account_circle,
                  size: Palette.ICON_MEDIUM,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text('Connect', style: _palette.titleClear),
              ],
            ),
            onPressed: _redirectRequest,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _palette.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                style: _palette.titleSmall,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter Access Token',
                  hintStyle: _palette.detail,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              RaisedButton(
                color: _palette.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.done,
                      size: Palette.ICON_MEDIUM,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text('Done', style: _palette.titleClear),
                  ],
                ),
                onPressed: _acceptToken,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
