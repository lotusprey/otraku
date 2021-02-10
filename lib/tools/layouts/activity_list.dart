import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/triangle_clip.dart';

class ActivityList extends StatelessWidget {
  final Viewer viewer;

  ActivityList(this.viewer);

  @override
  Widget build(BuildContext context) {
    final clipper = ClipPath(
      clipper: TriangleClip(),
      child: Container(
        width: 50,
        height: 10,
        color: Theme.of(context).primaryColor,
      ),
    );

    return SliverPadding(
      padding: Config.PADDING,
      sliver: Obx(
        () {
          final activities = viewer.activities;
          if ((activities?.length ?? 0) == 0)
            return SliverFillRemaining(
              child: Text(
                'No Activities',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            );

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == activities.length - 5) viewer.fetchPage();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrowseIndexer(
                      id: activities[i].agentId,
                      imageUrl: activities[i].agentImage,
                      browsable: Browsable.user,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: Config.BORDER_RADIUS,
                            child: FadeImage(
                              activities[i].agentImage,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            activities[i].agentName,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    clipper,
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: Config.PADDING,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: Config.BORDER_RADIUS,
                      ),
                      child: Column(
                        children: [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            child:
                                activities[i].type == ActivityType.ANIME_LIST ||
                                        activities[i].type ==
                                            ActivityType.MANGA_LIST
                                    ? _ListActivityContent()
                                    : HtmlWidget(activities[i].text),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                activities[i].createdAt,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          activities[i].replyCount.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.comment,
                                          size: Styles.ICON_SMALLER,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          activities[i].likeCount.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.favorite,
                                          size: Styles.ICON_SMALLER,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              childCount: activities.length,
            ),
          );
        },
      ),
    );
  }
}

class _ListActivityContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('List Activity');
  }
}
