import 'package:flutter/material.dart';
import 'package:otraku/feature/auth/account_picker.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/widget/dialogs.dart';

class LoginInstructions extends StatelessWidget {
  const LoginInstructions();

  static Future<void> dialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConfirmationDialog.show(
      context,
      title: l10n.accountLoginRequired,
      content: l10n.accountLoginInstructions,
      primaryAction: l10n.accountLogIn,
      secondaryAction: l10n.actionGoBack,
      onConfirm: () => showDialog(context: context, builder: (context) => const AccountPicker()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.accountLoginInstructions),
        ElevatedButton(
          onPressed: () =>
              showDialog(context: context, builder: (context) => const AccountPicker()),
          child: Text(l10n.accountLogIn),
        ),
      ],
    );
  }
}
