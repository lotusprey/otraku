import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/input/pill_selector.dart';

class AccountPicker extends StatefulWidget {
  const AccountPicker();

  @override
  State<AccountPicker> createState() => _AccountPickerState();
}

class _AccountPickerState extends State<AccountPicker> {
  static const _loginLink =
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token';

  static const _imageSize = 55.0;

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 40, child: VerticalDivider(width: 10, thickness: 1));

    final l10n = AppLocalizations.of(context)!;
    final bodyMediumTextHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final labelSmallTextHeight = context.lineHeight(TextTheme.of(context).labelSmall!);
    final rowHeight = max(_imageSize, bodyMediumTextHeight + labelSmallTextHeight * 2) + 10;

    return Dialog(
      insetPadding: const .symmetric(vertical: 24, horizontal: Theming.offset),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.all(Radius.circular(32)),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final accountGroup = ref.watch(persistenceProvider.select((s) => s.accountGroup));
          final accounts = accountGroup.accounts;

          final items = <Widget>[
            for (int i = 0; i < accounts.length; i++)
              SizedBox(
                height: rowHeight,
                child: Row(
                  children: [
                    Padding(
                      padding: .all(5),
                      child: CachedImage(
                        accounts[i].avatarUrl,
                        width: _imageSize,
                        height: _imageSize,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            '${accounts[i].name} ${accounts[i].id}',
                            overflow: .ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            DateTime.now().isBefore(accounts[i].expiration)
                                ? l10n.accountExpiresIn(accounts[i].expiration.timeUntil)
                                : l10n.accountExpired,
                            style: TextTheme.of(context).labelSmall,
                            overflow: .ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    divider,
                    IconButton(
                      tooltip: l10n.accountRemove,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => ConfirmationDialog.show(
                        context,
                        title: l10n.accountRemoveQuestion,
                        primaryAction: l10n.actionYes,
                        secondaryAction: l10n.actionNo,
                        onConfirm: () {
                          if (i == accountGroup.accountIndex) {
                            ref.read(persistenceProvider.notifier).switchAccount(null);
                          }

                          ref
                              .read(persistenceProvider.notifier)
                              .removeAccount(i)
                              .then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ];

          items.add(
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  const Padding(
                    padding: .all(5),
                    child: Icon(Icons.person_rounded, size: _imageSize),
                  ),
                  Expanded(child: Text(l10n.accountGuest)),
                  divider,
                  IconButton(
                    tooltip: l10n.accountAdd,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => _addAccount(l10n, accounts.isEmpty),
                  ),
                ],
              ),
            ),
          );

          return PillSelector(
            maxWidth: 380,
            shrinkWrap: true,
            selected: accountGroup.accountIndex ?? accounts.length,
            items: items,
            onTap: (i) async {
              if (i == accounts.length) {
                ref.read(persistenceProvider.notifier).switchAccount(null);
                Navigator.pop(context);
                return;
              }

              if (DateTime.now().isBefore(accounts[i].expiration)) {
                ref.read(persistenceProvider.notifier).switchAccount(i);
                Navigator.pop(context);
                return;
              }

              var ok = false;
              await ConfirmationDialog.show(
                context,
                title: l10n.accountSessionExpired,
                content: l10n.accountLogInAgainQuestion,
                primaryAction: l10n.actionYes,
                secondaryAction: l10n.actionNo,
                onConfirm: () => ok = true,
              );

              if (ok) _addAccount(l10n, accounts.isEmpty);
            },
          );
        },
      ),
    );
  }

  void _addAccount(AppLocalizations l10n, bool isAccountListEmpty) {
    if (isAccountListEmpty) {
      SnackBarExtension.launch(context, _loginLink);
      return;
    }

    ConfirmationDialog.show(
      context,
      title: l10n.accountAdd,
      content: l10n.accountAddWarning,
      primaryAction: l10n.actionOk,
      secondaryAction: l10n.actionGoBack,
      onConfirm: () {
        if (mounted) {
          SnackBarExtension.launch(context, _loginLink);
        }
      },
    );
  }
}
