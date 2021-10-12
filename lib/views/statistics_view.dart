import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/statistics_controller.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/pie_chart.dart';

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
              _Title('Details'),
              _Details(ctrl),
              if (ctrl.model.scores.isNotEmpty) ...[
                const SizedBox(height: 10),
                _Title(
                  'Score',
                  BubbleTabs<int>(
                    items: ctrl.onAnime
                        ? const {'Titles': 0, 'Hours': 1}
                        : const {'Titles': 0, 'Chapters': 1},
                    current: () => ctrl.scoreChartTab,
                    onChanged: (val) => ctrl.scoreChartTab = val,
                    onSame: () {},
                    itemWidth: 100,
                  ),
                ),
                GetBuilder<StatisticsController>(
                  id: StatisticsController.ID_SCORE,
                  tag: id.toString(),
                  builder: (_) => _BarChart(
                    stats: ctrl.model.scores,
                    onAnime: ctrl.onAnime,
                    chartTab: ctrl.scoreChartTab,
                    wide: false,
                  ),
                ),
              ],
              if (ctrl.model.lengths.isNotEmpty) ...[
                const SizedBox(height: 10),
                _Title(
                  ctrl.onAnime ? 'Episodes' : 'Chapters',
                  BubbleTabs<int>(
                    items: ctrl.onAnime
                        ? const {'Titles': 0, 'Hours': 1, 'Mean Score': 2}
                        : const {'Titles': 0, 'Chapters': 1, 'Mean Score': 2},
                    current: () => ctrl.lengthChartTab,
                    onChanged: (val) => ctrl.lengthChartTab = val,
                    onSame: () {},
                    itemWidth: 100,
                  ),
                ),
                GetBuilder<StatisticsController>(
                  id: StatisticsController.ID_LENGTH,
                  tag: id.toString(),
                  builder: (_) => _BarChart(
                    stats: ctrl.model.lengths,
                    onAnime: ctrl.onAnime,
                    chartTab: ctrl.lengthChartTab,
                    wide: true,
                  ),
                ),
              ],
              GridView(
                shrinkWrap: true,
                padding: Config.PADDING,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PieChart('Format Distribution', ctrl.model.formats),
                  _PieChart('Status Distribution', ctrl.model.statuses),
                  _PieChart('Country Distribution', ctrl.model.countries),
                ],
                gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
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

class _Title extends StatelessWidget {
  final String text;
  final BubbleTabs? tabs;
  _Title(this.text, [this.tabs]);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: Theme.of(context).textTheme.headline6),
        ),
        if (tabs != null) tabs!,
      ],
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
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: 50,
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<NumberStatistics> stats;
  final bool onAnime;
  final int chartTab;
  final bool wide;

  _BarChart({
    required this.stats,
    required this.onAnime,
    required this.chartTab,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    double max = 200.0;
    if (chartTab == StatisticsController.BY_COUNT) {
      int maxCount = stats[0].count;
      for (int i = 1; i < stats.length; i++)
        if (maxCount < stats[i].count) maxCount = stats[i].count;
      max /= maxCount;
    } else if (chartTab == StatisticsController.BY_MEAN_SCORE) {
      double maxMeanScore = stats[0].meanScore;
      for (int i = 1; i < stats.length; i++)
        if (maxMeanScore < stats[i].meanScore)
          maxMeanScore = stats[i].meanScore;
      max /= maxMeanScore;
    } else if (onAnime) {
      int maxMinutes = stats[0].minutesWatched;
      for (int i = 1; i < stats.length; i++)
        if (maxMinutes < stats[i].minutesWatched)
          maxMinutes = stats[i].minutesWatched;
      max /= maxMinutes;
    } else {
      int maxChapters = stats[0].chaptersRead;
      for (int i = 1; i < stats.length; i++)
        if (maxChapters < stats[i].chaptersRead)
          maxChapters = stats[i].chaptersRead;
      max /= maxChapters;
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: Config.PHYSICS,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          late num value;
          late double height;
          if (chartTab == StatisticsController.BY_COUNT) {
            value = stats[i].count;
            height = stats[i].count * max;
          } else if (chartTab == StatisticsController.BY_MEAN_SCORE) {
            value = stats[i].meanScore;
            height = stats[i].meanScore * max;
          } else if (onAnime) {
            value = stats[i].minutesWatched ~/ 60;
            height = stats[i].minutesWatched * max;
          } else {
            value = stats[i].chaptersRead;
            height = stats[i].chaptersRead * max;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: height,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1],
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              Text(
                stats[i].number,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          );
        },
        itemExtent: wide ? 65 : 50,
        itemCount: stats.length,
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final String title;
  final List<EnumStatistics> stats;
  _PieChart(this.title, this.stats);

  @override
  Widget build(BuildContext context) {
    final counts = stats.map((s) => s.count).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 10),
        Flexible(
          child: Container(
            padding: Config.PADDING,
            decoration: BoxDecoration(
              borderRadius: Config.BORDER_RADIUS,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.5, 1],
                colors: [
                  Theme.of(context).colorScheme.surface.withOpacity(0.4),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Row(
              children: [
                Flexible(child: PieChart(counts)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < stats.length; i++)
                        Row(
                          children: [
                            Expanded(child: Text(stats[i].value)),
                            const SizedBox(width: 5),
                            Text(
                              stats[i].count.toString(),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
