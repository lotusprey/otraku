import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/pushable/media_tabs/overview_tab.dart';
import 'package:otraku/tools/headers/bubble_tabs.dart';
import 'package:otraku/tools/headers/media_page_header.dart';

class MediaPage extends StatelessWidget {
  final int id;
  final String tagImageUrl;

  MediaPage(this.id, this.tagImageUrl);

  @override
  Widget build(BuildContext context) {
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    double coverHeight = coverWidth / 0.7;
    double bannerHeight = coverHeight + Config.MATERIAL_TAP_TARGET_SIZE + 10;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: CustomScrollView(
            physics: Config.PHYSICS,
            slivers: [
              GetX<Media>(
                init: !Get.isRegistered<Media>(tag: id.toString())
                    ? Media()
                    : null,
                tag: id.toString(),
                initState: (_) {
                  Get.find<Media>(tag: id.toString()).fetchOverview(id);
                },
                builder: (media) => SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: MediaPageHeader(
                    media: media.overview,
                    coverWidth: coverWidth,
                    coverHeight: coverHeight,
                    maxHeight: bannerHeight,
                    tagImageUrl: tagImageUrl,
                  ),
                ),
              ),
              Obx(() {
                final media = Get.find<Media>(tag: id.toString());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: BubbleTabs(
                      options: ['Overview', 'Relations', 'Social'],
                      values: [Media.OVERVIEW, Media.RELATIONS, Media.SOCIAL],
                      initial: media.currentTab,
                      onNewValue: (_) {},
                      onSameValue: (_) {},
                      shrinkWrap: false,
                    ),
                  ),
                );
              }),
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: Obx(() {
                  final media = Get.find<Media>(tag: id.toString());

                  if (media.currentTab == Media.OVERVIEW) {
                    final overview = media.overview;
                    if (overview == null) return SliverToBoxAdapter();
                    return OverviewTab(overview);
                  }

                  return SliverToBoxAdapter();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
