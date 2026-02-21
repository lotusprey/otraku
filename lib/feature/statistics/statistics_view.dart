import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/feature/statistics/statistics_model.dart';
import 'package:otraku/feature/user/user_model.dart';
import 'package:otraku/feature/user/user_providers.dart';
import 'package:otraku/feature/statistics/charts.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
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
              error: (_, _) => const Center(child: Text('Failed to load statistics')),
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
          ? const TopBar(key: Key('0'), title: 'Anime Statistics')
          : const TopBar(key: Key('1'), title: 'Manga Statistics'),
      navigationConfig: NavigationConfig(
        selected: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {'Anime': Ionicons.film_outline, 'Manga': Ionicons.book_outline},
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
    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));

    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + Theming.offset),
        ),
        _Details(statistics, ofAnime, highContrast),
        if (statistics.scores.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: 'Score',
            statistics: statistics.scores,
            ofAnime: ofAnime,
            full: false,
            initialTab: primaryBarChartTab(),
            onTabChanged: onPrimaryTabChanged,
          ),
        ],
        if (statistics.lengths.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: ofAnime ? 'Episodes' : 'Chapters',
            statistics: statistics.lengths,
            ofAnime: ofAnime,
            full: true,
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
              _PieChart('Format Distribution', statistics.formats, highContrast),
              _PieChart('Status Distribution', statistics.statuses, highContrast),
              _PieChart('Country Distribution', statistics.countries, highContrast),
            ]),
          ),
        ],
        const SliverFooter(),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  _Details(Statistics statistics, bool ofAnime, this.highContrast) {
    subtitles.add(statistics.count);
    subtitles.add(statistics.partsConsumed);

    if (ofAnime) {
      subtitles.add(((statistics.amountConsumed / 1440) * 10).round() / 10);
      icons.add(Ionicons.film_outline);
      icons.add(Ionicons.play_outline);
      icons.add(Ionicons.calendar_clear_outline);
      titles.add('Total Anime');
      titles.add('Episodes Watched');
      titles.add('Days Watched');
    } else {
      subtitles.add(statistics.amountConsumed);
      icons.add(Ionicons.book_outline);
      icons.add(Ionicons.reader_outline);
      icons.add(Ionicons.bookmark_outline);
      titles.add('Total Manga');
      titles.add('Chapters Read');
      titles.add('Volumes Read');
    }
    icons.add(Ionicons.star_half_outline);
    icons.add(Ionicons.calculator_outline);
    titles.add('Mean Score');
    titles.add('Standard Deviation');
    subtitles.add(statistics.meanScore);
    subtitles.add(statistics.standardDeviation);
  }

  final icons = <IconData>[];
  final titles = <String>[];
  final subtitles = <num>[];
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
        childCount: titles.length,
        (context, i) => Tooltip(
          message: titles[i],
          triggerMode: .tap,
          child: CardExtension.highContrast(highContrast)(
            child: Padding(
              padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
              child: Row(
                spacing: Theming.offset,
                children: [
                  Icon(icons[i], size: Theming.iconBig),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            titles[i],
                            style: TextTheme.of(context).labelMedium,
                            overflow: .ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(subtitles[i].toString()),
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
    required this.onTabChanged,
  });

  final List<AmountStatistics> statistics;
  final String title;
  final int initialTab;
  final bool ofAnime;
  final bool full;
  final void Function(int) onTabChanged;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    late List<num> values;
    if (_tab == 0) {
      values = widget.statistics.map((s) => s.count).toList();
    } else if (_tab == 1) {
      values = widget.statistics.map((s) => s.amount).toList();
    } else {
      values = widget.statistics.map((s) => s.meanScore).toList();
    }

    return SliverToBoxAdapter(
      child: BarChart(
        title: widget.title,
        toolbar: SegmentedButton(
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles'),
              icon: Icon(Icons.numbers_outlined),
            ),
            if (widget.ofAnime)
              const ButtonSegment(
                value: 1,
                label: Text('Hours'),
                icon: Icon(Icons.hourglass_bottom_outlined),
              )
            else
              const ButtonSegment(
                value: 1,
                label: Text('Chapters'),
                icon: Icon(Icons.hourglass_bottom_outlined),
              ),
            if (widget.full && widget.statistics.any((s) => s.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score'),
                icon: Icon(Icons.star_half_outlined),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
        names: widget.statistics.map((s) => s.type).toList(),
        values: values,
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart(this.title, this.stats, this.highContrast);

  final String title;
  final List<TypeStatistics> stats;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final names = stats.map((s) => s.value).toList();
    final values = stats.map((s) => s.count).toList();
    return PieChart(title: title, names: names, values: values, highContrast: highContrast);
  }
}
