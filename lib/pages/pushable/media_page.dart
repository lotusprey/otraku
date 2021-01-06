import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/pages/media_pages/overview_tab.dart';
import 'package:otraku/pages/media_pages/relations_tab.dart';
import 'package:otraku/tools/navigation/custom_nav_bar.dart';
import 'package:otraku/tools/navigation/media_header.dart';

class MediaPage extends StatelessWidget {
  final int id;
  final String tagImageUrl;

  MediaPage(this.id, this.tagImageUrl);

  @override
  Widget build(BuildContext context) {
    const placeholder = const SliverToBoxAdapter(child: SizedBox());
    final media = Get.find<Media>(tag: id.toString());

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
          slivers: [
            Obx(
              () => MediaHeader(
                overview: media.overview,
                imageUrl: tagImageUrl,
                toggleFavourite: media.toggleFavourite,
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
    );
  }
}
