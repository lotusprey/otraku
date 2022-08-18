import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class MediaHeader extends StatelessWidget {
  MediaHeader({required this.ctrl, required this.imageUrl});

  final MediaController ctrl;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final info = ctrl.model?.info;

    final textRailItems = <String, bool>{};
    if (info != null) {
      if (info.isAdult) textRailItems['Adult'] = true;

      if (info.format != null)
        textRailItems[Convert.clarifyEnum(info.format)!] = false;

      final status = ctrl.model?.edit.status;
      if (status != null)
        textRailItems[Convert.adaptListStatus(
          status,
          info.type == DiscoverType.anime,
        )] = false;

      if (info.airingAt != null)
        textRailItems['Ep ${info.nextEpisode} in '
            '${Convert.timeUntilTimestamp(info.airingAt)}'] = true;

      if (status != null) {
        final progress = ctrl.model?.edit.progress ?? 0;
        if (info.nextEpisode != null && info.nextEpisode! - 1 > progress)
          textRailItems['${info.nextEpisode! - 1 - progress} ep behind'] = true;
      }
    }

    return CustomSliverHeader(
      title: info?.preferredTitle,
      image: info?.cover ?? imageUrl,
      extraLargeImage: info?.extraLargeCover,
      banner: info?.banner,
      squareImage: false,
      implyLeading: true,
      heroId: ctrl.id,
      maxWidth: null,
      actions: [
        if (info?.siteUrl != null)
          IconShade(TopBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              FixedGradientDragSheet.link(context, info!.siteUrl!),
            ),
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
                    maxLines: 8,
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (textRailItems.isNotEmpty) TextRail(textRailItems),
              ]
            : [],
      ),
    );
  }
}
