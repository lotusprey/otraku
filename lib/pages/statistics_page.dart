import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/statistics.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';

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
                physics: Config.PHYSICS,
                children: [
                  _Details(stats),
                ],
              ),
            ),
          ),
        );
      },
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
                      Text(
                        subtitles[i].toString(),
                        style: Theme.of(context).textTheme.bodyText1,
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
