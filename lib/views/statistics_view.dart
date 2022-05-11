import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/statistics_controller.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/charts.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/tab_switcher.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';

class StatisticsView extends StatelessWidget {
  StatisticsView(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatisticsController>(
      init: StatisticsController(id),
      id: StatisticsController.ID_MAIN,
      tag: id.toString(),
      builder: (ctrl) {
        return PageLayout(
          bottomBar: BottomBarIconTabs(
            index: ctrl.onAnime ? 0 : 1,
            onChanged: (page) => ctrl.onAnime = page == 0 ? true : false,
            onSame: (_) => ctrl.scrollCtrl.scrollUpTo(0),
            items: const {
              'Anime': Ionicons.film_outline,
              'Manga': Ionicons.bookmark_outline,
            },
          ),
          topBar: TopBar(
            title: ctrl.onAnime ? 'Anime Statistics' : 'Manga Statistics',
          ),
          builder: (context, topOffset, bottomOffset) => TabSwitcher(
            index: ctrl.onAnime ? 0 : 1,
            onChanged: (i) => ctrl.onAnime = i > 0 ? false : true,
            tabs: [_StatisticsView(ctrl, true), _StatisticsView(ctrl, false)],
          ),
        );
      },
    );
  }
}

class _StatisticsView extends StatelessWidget {
  _StatisticsView(this.ctrl, this.ofAnime);

  final bool ofAnime;
  final StatisticsController ctrl;

  @override
  Widget build(BuildContext context) {
    final offset = PageOffset.of(context);
    final model = ofAnime ? ctrl.animeStats : ctrl.mangaStats;

    return ListView(
      controller: ctrl.scrollCtrl,
      padding: EdgeInsets.only(
        top: offset.top + 10,
        bottom: offset.bottom,
      ),
      children: [
        _Details(ctrl, ofAnime),
        if (model.scores.isNotEmpty) ...[
          GetBuilder<StatisticsController>(
            id: StatisticsController.ID_SCORE,
            tag: ctrl.id.toString(),
            builder: (_) => _BarChart(
              title: 'Score',
              tabs: TabSegments<int>(
                items: ctrl.onAnime
                    ? const {'Titles': 0, 'Hours': 1}
                    : const {'Titles': 0, 'Chapters': 1},
                initial: ctrl.scoreChartTab,
                onChanged: (val) => ctrl.scoreChartTab = val,
              ),
              stats: model.scores,
              onAnime: ctrl.onAnime,
              chartTab: ctrl.scoreChartTab,
              barWidth: 40,
            ),
          ),
        ],
        if (model.lengths.isNotEmpty) ...[
          GetBuilder<StatisticsController>(
            id: StatisticsController.ID_LENGTH,
            tag: ctrl.id.toString(),
            builder: (_) => _BarChart(
              title: ctrl.onAnime ? 'Episodes' : 'Chapters',
              tabs: TabSegments<int>(
                items: ctrl.onAnime
                    ? const {'Titles': 0, 'Hours': 1, 'Mean Score': 2}
                    : const {'Titles': 0, 'Chapters': 1, 'Mean Score': 2},
                initial: ctrl.lengthChartTab,
                onChanged: (val) => ctrl.lengthChartTab = val,
              ),
              stats: model.lengths,
              onAnime: ctrl.onAnime,
              chartTab: ctrl.lengthChartTab,
              barWidth: 50,
            ),
          ),
        ],
        if (model.count > 0)
          GridView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _PieChart('Format Distribution', model.formats),
              _PieChart('Status Distribution', model.statuses),
              _PieChart('Country Distribution', model.countries),
            ],
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 340,
              height: 250,
            ),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  _Details(StatisticsController ctrl, bool ofAnime) {
    if (ofAnime) {
      icons.add(Ionicons.tv_outline);
      icons.add(Ionicons.play_outline);
      icons.add(Ionicons.calendar_clear_outline);
      titles.add('Total Anime');
      titles.add('Episodes Watched');
      titles.add('Days Watched');
      subtitles.add(ctrl.animeStats.count);
      subtitles.add(ctrl.animeStats.episodesWatched);
      subtitles.add((ctrl.animeStats.minutesWatched / 1440).toPrecision(1));
    } else {
      icons.add(Ionicons.bookmarks_outline);
      icons.add(Ionicons.reader_outline);
      icons.add(Ionicons.book_outline);
      titles.add('Total Manga');
      titles.add('Chapters Read');
      titles.add('Volumes Read');
      subtitles.add(ctrl.mangaStats.count);
      subtitles.add(ctrl.mangaStats.chaptersRead);
      subtitles.add(ctrl.mangaStats.volumesRead);
    }

    icons.add(Ionicons.star_half_outline);
    icons.add(Ionicons.calculator_outline);
    titles.add('Mean Score');
    titles.add('Standard Deviation');

    if (ofAnime) {
      subtitles.add(ctrl.animeStats.meanScore);
      subtitles.add(ctrl.animeStats.standardDeviation);
    } else {
      subtitles.add(ctrl.mangaStats.meanScore);
      subtitles.add(ctrl.mangaStats.standardDeviation);
    }
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
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: Consts.BORDER_RAD_MIN,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icons[i], color: Theme.of(context).colorScheme.onSurface),
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
  final TabSegments tabs;
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
      values = stats.map((s) => s.hoursWatched).toList();
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
