import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaHeader extends StatelessWidget {
  final MediaController ctrl;
  final String? imageUrl;

  MediaHeader({required this.ctrl, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final info = ctrl.model?.info;

    final details = <TextSpan>[];
    if (info != null) {
      if (info.format != null)
        details.add(TextSpan(text: Convert.clarifyEnum(info.format)));
      if (info.airingAt != null)
        details.add(TextSpan(
          text: '${details.isEmpty ? "" : ' • '}'
              'Ep ${info.nextEpisode} in '
              '${Convert.timeUntilTimestamp(info.airingAt)}',
        ));
      final progress = ctrl.model?.entry.progress ?? 0;
      if (info.nextEpisode != null && info.nextEpisode! - 1 > progress)
        details.add(TextSpan(
          text: '${details.isEmpty ? "" : ' • '}'
              '${info.nextEpisode! - 1 - progress} ep behind',
          style: Theme.of(context).textTheme.bodyText1,
        ));
    }

    return CustomSliverHeader(
      title: info?.preferredTitle,
      image: info?.cover ?? imageUrl,
      banner: info?.banner,
      squareImage: false,
      implyLeading: true,
      heroId: ctrl.id,
      actions: [
        if (info?.siteUrl != null)
          IconShade(AppBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => _showSheet(context, info!),
          )),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: info != null
            ? [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Toast.copy(context, info.preferredTitle!),
                  child: Text(
                    info.preferredTitle!,
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.background,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.subtitle1,
                      children: details,
                    ),
                  ),
                ],
              ]
            : [],
      ),
    );
  }

  void _showSheet(BuildContext context, MediaInfoModel model) {
    final children = <Widget>[];
    children.add(DragSheetListTile(
      text: 'Copy Link',
      icon: Ionicons.clipboard_outline,
      onTap: () {
        if (model.siteUrl == null) {
          Toast.show(context, 'Url is null');
          return;
        }

        Toast.copy(context, model.siteUrl!);
      },
    ));
    children.add(DragSheetListTile(
      text: 'Open in Browser',
      icon: Ionicons.link_outline,
      onTap: () {
        if (model.siteUrl == null) {
          Toast.show(context, 'Url is null');
          return;
        }

        try {
          launch(model.siteUrl!);
        } catch (err) {
          Toast.show(context, 'Couldn\'t open link: $err');
        }
      },
    ));

    DragSheet.show(context, DragSheet(children: children, ctx: context));
  }
}
