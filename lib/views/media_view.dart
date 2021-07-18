import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/views/media_info_view.dart';
import 'package:otraku/views/media_relations_view.dart';
import 'package:otraku/views/media_social_view.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/media_header.dart';

class MediaView extends StatelessWidget {
  final int id;
  final String? coverUrl;

  MediaView(this.id, this.coverUrl);

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150.0;
    final coverHeight = coverWidth / 0.7;
    final bannerHeight =
        coverHeight * 0.6 + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    final headerHeight = bannerHeight + coverHeight * 0.6;
    final pageTop = headerHeight - Config.MATERIAL_TAP_TARGET_SIZE;

    final header = MediaHeader(
      ctrl: Get.find<MediaController>(tag: id.toString()),
      imageUrl: coverUrl,
      coverWidth: coverWidth,
      coverHeight: coverHeight,
      bannerHeight: bannerHeight,
      height: headerHeight,
    );

    return GetBuilder<MediaController>(
      tag: id.toString(),
      builder: (ctrl) => Scaffold(
        extendBody: true,
        bottomNavigationBar: NavBar(
          options: {
            'Info': Ionicons.book_outline,
            'Relations': Icons.emoji_people_outlined,
            'Social': Icons.rate_review_outlined,
          },
          initial: ctrl.tab,
          onChanged: (index) => ctrl.tab = index,
        ),
        body: SafeArea(
          bottom: false,
          child: ctrl.model == null
              ? CustomScrollView(slivers: [header])
              : ctrl.tab == MediaController.INFO
                  ? MediaInfoView(ctrl, header)
                  : ctrl.tab == MediaController.RELATIONS
                      ? MediaRelationsView(
                          ctrl,
                          header,
                          () => ctrl.scrollTo(pageTop),
                        )
                      : MediaSocialView(ctrl, header),
        ),
      ),
    );
  }
}
