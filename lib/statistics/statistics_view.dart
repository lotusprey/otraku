import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/statistics/user_statistics.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/user/user_providers.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/statistics/charts.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView(this.id);

  final int id;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final _ctrl = ScrollController();
  bool _onAnime = true;

  int _primaryBarChartTab = 0; // 0-1
  int _secondaryBarChartTab = 0; // 0-2

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<User>>(
          userProvider(widget.id),
          (_, s) => s.whenOrNull(
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Could not load statistics',
                content: error.toString(),
              ),
            ),
          ),
        );

        return ref.watch(userProvider(widget.id)).maybeWhen(
              orElse: () => const Center(child: Text('No statistics')),
              loading: () => const Center(child: Loader()),
              data: (data) {
                return DirectPageView(
                  current: _onAnime ? 0 : 1,
                  onChanged: (i) =>
                      setState(() => _onAnime = i > 0 ? false : true),
                  children: [
                    _StatisticsView(
                      statistics: data.animeStats,
                      ofAnime: true,
                      scrollCtrl: _ctrl,
                      primaryBarChartTab: () => _primaryBarChartTab,
                      secondaryBarChartTab: () => _secondaryBarChartTab,
                      onPrimaryTabChanged: (i) => _primaryBarChartTab = i,
                      onSecondaryTabChanged: (i) => _secondaryBarChartTab = i,
                    ),
                    _StatisticsView(
                      statistics: data.mangaStats,
                      ofAnime: false,
                      scrollCtrl: _ctrl,
                      primaryBarChartTab: () => _primaryBarChartTab,
                      secondaryBarChartTab: () => _secondaryBarChartTab,
                      onPrimaryTabChanged: (i) => _primaryBarChartTab = i,
                      onSecondaryTabChanged: (i) => _secondaryBarChartTab = i,
                    ),
                  ],
                );
              },
            );
      },
    );

    return PageLayout(
      bottomBar: BottomBarIconTabs(
        current: _onAnime ? 0 : 1,
        onChanged: (page) =>
            setState(() => _onAnime = page == 0 ? true : false),
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Anime': Ionicons.film_outline,
          'Manga': Ionicons.bookmark_outline,
        },
      ),
      topBar: TopBar(
        title: _onAnime ? 'Anime Statistics' : 'Manga Statistics',
      ),
      child: content,
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
  });

  final UserStatistics statistics;
  final bool ofAnime;
  final ScrollController scrollCtrl;
  final int Function() primaryBarChartTab;
  final int Function() secondaryBarChartTab;
  final void Function(int) onPrimaryTabChanged;
  final void Function(int) onSecondaryTabChanged;

  @override
  Widget build(BuildContext context) {
    final pageLayout = PageLayout.of(context);

    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.only(
        top: pageLayout.topOffset + 10,
        bottom: pageLayout.bottomOffset,
      ),
      children: [
        _Details(statistics, ofAnime),
        if (statistics.scores.isNotEmpty)
          _BarChart(
            title: 'Score',
            statistics: statistics.scores,
            ofAnime: ofAnime,
            full: false,
            initialTab: primaryBarChartTab(),
            onTabChanged: onPrimaryTabChanged,
            barWidth: 40,
          ),
        if (statistics.lengths.isNotEmpty)
          _BarChart(
            title: ofAnime ? 'Episodes' : 'Chapters',
            statistics: statistics.lengths,
            ofAnime: ofAnime,
            full: true,
            initialTab: secondaryBarChartTab(),
            onTabChanged: onSecondaryTabChanged,
            barWidth: 50,
          ),
        if (statistics.count > 0)
          GridView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 340,
              height: 250,
            ),
            children: [
              _PieChart('Format Distribution', statistics.formats),
              _PieChart('Status Distribution', statistics.statuses),
              _PieChart('Country Distribution', statistics.countries),
            ],
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  _Details(UserStatistics statistics, bool ofAnime) {
    subtitles.add(statistics.count);
    subtitles.add(statistics.partsConsumed);
    if (ofAnime) {
      subtitles.add(((statistics.amountConsumed / 1440) * 10).round() / 10);
      icons.add(Ionicons.tv_outline);
      icons.add(Ionicons.play_outline);
      icons.add(Ionicons.calendar_clear_outline);
      titles.add('Total Anime');
      titles.add('Episodes Watched');
      titles.add('Days Watched');
    } else {
      subtitles.add(statistics.amountConsumed);
      icons.add(Ionicons.bookmarks_outline);
      icons.add(Ionicons.reader_outline);
      icons.add(Ionicons.book_outline);
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: titles.length,
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: 50,
      ),
      itemBuilder: (context, i) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icons[i],
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titles[i], style: Theme.of(context).textTheme.subtitle1),
                  Text(subtitles[i].toString()),
                ],
              ),
            ],
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
    required this.barWidth,
    required this.onTabChanged,
  });

  final List<AmountStatistics> statistics;
  final String title;
  final int initialTab;
  final bool ofAnime;
  final bool full;
  final double barWidth;
  final void Function(int) onTabChanged;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

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

    return BarChart(
      title: widget.title,
      action: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CompactSegmentSwitcher(
          items: [
            'Titles',
            widget.ofAnime ? 'Hours' : 'Chapters',
            if (widget.full) 'Mean Score',
          ],
          current: _tab,
          onChanged: (val) {
            setState(() => _tab = val);
            widget.onTabChanged(val);
          },
        ),
      ),
      names: widget.statistics.map((s) => s.type).toList(),
      values: values,
      barWidth: widget.barWidth,
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart(this.title, this.stats);

  final String title;
  final List<TypeStatistics> stats;

  @override
  Widget build(BuildContext context) {
    final names = stats.map((s) => s.value).toList();
    final values = stats.map((s) => s.count).toList();
    return PieChart(title: title, names: names, values: values);
  }
}
