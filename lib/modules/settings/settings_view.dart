import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/settings/settings_provider.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/modules/settings/settings_app_tab.dart';
import 'package:otraku/modules/settings/settings_content_tab.dart';
import 'package:otraku/modules/settings/settings_notifications_tab.dart';
import 'package:otraku/modules/settings/settings_about_tab.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 4, vsync: this);
  final _scrollCtrl = ScrollController();

  late var _settings =
      ref.read(settingsProvider).whenData((data) => data.copy());
  late final _updateCallback = ref.read(settingsProvider.notifier).updateWith;
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  /// Cannot access [ref] in [dispose] and directly reading the provider here
  /// caused warnings, so I'm using a callback in [deactivate].
  /// The proper solution would be to use a [PopScore] widget or similar, but
  /// currently it doesn't work with Go router.
  @override
  void deactivate() {
    if (_shouldUpdate && _settings.hasValue) {
      _shouldUpdate = false;
      _updateCallback(_settings.value!);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsProvider,
      (_, next) => _settings = next.whenData((data) => data.copy()),
    );

    const pageNames = ['App', 'Content', 'Notifications', 'About'];
    const loadWidget = Center(child: Loader());
    const errorWidget = Center(child: Text('Failed to load settings'));

    final tabs = [
      ConstrainedView(
        padding: EdgeInsets.zero,
        child: SettingsAppTab(_scrollCtrl),
      ),
      if (_settings.hasValue) ...[
        ConstrainedView(
          padding: EdgeInsets.zero,
          child: SettingsContentTab(
            _scrollCtrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
        ConstrainedView(
          padding: EdgeInsets.zero,
          child: SettingsNotificationsTab(
            _scrollCtrl,
            _settings.value!,
            () => _shouldUpdate = true,
          ),
        ),
      ] else if (_settings.hasError) ...[
        errorWidget,
        errorWidget,
      ] else ...[
        loadWidget,
        loadWidget,
      ],
      ConstrainedView(
        padding: EdgeInsets.zero,
        child: SettingsAboutTab(_scrollCtrl),
      ),
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
