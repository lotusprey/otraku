import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
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
    const placeholder = const SliverToBoxAdapter(child: SizedBox());
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    double coverHeight = coverWidth / 0.7;
    double bannerHeight = coverHeight + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    Media media;

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
                didUpdateWidget: (_, __) =>
                    media = Get.find<Media>(tag: id.toString()),
                initState: (_) => media = Get.find<Media>(tag: id.toString())
                  ..fetchOverview(id),
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
              Obx(
                () => media.tab == Media.OVERVIEW && media.overview != null
                    ? OverviewTab(media.overview)
                    : placeholder,
              ),
              Obx(
                () => media.tab == Media.RELATIONS
                    ? RelationControls(media)
                    : placeholder,
              ),
              Obx(
                () => media.tab == Media.RELATIONS
                    ? RelationList(media)
                    : placeholder,
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
