import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
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
    await Api.addAccount(token, expiration);
    setState(() => _loading = false);
  }

  Future<void> _triggerAccountSetup() async {
    setState(() => _loading = true);
    final ok = await Toast.launch(
      context,
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token',
    );
    if (!ok) setState(() => _loading = false);
  }

  void _selectAccount(int index) async {
    if (await Api.selectAccount(index) && mounted) {
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

    final accounts = Options().accounts;
    return Scaffold(
      body: ConstrainedView(
        child: ListView.builder(
          padding: MediaQuery.of(context)
              .padding
              .add(const EdgeInsets.symmetric(vertical: 20)),
          reverse: true,
          itemExtent: 90,
          itemCount: accounts.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Card(
                margin: const EdgeInsets.only(top: 10),
                child: ListTile(
                  contentPadding: Consts.padding,
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
              margin: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {
                  if (DateTime.now().compareTo(accounts[i].expiration) < 0) {
                    _selectAccount(i);
                    return;
                  }

                  showPopUp(
                    context,
                    const ConfirmationDialog(
                      title: 'Session expired',
                      content: 'Please remove the account and add it again.',
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Consts.radiusMin,
                      ),
                      child: CachedImage(accounts[i].avatarUrl, width: 70),
                    ),
                    const SizedBox(width: 10),
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
                    TopBarIcon(
                      icon: Ionicons.close_circle_outline,
                      tooltip: 'Remove Account',
                      onTap: () => showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Remove Account?',
                          mainAction: 'Yes',
                          secondaryAction: 'No',
                          onConfirm: () =>
                              Api.removeAccount(i).then((_) => setState(() {})),
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
