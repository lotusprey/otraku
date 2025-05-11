import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class SettingsAboutSubview extends StatelessWidget {
  const SettingsAboutSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final padding = MediaQuery.paddingOf(context);
        final persistence = ref.watch(persistenceProvider);
        final lastBackgroundJob = persistence.appMeta.lastBackgroundJob;
        final lastJobTimestamp =
            lastBackgroundJob?.formattedDateTimeFromSeconds(
          persistence.options.analogClock,
        );

        return Align(
          alignment: Alignment.center,
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.only(
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
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'Otraku - v.$appVersion',
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
              const Text(
                'An unofficial AniList app',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Ionicons.logo_discord),
                title: const Text('Discord'),
                onTap: () => SnackBarExtension.launch(
                    context, 'https://discord.gg/YN2QWVbFef'),
              ),
              ListTile(
                leading: const Icon(Ionicons.logo_github),
                title: const Text('Source Code'),
                onTap: () => SnackBarExtension.launch(
                    context, 'https://github.com/lotusprey/otraku'),
              ),
              ListTile(
                leading: const Icon(Ionicons.cash_outline),
                title: const Text('Donate'),
                onTap: () => SnackBarExtension.launch(
                    context, 'https://ko-fi.com/lotusgate'),
              ),
              ListTile(
                leading: const Icon(Ionicons.finger_print),
                title: const Text('Privacy Policy'),
                onTap: () => SnackBarExtension.launch(
                  context,
                  'https://sites.google.com/view/otraku/privacy-policy',
                ),
              ),
              const ListTile(
                leading: Icon(Ionicons.trash_bin_outline),
                title: Text('Clear Image Cache'),
                onTap: clearImageCache,
              ),
              ListTile(
                leading: Icon(Ionicons.refresh_outline),
                title: Text('Reset Options'),
                onTap: () => ref
                    .read(persistenceProvider.notifier)
                    .setOptions(Options.empty()),
              ),
              if (lastJobTimestamp != null) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: Theming.offset,
                    right: Theming.offset,
                    top: 20,
                  ),
                  child: Text(
                    'Performed a notification check around $lastJobTimestamp.',
                    textAlign: TextAlign.center,
                    style: TextTheme.of(context).labelMedium,
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
