import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/statistics.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/pie_chart.dart';

class StatisticsPage extends StatelessWidget {
  static const ROUTE = '/statistics';

  final int id;
  StatisticsPage(this.id);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Statistics>(
      tag: id.toString(),
      builder: (stats) {
        return Scaffold(
          extendBody: true,
          appBar: CustomAppBar(
            title: stats.onAnime ? 'Anime Statistics' : 'Manga Statistics',
          ),
          bottomNavigationBar: NavBar(
            options: {
              'Anime': Ionicons.film_outline,
              'Manga': Ionicons.bookmark_outline,
            },
            onChanged: (page) => stats.onAnime = page == 0 ? true : false,
            initial: stats.onAnime ? 0 : 1,
          ),
          body: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: Config.TAB_SWITCH_DURATION,
              child: ListView(
                key: stats.key,
                padding:
                    EdgeInsets.only(top: 10, bottom: NavBar.offset(context)),
                physics: Config.PHYSICS,
                children: [
                  _Title('Details'),
                  _Details(stats),
                  if (stats.model.scores.isNotEmpty) ...[
                    _Title(
                      'Score',
                      BubbleTabs<bool>(
                        options: stats.onAnime
                            ? const ['Titles Watched', 'Hours Watched']
                            : const ['Titles Read', 'Chapters Read'],
                        values: [true, false],
                        initial: stats.scoresOnCount,
                        onNewValue: (val) => stats.scoresOnCount = val,
                        onSameValue: (_) {},
                      ),
                    ),
                    _ScoreChart(id),
                    GridView.extent(
                      shrinkWrap: true,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 2,
                      padding: Config.PADDING,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Card(stats.model.formats),
                        _Card(stats.model.statuses),
                        _Card(stats.model.countries),
                      ],
                    ),
                  ],
                ],
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(text, style: Theme.of(context).textTheme.headline3),
          const Spacer(),
          if (tabs != null) tabs!,
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final Statistics stats;
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
    return SizedBox(
      height: 60,
      child: ListView(
        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        physics: Config.PHYSICS,
        scrollDirection: Axis.horizontal,
        itemExtent: 200,
        children: [
          for (int i = 0; i < icons.length; i++)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: Config.BORDER_RADIUS,
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: [
                  Icon(icons[i]),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[i],
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(subtitles[i].toString()),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreChart extends StatelessWidget {
  final int id;
  _ScoreChart(this.id);

  @override
  Widget build(BuildContext context) {
    final stats = Get.find<Statistics>(tag: id.toString());

    return Obx(
      () {
        final scores = stats.model.scores;

        double max = 200.0;
        if (stats.scoresOnCount) {
          int maxCount = scores[0].count;
          for (int i = 1; i < scores.length; i++)
            if (maxCount < scores[i].count) maxCount = scores[i].count;
          max /= maxCount;
        } else {
          if (stats.onAnime) {
            int maxMinutes = scores[0].minutesWatched;
            for (int i = 1; i < scores.length; i++)
              if (maxMinutes < scores[i].minutesWatched)
                maxMinutes = scores[i].minutesWatched;
            max /= maxMinutes;
          } else {
            int maxChapters = scores[0].chaptersRead;
            for (int i = 1; i < scores.length; i++)
              if (maxChapters < scores[i].chaptersRead)
                maxChapters = scores[i].chaptersRead;
            max /= maxChapters;
          }
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            physics: Config.PHYSICS,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              late int number;
              late double height;
              if (stats.scoresOnCount) {
                number = scores[i].count;
                height = scores[i].count * max;
              } else {
                if (stats.onAnime) {
                  number = scores[i].minutesWatched ~/ 60;
                  height = scores[i].minutesWatched * max;
                } else {
                  number = scores[i].chaptersRead;
                  height = scores[i].chaptersRead * max;
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    number.toString(),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Container(
                    height: height,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  Text(
                    scores[i].number.toString(),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              );
            },
            itemExtent: 50,
            itemCount: scores.length,
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final List<EnumStatistics> stats;
  _Card(this.stats);

  @override
  Widget build(BuildContext context) {
    final counts = <int>[];
    final values = <String>[];
    final colours = <Color>[];

    final offset = stats.length / 2;
    final division = 1.0 / (stats.length * 2);
    final colour = HSLColor.fromColor(Theme.of(context).accentColor);

    for (int i = 0; i < stats.length; i++) {
      counts.add(stats[i].count);
      values.add(stats[i].value);
      colours.add(colour.withLightness(division * (i + offset)).toColor());
    }

    return Container(
      padding: Config.PADDING,
      decoration: BoxDecoration(
        borderRadius: Config.BORDER_RADIUS,
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        children: [
          PieChart(counts, colours),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < stats.length; i++)
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: Config.BORDER_RADIUS,
                          color: colours[i],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(child: Text(values[i])),
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
    );
  }
}
