import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class SettingsAboutSubview extends StatelessWidget {
  const SettingsAboutSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer(
      builder: (context, ref, _) {
        final padding = MediaQuery.paddingOf(context);
        final persistence = ref.watch(persistenceProvider);
        final lastBackgroundJob = persistence.appMeta.lastBackgroundJob;
        final lastJobTimestamp = lastBackgroundJob?.formattedDateTimeFromSeconds(
          persistence.options.analogClock,
        );

        return Align(
          alignment: .center,
          child: ListView(
            controller: scrollCtrl,
            padding: .only(
              top: padding.top + Theming.offset,
              bottom: padding.bottom + Theming.offset,
            ),
            children: [
              Image.asset(
                'assets/icons/about.png',
                color: ColorScheme.of(context).primary,
                width: 180,
                height: 180,
              ),
              Padding(
                padding: const .symmetric(vertical: 5),
                child: Text(
                  '${l10n.appName} - v.$appVersion',
                  textAlign: .center,
                  style: TextTheme.of(context).bodyMedium,
                ),
              ),
              Text(l10n.settingsAboutDisclaimer, textAlign: .center),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Ionicons.logo_discord),
                title: Text(l10n.settingsAboutDiscord),
                onTap: () => SnackBarExtension.launch(context, 'https://discord.gg/YN2QWVbFef'),
              ),
              ListTile(
                leading: const Icon(Ionicons.logo_github),
                title: Text(l10n.settingsAboutSourceCode),
                onTap: () =>
                    SnackBarExtension.launch(context, 'https://github.com/lotusprey/otraku'),
              ),
              ListTile(
                leading: const Icon(Ionicons.cash_outline),
                title: Text(l10n.settingsAboutDonate),
                onTap: () => SnackBarExtension.launch(context, 'https://ko-fi.com/lotusgate'),
              ),
              ListTile(
                leading: const Icon(Ionicons.finger_print),
                title: Text(l10n.settingsAboutPrivacyPolicy),
                onTap: () => SnackBarExtension.launch(
                  context,
                  'https://sites.google.com/view/otraku/privacy-policy',
                ),
              ),
              ListTile(
                leading: const Icon(Ionicons.trash_bin_outline),
                title: Text(l10n.settingsAboutClearImageCache),
                onTap: clearImageCache,
              ),
              ListTile(
                leading: Icon(Ionicons.refresh_outline),
                title: Text(l10n.settingsAboutResetOptions),
                onTap: () => ref.read(persistenceProvider.notifier).setOptions(.empty()),
              ),
              if (lastJobTimestamp != null) ...[
                Padding(
                  padding: const .only(left: Theming.offset, right: Theming.offset, top: 20),
                  child: Text(
                    l10n.settingsAboutLastNotificationCheck(lastJobTimestamp),
                    style: TextTheme.of(context).labelMedium,
                    textAlign: .center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
