import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/pages/media/overview_tab.dart';
import 'package:otraku/pages/media/relations_tab.dart';
import 'package:otraku/pages/media/social_tab.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/pages/media/media_header.dart';

class MediaPage extends StatelessWidget {
  static const ROUTE = '/media';

  final int id;
  final String? coverUrl;

  MediaPage(this.id, this.coverUrl);

  @override
  Widget build(BuildContext context) {
    final placeHolder = const SliverToBoxAdapter(child: SizedBox());
    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150.0;
    final coverHeight = coverWidth / 0.7;
    final bannerHeight =
        coverHeight * 0.6 + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    final headerHeight = bannerHeight + coverHeight * 0.6;
    final pageTop = headerHeight - Config.MATERIAL_TAP_TARGET_SIZE;

    return GetBuilder<Media>(
      tag: id.toString(),
      builder: (media) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            FluentIcons.book_information_24_regular: 'Overview',
            Icons.emoji_people_outlined: 'Relations',
            Icons.rate_review_outlined: 'Social',
          },
          initial: media.tab,
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
                imageUrl: coverUrl,
                coverWidth: coverWidth,
                coverHeight: coverHeight,
                bannerHeight: bannerHeight,
                height: headerHeight,
              ),
              if (media.model != null) ...[
                Obx(
                  () => media.tab == Media.RELATIONS
                      ? RelationControls(media, () => media.scrollTo(pageTop))
                      : placeHolder,
                ),
                Obx(() {
                  if (media.tab == Media.OVERVIEW)
                    return OverviewTab(media.model!.overview);
                  else if (media.tab == Media.RELATIONS)
                    return RelationsTab(media);
                  else
                    return SocialTab(media);
                }),
              ],
              SliverToBoxAdapter(
                child: SizedBox(height: NavBar.offset(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
