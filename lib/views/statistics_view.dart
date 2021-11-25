import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/statistics_controller.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/widgets/charts.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class StatisticsView extends StatelessWidget {
  final int id;
  StatisticsView(this.id);

  @override
  Widget build(BuildContext context) {
    final keyAnime = UniqueKey();
    final keyManga = UniqueKey();

    return GetBuilder<StatisticsController>(
      id: StatisticsController.ID_MAIN,
      tag: id.toString(),
      builder: (ctrl) {
        return NavLayout(
          onChanged: (page) => ctrl.onAnime = page == 0 ? true : false,
          index: ctrl.onAnime ? 0 : 1,
          appBar: ShadowAppBar(
            title: ctrl.onAnime ? 'Anime Statistics' : 'Manga Statistics',
          ),
          items: const {
            'Anime': Ionicons.film_outline,
            'Manga': Ionicons.bookmark_outline,
          },
          child: ListView(
            key: ctrl.onAnime ? keyAnime : keyManga,
            padding:
                EdgeInsets.only(top: 10, bottom: NavLayout.offset(context)),
            physics: Config.PHYSICS,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Details',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              _Details(ctrl),
              if (ctrl.model.scores.isNotEmpty) ...[
                GetBuilder<StatisticsController>(
                  id: StatisticsController.ID_SCORE,
                  tag: id.toString(),
                  builder: (_) => _BarChart(
                    title: 'Score',
                    tabs: BubbleTabs<int>(
                      items: ctrl.onAnime
                          ? const {'Titles': 0, 'Hours': 1}
                          : const {'Titles': 0, 'Chapters': 1},
                      current: () => ctrl.scoreChartTab,
                      onChanged: (val) => ctrl.scoreChartTab = val,
                      onSame: () {},
                    ),
                    stats: ctrl.model.scores,
                    onAnime: ctrl.onAnime,
                    chartTab: ctrl.scoreChartTab,
                    barWidth: 40,
                  ),
                ),
              ],
              if (ctrl.model.lengths.isNotEmpty) ...[
                GetBuilder<StatisticsController>(
                  id: StatisticsController.ID_LENGTH,
                  tag: id.toString(),
                  builder: (_) => _BarChart(
                    title: ctrl.onAnime ? 'Episodes' : 'Chapters',
                    tabs: BubbleTabs<int>(
                      items: ctrl.onAnime
                          ? const {'Titles': 0, 'Hours': 1, 'Mean Score': 2}
                          : const {'Titles': 0, 'Chapters': 1, 'Mean Score': 2},
                      current: () => ctrl.lengthChartTab,
                      onChanged: (val) => ctrl.lengthChartTab = val,
                      onSame: () {},
                    ),
                    stats: ctrl.model.lengths,
                    onAnime: ctrl.onAnime,
                    chartTab: ctrl.lengthChartTab,
                    barWidth: 65,
                  ),
                ),
              ],
              if (ctrl.model.count > 0)
                GridView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _PieChart('Format Distribution', ctrl.model.formats),
                    _PieChart('Status Distribution', ctrl.model.statuses),
                    _PieChart('Country Distribution', ctrl.model.countries),
                  ],
                  gridDelegate:
                      const SliverGridDelegateWithMinWidthAndFixedHeight(
                    minWidth: 340,
                    height: 250,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  final StatisticsController stats;
  final icons = <IconData>[];
  final titles = <String>[];
  final subtitles = <num>[];

  _Details(this.stats) {
    if (stats.onAnime) {
      icons.add(Ionicons.tv_outline);
      icons.add(Ionicons.play_outline);
      icons.add(Ionicons.calendar_clear_outline);
      titles.add('Total Anime');
      titles.add('Episodes Watched');
      titles.add('Days Watched');
      subtitles.add(stats.model.count);
      subtitles.add(stats.model.episodesWatched);
      subtitles.add((stats.model.minutesWatched / 1440).toPrecision(1));
    } else {
      icons.add(Ionicons.bookmarks_outline);
      icons.add(Ionicons.reader_outline);
      icons.add(Ionicons.book_outline);
      titles.add('Total Manga');
      titles.add('Chapters Read');
      titles.add('Volumes Read');
      subtitles.add(stats.model.count);
      subtitles.add(stats.model.chaptersRead);
      subtitles.add(stats.model.volumesRead);
    }

    icons.add(Ionicons.star_half_outline);
    icons.add(Ionicons.calculator_outline);
    titles.add('Mean Score');
    titles.add('Standard Deviation');
    subtitles.add(stats.model.meanScore);
    subtitles.add(stats.model.standardDeviation);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: Config.PADDING,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: titles.length,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: Config.BORDER_RADIUS,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icons[i]),
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
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: 50,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  _BarChart({
    required this.stats,
    required this.title,
    required this.tabs,
    required this.onAnime,
    required this.chartTab,
    required this.barWidth,
  });

  final List<NumberStatistics> stats;
  final String title;
  final BubbleTabs tabs;
  final bool onAnime;
  final int chartTab;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    late List<num> values;
    if (chartTab == StatisticsController.BY_COUNT)
      values = stats.map((s) => s.count).toList();
    else if (chartTab == StatisticsController.BY_MEAN_SCORE)
      values = stats.map((s) => s.meanScore).toList();
    else if (onAnime)
      values = stats.map((s) => s.minutesWatched).toList();
    else
      values = stats.map((s) => s.chaptersRead).toList();

    return BarChart(
      title: title,
      tabs: tabs,
      names: stats.map((s) => s.number).toList(),
      values: values,
      barWidth: barWidth,
    );
  }
}

class _PieChart extends StatelessWidget {
  _PieChart(this.title, this.stats);

  final String title;
  final List<EnumStatistics> stats;

  @override
  Widget build(BuildContext context) {
    final names = stats.map((s) => s.value).toList();
    final values = stats.map((s) => s.count).toList();

    return PieChart(title: title, names: names, values: values);
  }
}
