import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class AuthView extends StatefulWidget {
  const AuthView();

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  StreamSubscription<String>? _sub;
  bool _loading = false;

  void _verify(int account) {
    if (!_loading) setState(() => _loading = true);

    Client.logIn(account).then((loggedIn) {
      if (!loggedIn) {
        setState(() => _loading = false);
        return;
      }

      Settings().selectedAccount = account;
      Navigator.pushReplacementNamed(
        context,
        RouteArg.home,
        arguments: RouteArg(id: Settings().idOf(account)),
      );
    });
  }

  Future<void> _requestAccessToken(int account) async {
    setState(() => _loading = true);

    // Prepare to receive an authentication token.
    _sub?.cancel();
    _sub = AppLinks().stringLinkStream.listen((link) async {
      final start = link.indexOf('=') + 1;
      final middle = link.indexOf('&');
      final end = link.lastIndexOf('=') + 1;

      if (start < 1 || middle < 1 || end < 1) {
        setState(() => _loading = false);
        showPopUp(
          context,
          ConfirmationDialog(
            content: 'Needed data is missing',
            title: 'Faulty response',
          ),
        );
        return;
      }

      final token = link.substring(start, middle);
      final expiration = int.tryParse(link.substring(end)) ?? -1;

      if (token.isEmpty || expiration < 0) {
        setState(() => _loading = false);
        showPopUp(
          context,
          ConfirmationDialog(
            content: 'Could not parse data',
            title: 'Faulty response',
          ),
        );
        return;
      }

      await Client.register(account, token, expiration);
      _verify(account);
    });

    // Redirect to the browser for authentication.
    final ok = await Toast.launch(
      context,
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token',
    );

    if (!ok) setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    if (Settings().selectedAccount == null) return;
    _loading = true;
    _verify(Settings().selectedAccount!);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: Loader()));

    final available0 = Settings().isAvailableAccount(0);
    final available1 = Settings().isAvailableAccount(1);

    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        padding: Consts.padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Otraku for AniList',
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 20),
              Container(
                padding: Consts.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: Consts.borderRadiusMin,
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Account',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        if (available0) ...[
                          const SizedBox(height: 5),
                          Text(
                            Settings().idOf(0)?.toString() ?? '',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    if (available0)
                      TopBarIcon(
                        icon: Ionicons.close_circle_outline,
                        tooltip: 'Remove Account',
                        onTap: () => showPopUp(
                          context,
                          ConfirmationDialog(
                            title: 'Remove Account?',
                            mainAction: 'Yes',
                            secondaryAction: 'No',
                            onConfirm: () => Client.removeAccount(0)
                                .then((_) => setState(() {})),
                          ),
                        ),
                      ),
                    TopBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available0 ? 'Log In' : 'Connect',
                      onTap: () =>
                          available0 ? _verify(0) : _requestAccessToken(0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: Consts.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: Consts.borderRadiusMin,
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secondary Account',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        if (available1) ...[
                          const SizedBox(height: 5),
                          Text(
                            Settings().idOf(1)?.toString() ?? '',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    if (available1)
                      TopBarIcon(
                        icon: Ionicons.close_circle_outline,
                        tooltip: 'Remove Account',
                        onTap: () => showPopUp(
                          context,
                          ConfirmationDialog(
                            title: 'Remove Account?',
                            mainAction: 'Yes',
                            secondaryAction: 'No',
                            onConfirm: () => Client.removeAccount(1)
                                .then((_) => setState(() {})),
                          ),
                        ),
                      ),
                    TopBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available1 ? 'Log In' : 'Connect',
                      onTap: () =>
                          available1 ? _verify(1) : _requestAccessToken(1),
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
