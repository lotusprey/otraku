import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/auth/login_instructions.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/settings/settings_app_view.dart';
import 'package:otraku/feature/settings/settings_content_view.dart';
import 'package:otraku/feature/settings/settings_notifications_view.dart';
import 'package:otraku/feature/settings/settings_about_view.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 4, vsync: this);
  final _scrollCtrl = ScrollController();
  AsyncValue<Settings>? _settings;

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewerId = ref.watch(viewerIdProvider);
    if (viewerId == null) {
      _settings = null;
    } else {
      _settings ??= ref.watch(settingsProvider).whenData((data) => data.copy());

      ref.listen(
        settingsProvider,
        (_, s) => s.whenOrNull(
          loading: () => _settings = const AsyncValue.loading(),
          data: (data) => _settings = AsyncValue.data(data.copy()),
          error: (error, _) => SnackBarExtension.show(context, error.toString()),
        ),
      );
    }

    final highContrast = ref.watch(persistenceProvider.select((s) => s.options.highContrast));

    final tabs = [
      ConstrainedView(padded: false, child: SettingsAppSubview(_scrollCtrl)),
      switch (_settings) {
        null => Center(
          child: Padding(padding: Theming.paddingAll, child: const LoginInstructions()),
        ),
        AsyncData(:final value) => SettingsContentSubview(_scrollCtrl, value, highContrast),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: Theming.paddingAll,
            child: Text('${l10n.errorFailedLoading}: ${error.toString()}'),
          ),
        ),
        AsyncLoading() => const Center(child: Loader()),
      },
      switch (_settings) {
        null => Center(
          child: Padding(padding: Theming.paddingAll, child: const LoginInstructions()),
        ),
        AsyncData(:final value) => SettingsNotificationsSubview(_scrollCtrl, value),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: Theming.paddingAll,
            child: Text('${l10n.errorFailedLoading}: ${error.toString()}'),
          ),
        ),
        AsyncLoading() => const Center(child: Loader()),
      },
      ConstrainedView(padded: false, child: SettingsAboutSubview(_scrollCtrl)),
    ];

    final floatingAction = switch (_settings) {
      AsyncData(:final value) => HidingFloatingActionButton(
        key: const Key('save'),
        scrollCtrl: _scrollCtrl,
        child: _SaveButton(l10n, () => ref.read(settingsProvider.notifier).updateSettings(value)),
      ),
      _ => null,
    };

    return AdaptiveScaffold(
      topBar: TopBarAnimatedSwitcher(switch (_tabCtrl.index) {
        0 => TopBar(key: const Key('0'), title: l10n.settingsTabApp),
        1 => TopBar(key: const Key('1'), title: l10n.settingsTabContent),
        2 => TopBar(key: const Key('2'), title: l10n.notifications),
        _ => TopBar(key: const Key('3'), title: l10n.settingsTabAbout),
      }),
      floatingAction: floatingAction,
      navigationConfig: NavigationConfig(
        selected: _tabCtrl.index,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        onChanged: (i) => _tabCtrl.index = i,
        items: {
          l10n.settingsTabApp: Ionicons.color_palette_outline,
          l10n.settingsTabContent: Ionicons.tv_outline,
          l10n.notifications: Ionicons.notifications_outline,
          l10n.settingsTabAbout: Ionicons.information_outline,
        },
      ),
      child: TabBarView(controller: _tabCtrl, children: tabs),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton(this.l10n, this.onTap) : super(key: const Key('saveSettings'));

  final AppLocalizations l10n;
  final Future<void> Function() onTap;

  @override
  State<_SaveButton> createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {
  var _hidden = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: widget.l10n.actionSave,
      onPressed: _hidden
          ? null
          : () async {
              setState(() => _hidden = true);
              await widget.onTap();
              setState(() => _hidden = false);
            },
      child: _hidden ? const Icon(Ionicons.time_outline) : const Icon(Ionicons.save_outline),
    );
  }
}
