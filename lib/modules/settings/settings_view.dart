import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_preview_provider.dart';
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
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';

/// FIX: PopScope was not working properly with Go router. For that reason,
/// updating the settings when the page is popped is handled very awkwardly.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 4, vsync: this);
  final _scrollCtrl = ScrollController();

  late ProviderSubscription<AsyncValue<Settings>> _subscription;
  var _settings = const AsyncValue<Settings>.loading();
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
    _initProviderSubscription();
  }

  /// Since we touch [deactivate], we should also handle reactivation
  /// (unlikely to occur).
  @override
  void activate() {
    super.activate();
    _initProviderSubscription();
  }

  /// Modified settings are updated only after the user pops the page.
  /// This is not done in [dispose], because [ref] cannot be utilized there.
  /// We have to manually close our provider subscription
  /// before updating the state or a rebuild will be caused for the page,
  /// that is about to be disposed.
  @override
  void deactivate() {
    _subscription.close();
    if (_shouldUpdate && _settings.hasValue) {
      _shouldUpdate = false;
      final prev = ref.read(settingsProvider.notifier).value;
      final next = _settings.value!;
      ref.read(settingsProvider.notifier).update(_settings.value!);

      // Some setting changes may require a reload of an anime/manga collection.
      final id = Options().id!;
      bool invalidateAnimeCollection = false;
      bool invalidateMangaCollection = false;

      if (prev.scoreFormat != next.scoreFormat ||
          prev.titleLanguage != next.titleLanguage) {
        invalidateAnimeCollection = true;
        invalidateMangaCollection = true;
      } else {
        if (prev.splitCompletedAnime != next.splitCompletedAnime) {
          invalidateAnimeCollection = true;
        }
        if (prev.splitCompletedManga != next.splitCompletedManga) {
          invalidateMangaCollection = true;
        }
      }

      if (invalidateAnimeCollection) {
        final tag = (userId: id, ofAnime: true);
        if (ref.exists(collectionProvider(tag))) {
          ref.invalidate(collectionProvider(tag));
        } else {
          ref.invalidate(collectionPreviewProvider(tag));
        }
      }

      if (invalidateMangaCollection) {
        final tag = (userId: id, ofAnime: false);
        if (ref.exists(collectionProvider(tag))) {
          ref.invalidate(collectionProvider(tag));
        } else {
          ref.invalidate(collectionPreviewProvider(tag));
        }
      }
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// We need to listen for changes, since the settings page
  /// can technically be opened before the settings have loaded.
  void _initProviderSubscription() {
    _subscription = ref.listenManual(
      settingsProvider,
      (_, next) => setState(
        () => _updateSettings(next),
      ),
    );
    _updateSettings(_subscription.read());
  }

  void _updateSettings(AsyncValue<Settings> other) =>
      _settings = other.hasValue ? AsyncValue.data(other.value!.copy()) : other;

  @override
  Widget build(BuildContext context) {
    const pageNames = ['App', 'Content', 'Notifications', 'About'];

    const loadWidget = Center(child: Loader());
    const errorWidget = Center(child: Text('Failed to load settings'));

    final tabs = [
      ConstrainedView(child: SettingsAppTab(_scrollCtrl)),
      if (_settings.hasError) ...[
        errorWidget,
        errorWidget,
      ] else if (_settings.hasValue) ...[
        ConstrainedView(
          child: SettingsContentTab(
            _scrollCtrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
        ConstrainedView(
          child: SettingsNotificationsTab(
            _scrollCtrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
      ] else ...[
        loadWidget,
        loadWidget,
      ],
      ConstrainedView(child: SettingsAboutTab(_scrollCtrl)),
    ];

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        onChanged: (i) => _tabCtrl.index = i,
        items: const {
          'App': Ionicons.color_palette_outline,
          'Content': Ionicons.tv_outline,
          'Notifications': Ionicons.notifications_outline,
          'About': Ionicons.information_outline,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(title: pageNames[_tabCtrl.index]),
        child: TabBarView(controller: _tabCtrl, children: tabs),
      ),
    );
  }
}
