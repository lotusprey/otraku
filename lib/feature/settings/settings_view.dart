import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/feature/settings/settings_model.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/settings/settings_app_view.dart';
import 'package:otraku/feature/settings/settings_content_view.dart';
import 'package:otraku/feature/settings/settings_notifications_view.dart';
import 'package:otraku/feature/settings/settings_about_view.dart';
import 'package:otraku/widget/layouts/bottom_bar.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView();

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView>
    with SingleTickerProviderStateMixin {
  late Settings? _settings = ref.read(settingsProvider).valueOrNull?.copy();
  late final _tabCtrl = TabController(length: 4, vsync: this);
  final _scrollCtrl = ScrollController();

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
    ref.listen(
      settingsProvider,
      (_, s) => s.whenOrNull(
        data: (data) => _settings = data.copy(),
        error: (error, _) => Toast.show(context, error.toString()),
      ),
    );

    final floatingBar = FloatingBar(
      scrollCtrl: _scrollCtrl,
      children: [
        _SaveButton(() {
          if (_settings == null) return Future.value();
          return ref.read(settingsProvider.notifier).updateSettings(_settings!);
        }),
      ],
    );

    final tabs = [
      TabScaffold(
        topBar: const TopBar(title: 'App'),
        child: ConstrainedView(
          padding: EdgeInsets.zero,
          child: SettingsAppSubview(_scrollCtrl),
        ),
      ),
      if (_settings != null) ...[
        TabScaffold(
          topBar: const TopBar(title: 'Content'),
          floatingBar: floatingBar,
          child: ConstrainedView(
            padding: EdgeInsets.zero,
            child: SettingsContentSubview(_scrollCtrl, _settings!),
          ),
        ),
        TabScaffold(
          topBar: const TopBar(title: 'Notifications'),
          floatingBar: floatingBar,
          child: ConstrainedView(
            padding: EdgeInsets.zero,
            child: SettingsNotificationsSubview(_scrollCtrl, _settings!),
          ),
        ),
      ] else ...[
        const SizedBox(),
        const SizedBox(),
      ],
      TabScaffold(
        topBar: const TopBar(title: 'About'),
        child: ConstrainedView(
          padding: EdgeInsets.zero,
          child: SettingsAboutSubview(_scrollCtrl),
        ),
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
      child: TabBarView(controller: _tabCtrl, children: tabs),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton(this.onTap);

  final Future<void> Function() onTap;

  @override
  State<_SaveButton> createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox();

    return ActionButton(
      tooltip: 'Save Settings',
      icon: Ionicons.save_outline,
      onTap: () async {
        setState(() => _hidden = true);
        await widget.onTap();
        setState(() => _hidden = false);
      },
    );
  }
}
