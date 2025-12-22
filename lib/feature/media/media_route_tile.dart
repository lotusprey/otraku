import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/sheets.dart';

class MediaRouteTile extends StatelessWidget {
  const MediaRouteTile({super.key, required this.id, required this.imageUrl, required this.child});

  final int id;
  final String? imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Theming.borderRadiusSmall,
      onTap: () => context.push(Routes.media(id, imageUrl)),
      onLongPress: () => showSheet(context, EditView((id: id, setComplete: false))),
      child: child,
    );
  }
}
