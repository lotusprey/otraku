import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/feature/statistics/statistics_model.dart';
import 'package:otraku/feature/user/user_model.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/feature/statistics/charts.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/loaders.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView(this.id);

  final int id;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> with SingleTickerProviderStateMixin {
  late final tag = idUserTag(widget.id);
  late final _tabCtrl = TabController(length: 2, vsync: this);
  final _scrollCtrl = ScrollController();

  int _primaryBarChartTab = 0;
  int _secondaryBarChartTab = 0;

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
    final child = Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<User>>(
          userProvider(tag),
          (_, s) =>
              s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
        );

        final options = ref.watch(persistenceProvider.select((s) => s.options));

        return ref
            .watch(userProvider(tag))
            .when(
              loading: () => const Center(child: Loader()),
              error: (err, _) => Center(child: Text(l10n.errorFailedLoading(err.toString()))),
              data: (data) {
                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    ConstrainedView(
                      child: _StatisticsView(
                        statistics: data.animeStats,
                        ofAnime: true,
                        scrollCtrl: _scrollCtrl,
                        primaryBarChartTab: () => _primaryBarChartTab,
                        secondaryBarChartTab: () => _secondaryBarChartTab,
                        onPrimaryTabChanged: (i) => _primaryBarChartTab = i,
                        onSecondaryTabChanged: (i) => _secondaryBarChartTab = i,
                        highContrast: options.highContrast,
                      ),
                    ),
                    ConstrainedView(
                      child: _StatisticsView(
                        statistics: data.mangaStats,
                        ofAnime: false,
                        scrollCtrl: _scrollCtrl,
                        primaryBarChartTab: () => _primaryBarChartTab,
                        secondaryBarChartTab: () => _secondaryBarChartTab,
                        onPrimaryTabChanged: (i) => _primaryBarChartTab = i,
                        onSecondaryTabChanged: (i) => _secondaryBarChartTab = i,
                        highContrast: options.highContrast,
                      ),
                    ),
                  ],
                );
              },
            );
      },
    );

    return AdaptiveScaffold(
      topBar: _tabCtrl.index == 0
          ? TopBar(key: const Key('0'), title: l10n.statisticsAnime)
          : TopBar(key: const Key('1'), title: l10n.statisticsManga),
      navigationConfig: NavigationConfig(
        selected: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: {
          l10n.mediaTypeAnime: Ionicons.film_outline,
          l10n.mediaTypeManga: Ionicons.book_outline,
        },
      ),
      child: child,
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView({
    required this.statistics,
    required this.ofAnime,
    required this.scrollCtrl,
    required this.primaryBarChartTab,
    required this.secondaryBarChartTab,
    required this.onPrimaryTabChanged,
    required this.onSecondaryTabChanged,
    required this.highContrast,
  });

  final Statistics statistics;
  final bool ofAnime;
  final ScrollController scrollCtrl;
  final int Function() primaryBarChartTab;
  final int Function() secondaryBarChartTab;
  final void Function(int) onPrimaryTabChanged;
  final void Function(int) onSecondaryTabChanged;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));

    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + Theming.offset),
        ),
        _Details(statistics, ofAnime, l10n, highContrast),
        if (statistics.scores.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: l10n.entryScore,
            statistics: statistics.scores,
            ofAnime: ofAnime,
            full: false,
            l10n: l10n,
            initialTab: primaryBarChartTab(),
            onTabChanged: onPrimaryTabChanged,
          ),
        ],
        if (statistics.lengths.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: ofAnime ? l10n.mediaEpisodes : l10n.mediaChapters,
            statistics: statistics.lengths,
            ofAnime: ofAnime,
            full: true,
            l10n: l10n,
            initialTab: secondaryBarChartTab(),
            onTabChanged: onSecondaryTabChanged,
          ),
        ],
        if (statistics.count > 0) ...[
          spacing,
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 340,
              height: 200,
            ),
            delegate: SliverChildListDelegate([
              PieChart(
                title: l10n.statisticsDistributionFormat,
                categories: statistics.formats
                    .map((e) => (e.name.localize(l10n), e.count))
                    .toList(),
                highContrast: highContrast,
              ),
              PieChart(
                title: l10n.statisticsDistributionStatus,
                categories: statistics.statuses
                    .map((e) => (e.name.localize(l10n, ofAnime), e.count))
                    .toList(),
                highContrast: highContrast,
              ),
              PieChart(
                title: l10n.statisticsDistributionCountry,
                categories: statistics.countries
                    .map((e) => (e.name.localize(l10n), e.count))
                    .toList(),
                highContrast: highContrast,
              ),
            ]),
          ),
        ],
        const SliverFooter(),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  _Details(Statistics statistics, bool ofAnime, AppLocalizations l10n, this.highContrast)
    : categories = [
        if (ofAnime) ...[
          (l10n.statisticsTotalAnime, Ionicons.film_outline, statistics.count),
          (l10n.statisticsEpisodesWatched, Ionicons.play_outline, statistics.partsConsumed),
          (
            l10n.statisticsDaysWatched,
            Ionicons.calendar_clear_outline,
            ((statistics.amountConsumed / 1440) * 10).round() / 10,
          ),
        ] else ...[
          (l10n.statisticsTotalManga, Ionicons.book_outline, statistics.count),
          (l10n.statisticsChaptersRead, Ionicons.reader_outline, statistics.partsConsumed),
          (l10n.statisticsVolumesRead, Ionicons.bookmark_outline, statistics.amountConsumed),
        ],
        (l10n.mediaScoreMean, Ionicons.star_half_outline, statistics.meanScore),
        (
          l10n.statisticsStandardDeviation,
          Ionicons.calculator_outline,
          statistics.standardDeviation,
        ),
      ];

  final List<(String, IconData, num)> categories;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final tileHeight = max(bodyMediumLineHeight + labelMediumLineHeight, Theming.iconBig) + 10;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: tileHeight,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: categories.length,
        (context, i) => Tooltip(
          message: categories[i].$1,
          triggerMode: .tap,
          child: CardExtension.highContrast(highContrast)(
            child: Padding(
              padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
              child: Row(
                spacing: Theming.offset,
                children: [
                  Icon(categories[i].$2, size: Theming.iconBig),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            categories[i].$1,
                            style: TextTheme.of(context).labelMedium,
                            overflow: .ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(categories[i].$3.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatefulWidget {
  const _BarChart({
    required this.statistics,
    required this.title,
    required this.initialTab,
    required this.ofAnime,
    required this.full,
    required this.l10n,
    required this.onTabChanged,
  });

  final List<({String name, int count, int amount, double meanScore})> statistics;
  final String title;
  final int initialTab;
  final bool ofAnime;
  final bool full;
  final AppLocalizations l10n;
  final void Function(int) onTabChanged;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final categories = switch (_tab) {
      0 => widget.statistics.map((e) => (e.name, e.count)).toList(),
      1 => widget.statistics.map((e) => (e.name, e.amount)).toList(),
      _ => widget.statistics.map((e) => (e.name, e.meanScore)).toList(),
    };

    return SliverToBoxAdapter(
      child: BarChart(
        title: widget.title,
        toolbar: SegmentedButton(
          segments: [
            ButtonSegment(
              value: 0,
              label: Text(widget.l10n.statisticsTitles),
              icon: const Icon(Icons.numbers_outlined),
            ),
            if (widget.ofAnime)
              ButtonSegment(
                value: 1,
                label: Text(widget.l10n.statisticsHours),
                icon: const Icon(Icons.hourglass_bottom_outlined),
              )
            else
              ButtonSegment(
                value: 1,
                label: Text(widget.l10n.mediaChapters),
                icon: const Icon(Icons.hourglass_bottom_outlined),
              ),
            if (widget.full && widget.statistics.any((s) => s.meanScore > 0))
              ButtonSegment(
                value: 2,
                label: Text(widget.l10n.entryScore),
                icon: const Icon(Icons.star_half_outlined),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
        categories: categories,
      ),
    );
  }
}
