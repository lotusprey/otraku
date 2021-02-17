import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/media/overview_tab.dart';
import 'package:otraku/pages/media/relations_tab.dart';
import 'package:otraku/pages/media/social_tab.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';
import 'package:otraku/pages/media/media_header.dart';

class MediaPage extends StatelessWidget {
  static const ROUTE = '/media';

  final int id;
  final String coverUrl;

  MediaPage(this.id, this.coverUrl);

  @override
  Widget build(BuildContext context) {
    const placeholder = const SliverToBoxAdapter(child: SizedBox());
    final media = Get.find<Media>(tag: id.toString());

    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150.0;
    final coverHeight = coverWidth / 0.7;
    final bannerHeight =
        coverHeight * 0.6 + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    final headerHeight = bannerHeight + coverHeight * 0.6;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomNavBar(
        icons: const [
          FluentSystemIcons.ic_fluent_text_description_regular,
          FluentSystemIcons.ic_fluent_recommended_regular,
          FluentSystemIcons.ic_fluent_people_community_regular,
        ],
        onChanged: (index) => media.tab = index,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: Config.PHYSICS,
          controller: media.scrollCtrl,
          slivers: [
            MediaHeader(
              media: media,
              mediaId: id,
              imageUrl: coverUrl,
              coverWidth: coverWidth,
              coverHeight: coverHeight,
              bannerHeight: bannerHeight,
              height: headerHeight,
            ),
            Obx(
              () => media.tab == Media.OVERVIEW && media.overview != null
                  ? OverviewTab(media.overview)
                  : placeholder,
            ),
            Obx(
              () => media.tab == Media.RELATIONS
                  ? RelationControls(
                      media,
                      () => media.scrollTo(
                        headerHeight - Config.MATERIAL_TAP_TARGET_SIZE,
                      ),
                    )
                  : placeholder,
            ),
            Obx(
              () => media.tab == Media.RELATIONS
                  ? RelationsTab(media)
                  : placeholder,
            ),
            Obx(
              () => media.tab == Media.SOCIAL ? SocialTab(media) : placeholder,
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: CustomNavBar.offset(context)),
            ),
          ],
        ),
      ),
    );
  }
}
