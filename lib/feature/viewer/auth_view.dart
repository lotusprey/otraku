import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/persistence.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView([this.credentials]);

  final (String token, int secondsUntilExpiration)? credentials;

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends ConsumerState<AuthView> {
  bool _loading = false;

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

    final account = await ref
        .read(repositoryProvider.notifier)
        .setUpAccount(token, expiration);

    if (account == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const ConfirmationDialog(
            title: 'Failed to connect account',
          ),
        );
      }

      return;
    }

    ref.read(persistenceProvider.notifier).addAccount(account);
    _loading = false;
  }

  Future<void> _triggerAccountSetup() async {
    setState(() => _loading = true);

    final ok = await SnackBarExtension.launch(
      context,
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token',
    );
    if (!ok) setState(() => _loading = false);
  }

  void _selectAccount(int index) {
    ref.read(persistenceProvider.notifier).switchAccount(index);
    context.go(Routes.home());
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
            const SizedBox(height: Theming.offset),
            Center(
              child: TextButton(
                child: const Text('Cancel'),
                onPressed: () => setState(() => _loading = false),
              ),
            ),
          ],
        ),
      );
    }

    final accounts = Persistence().accounts;
    return Scaffold(
      body: ConstrainedView(
        child: ListView.builder(
          padding: MediaQuery.paddingOf(context).add(
            const EdgeInsets.symmetric(vertical: 20),
          ),
          reverse: true,
          itemExtent: 90,
          itemCount: accounts.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Card(
                margin: const EdgeInsets.only(top: Theming.offset),
                child: ListTile(
                  contentPadding: Theming.paddingAll,
                  title: const Text('Add an account'),
                  subtitle: const Text(
                    'To add more accounts, you must be logged out in the browser.',
                  ),
                  onTap: _triggerAccountSetup,
                ),
              );
            }

            i--;
            return Card(
              margin: const EdgeInsets.only(top: Theming.offset),
              child: InkWell(
                borderRadius: Theming.borderRadiusSmall,
                onTap: () {
                  if (DateTime.now().compareTo(accounts[i].expiration) < 0) {
                    _selectAccount(i);
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Session expired',
                      content: 'Please remove the account and add it again.',
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Theming.radiusSmall,
                      ),
                      child: CachedImage(accounts[i].avatarUrl, width: 70),
                    ),
                    const SizedBox(width: Theming.offset),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${accounts[i].name} ${accounts[i].id}'),
                        Text(
                          DateTime.now().compareTo(accounts[i].expiration) < 0
                              ? 'Expires in ${accounts[i].expiration.timeUntil}'
                              : 'Expired',
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove Account',
                      icon: const Icon(Ionicons.close_circle_outline),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Remove Account?',
                          mainAction: 'Yes',
                          secondaryAction: 'No',
                          onConfirm: () => ref
                              .read(persistenceProvider.notifier)
                              .removeAccount(i)
                              .then((_) => setState(() {})),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
