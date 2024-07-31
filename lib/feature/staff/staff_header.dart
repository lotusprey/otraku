import 'package:flutter/material.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/content_header.dart';
import 'package:otraku/widget/table_list.dart';

class StaffHeader extends StatelessWidget {
  const StaffHeader({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.tabCtrl,
    required this.scrollToTop,
  });

  final int id;
  final String? imageUrl;
  final Staff? staff;
  final TabController tabCtrl;
  final void Function() scrollToTop;

  @override
  Widget build(BuildContext context) {
    return ContentHeader(
      imageUrl: imageUrl ?? staff?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: staff?.siteUrl,
      title: staff?.preferredName,
      details: staff != null
          ? TableList([
              ('Favorites', staff!.favorites.toString()),
              if (staff!.gender != null) ('Gender', staff!.gender!),
            ])
          : null,
      tabBarConfig: (
        tabCtrl: tabCtrl,
        scrollToTop: scrollToTop,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Characters'),
          Tab(text: 'Roles'),
        ],
      ),
    );
  }
}
