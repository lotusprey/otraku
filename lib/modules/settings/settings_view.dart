import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/modules/settings/settings_app_tab.dart';
import 'package:otraku/modules/settings/settings_content_tab.dart';
import 'package:otraku/modules/settings/settings_notifications_tab.dart';
import 'package:otraku/modules/settings/settings_about_tab.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/direct_page_view.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late var _settings = ref.read(settingsProvider).whenData((v) => v.copy());
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

    ref.listen<Settings?>(
      settingsProvider.select((s) => s.valueOrNull),
      (prev, next) {
        if (next == null) return;
        final id = Options().id!;

        if (mounted) setState(() => _settings = AsyncValue.data(next.copy()));

        if (prev?.scoreFormat != next.scoreFormat ||
            prev?.titleLanguage != next.titleLanguage) {
          ref.invalidate(collectionProvider(CollectionTag(id, true)));
          ref.invalidate(collectionProvider(CollectionTag(id, false)));
        } else if (prev?.splitCompletedAnime != next.splitCompletedAnime) {
          ref.invalidate(collectionProvider(CollectionTag(id, true)));
        } else if (prev?.splitCompletedManga != next.splitCompletedManga) {
          ref.invalidate(collectionProvider(CollectionTag(id, false)));
        }
      },
    );

    const loadWidget = Center(child: Loader());
    const errorWidget = Center(child: Text('Failed to load settings'));

    final tabs = [
      ConstrainedView(child: SettingsAppTab(_ctrl)),
      if (_settings.hasError) ...[
        errorWidget,
        errorWidget,
      ] else if (_settings.hasValue) ...[
        ConstrainedView(
          child: SettingsContentTab(
            _ctrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
        ConstrainedView(
          child: SettingsNotificationsTab(
            _ctrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
      ] else ...[
        loadWidget,
        loadWidget,
      ],
      ConstrainedView(child: SettingsAboutTab(_ctrl)),
    ];

    return WillPopScope(
      onWillPop: () {
        if (_shouldUpdate) {
          ref.read(settingsProvider.notifier).update(_settings.value!);
        }
        return Future.value(true);
      },
      child: PageScaffold(
        bottomBar: BottomNavBar(
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
        child: TabScaffold(
          topBar: TopBar(title: pageNames[_tabIndex]),
          child: DirectPageView(
            current: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
            children: tabs,
          ),
        ),
      ),
    );
  }
}
