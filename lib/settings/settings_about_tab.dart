import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/cached_image.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class SettingsAboutTab extends StatelessWidget {
  const SettingsAboutTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final offsets = scaffoldOffsets(context);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 220,
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: offsets.top + 10,
            bottom: offsets.bottom + 10,
          ),
          children: [
            Image.asset(
              'assets/icons/about.png',
              color: Theme.of(context).colorScheme.primary,
              width: 180,
              height: 180,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Otraku - v.$versionCode',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Text(
              'An unofficial AniList app',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.logo_discord),
              label: const Text('Discord'),
              onPressed: () =>
                  Toast.launch(context, 'https://discord.gg/YN2QWVbFef'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.logo_github),
              label: const Text('Source Code'),
              onPressed: () =>
                  Toast.launch(context, 'https://github.com/lotusgate/otraku'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.cash_outline),
              label: const Text('Donate'),
              onPressed: () =>
                  Toast.launch(context, 'https://ko-fi.com/lotusgate'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.finger_print),
              label: const Text('Privacy Policy'),
              onPressed: () => Toast.launch(
                context,
                'https://sites.google.com/view/otraku/privacy-policy',
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.log_out_outline),
              label: const Text('Accounts'),
              onPressed: Api.logOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.trash_bin_outline),
              label: const Text('Clear Image Cache'),
              onPressed: clearImageCache,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Ionicons.refresh_outline),
              label: const Text('Reset Options'),
              onPressed: Options.resetOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
            const SizedBox(height: 30),
            if (Options().lastBackgroundWork != null)
              _buildBackgroundWorkInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundWorkInfo(BuildContext context) {
    final time = Options().lastBackgroundWork!.millisecondsSinceEpoch;
    return Text(
      'Performed a notification check around ${Convert.millisToStr((time / 1000).truncate())}.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}
