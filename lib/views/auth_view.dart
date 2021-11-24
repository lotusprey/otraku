import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthView extends StatefulWidget {
  const AuthView();

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _loading = true;

  void _verify(bool? primary) {
    if (primary == null) primary = LocalSettings.onPrimaryAccount;
    if (primary == null) {
      setState(() => _loading = false);
      return;
    }

    if (!_loading) setState(() => _loading = true);

    Client.logIn(primary).then((loggedIn) => loggedIn
        ? WidgetsBinding.instance!.addPostFrameCallback(
            (_) => Navigation().setBasePage(Navigation.homeRoute),
          )
        : setState(() => _loading = false));
  }

  Future<void> _requestAccessToken(bool primary) async {
    setState(() => _loading = true);

    const redirectUrl =
        'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token';

    try {
      await launch(redirectUrl);
    } catch (err) {
      showPopUp(
        context,
        ConfirmationDialog(
          title: 'Could not open AniList',
          mainAction: 'Oh No',
        ),
      );
      setState(() => _loading = false);
      return;
    }

    AppLinks(onAppLink: (Uri _, String link) async {
      final start = link.indexOf('=') + 1;
      final end = link.indexOf('&');
      await Client.register(
        primary,
        link.substring(start, end),
        int.parse(link.substring(link.lastIndexOf('=') + 1)),
      );
      closeWebView();
      _verify(primary);
    });
  }

  @override
  void initState() {
    super.initState();
    _verify(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: Loader()));

    final available0 = LocalSettings.isAvailableAccount(true);
    final available1 = LocalSettings.isAvailableAccount(false);

    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        padding: Config.PADDING,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Otraku\nAn unofficial AniList app',
                style: Theme.of(context).textTheme.headline2,
              ),
              const SizedBox(height: 20),
              Container(
                padding: Config.PADDING,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: Config.BORDER_RADIUS,
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Account',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        if (available0) ...[
                          const SizedBox(height: 5),
                          Text(
                            LocalSettings().id0?.toString() ?? '',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    if (available0)
                      AppBarIcon(
                        icon: Ionicons.close_circle_outline,
                        tooltip: 'Remove Account',
                        onTap: () => showPopUp(
                          context,
                          ConfirmationDialog(
                            title: 'Remove Account?',
                            mainAction: 'Yes',
                            secondaryAction: 'No',
                            onConfirm: () =>
                                setState(() => Client.removeAccount(true)),
                          ),
                        ),
                      ),
                    AppBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available0 ? 'Log In' : 'Connect',
                      onTap: () => available0
                          ? _verify(true)
                          : _requestAccessToken(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: Config.PADDING,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: Config.BORDER_RADIUS,
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secondary Account',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        if (available1) ...[
                          const SizedBox(height: 5),
                          Text(
                            LocalSettings().id1?.toString() ?? '',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    if (available1)
                      AppBarIcon(
                        icon: Ionicons.close_circle_outline,
                        tooltip: 'Remove Account',
                        onTap: () => showPopUp(
                          context,
                          ConfirmationDialog(
                            title: 'Remove Account?',
                            mainAction: 'Yes',
                            secondaryAction: 'No',
                            onConfirm: () =>
                                setState(() => Client.removeAccount(false)),
                          ),
                        ),
                      ),
                    AppBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available1 ? 'Log In' : 'Connect',
                      onTap: () => available1
                          ? _verify(false)
                          : _requestAccessToken(false),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  'Before connecting another account, you should log out from the first one in the browser.',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
