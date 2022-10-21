import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/settings/settings_app_tab.dart';
import 'package:otraku/settings/settings_content_tab.dart';
import 'package:otraku/settings/settings_notifications_tab.dart';
import 'package:otraku/settings/settings_about_tab.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late final _settings = ref.read(settingsProvider).copy();
  final _ctrl = ScrollController();
  bool _shouldUpdate = false;
  int _tabIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pageNames = ['App', 'Content', 'Notifications', 'About'];

    ref.listen<Settings>(settingsProvider, (prev, next) {
      final id = Options().id!;

      if (prev?.scoreFormat != next.scoreFormat ||
          prev?.titleLanguage != next.titleLanguage) {
        ref.invalidate(collectionProvider(CollectionTag(id, true)));
        ref.invalidate(collectionProvider(CollectionTag(id, false)));
      } else if (prev?.splitCompletedAnime != next.splitCompletedAnime) {
        ref.invalidate(collectionProvider(CollectionTag(id, true)));
      } else if (prev?.splitCompletedManga != next.splitCompletedManga) {
        ref.invalidate(collectionProvider(CollectionTag(id, false)));
      }
    });

    final tabs = [
      SettingsAppTab(_ctrl),
      SettingsContentTab(_ctrl, _settings, () => _shouldUpdate = true),
      SettingsNotificationsTab(_ctrl, _settings, () => _shouldUpdate = true),
      SettingsAboutTab(_ctrl),
    ];

    return WillPopScope(
      onWillPop: () {
        if (_shouldUpdate) {
          ref.read(settingsProvider.notifier).update(_settings);
        }
        return Future.value(true);
      },
      child: PageLayout(
        topBar: TopBar(title: pageNames[_tabIndex]),
        bottomBar: BottomBarIconTabs(
          current: _tabIndex,
          onSame: (_) => _ctrl.scrollToTop(),
          onChanged: (i) => setState(() => _tabIndex = i),
          items: const {
            'App': Ionicons.color_palette_outline,
            'Content': Ionicons.tv_outline,
            'Notifications': Ionicons.notifications_outline,
            'About': Ionicons.information_outline,
          },
        ),
        child: DirectPageView(
          current: _tabIndex,
          onChanged: (i) => setState(() => _tabIndex = i),
          children: tabs,
        ),
      ),
    );
  }
}
