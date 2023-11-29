import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/utils/toast.dart';

class AuthView extends StatefulWidget {
  const AuthView([this.credentials]);

  final (String, int)? credentials;

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  bool _loading = false;
  int _account = 0;

  @override
  void initState() {
    super.initState();
    _attemptToFinishAccountSetup();
  }

  @override
  void didUpdateWidget(covariant AuthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attemptToFinishAccountSetup();
  }

  void _attemptToFinishAccountSetup() async {
    if (widget.credentials == null) return;
    final token = widget.credentials!.$1;
    final expiration = widget.credentials!.$2;
    if (await Api.addAccount(_account, token, expiration) && mounted) {
      context.go(Routes.home());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Loader()),
            const SizedBox(height: 10),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => setState(() => _loading = false),
            ),
          ],
        ),
      );
    }

    final available0 = Options().isAvailableAccount(0);
    final available1 = Options().isAvailableAccount(1);

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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Container(
                padding: Consts.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (available0) ...[
                          const SizedBox(height: 5),
                          Text(
                            Options().idOf(0)?.toString() ?? '',
                            style: Theme.of(context).textTheme.labelMedium,
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
                            onConfirm: () => Api.removeAccount(0)
                                .then((_) => setState(() {})),
                          ),
                        ),
                      ),
                    TopBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available0 ? 'Log In' : 'Connect',
                      onTap: () =>
                          available0 ? _selectAccount(0) : _addAccount(0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: Consts.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (available1) ...[
                          const SizedBox(height: 5),
                          Text(
                            Options().idOf(1)?.toString() ?? '',
                            style: Theme.of(context).textTheme.labelMedium,
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
                            onConfirm: () => Api.removeAccount(1)
                                .then((_) => setState(() {})),
                          ),
                        ),
                      ),
                    TopBarIcon(
                      icon: Ionicons.enter_outline,
                      tooltip: available1 ? 'Log In' : 'Connect',
                      onTap: () =>
                          available1 ? _selectAccount(1) : _addAccount(1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Before connecting another account, you should log out from the first one in the browser.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAccount(int account) async {
    if (await Api.selectAccount(account) && mounted) {
      context.go(Routes.home());
    }
  }

  Future<void> _addAccount(int account) async {
    setState(() => _loading = true);
    _account = account;
    final ok = await Toast.launch(
      context,
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token',
    );
    if (!ok) setState(() => _loading = false);
  }
}
