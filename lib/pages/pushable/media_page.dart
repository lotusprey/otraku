import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/pushable/media_tabs/overview_tab.dart';
import 'package:otraku/pages/pushable/media_tabs/relations_tab.dart';
import 'package:otraku/tools/navigators/custom_nav_bar.dart';
import 'package:otraku/tools/navigators/media_page_header.dart';

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
      extendBody: true,
      bottomNavigationBar: CustomNavBar(
        icons: const [
          FluentSystemIcons.ic_fluent_text_description_regular,
          FluentSystemIcons.ic_fluent_recommended_regular,
          FluentSystemIcons.ic_fluent_people_community_regular,
        ],
        onChanged: (index) => Get.find<Media>(tag: id.toString()).tab = index,
      ),
      body: SafeArea(
        bottom: false,
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
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: Obx(() {
                  final media = Get.find<Media>(tag: id.toString());

                  if (media.tab == Media.OVERVIEW) {
                    if (media.overview == null) return SliverToBoxAdapter();
                    return OverviewTab(media.overview);
                  }

                  if (media.tab == Media.RELATIONS) {
                    return RelationsTab(media);
                  }

                  if (media.tab == Media.SOCIAL) {}

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
