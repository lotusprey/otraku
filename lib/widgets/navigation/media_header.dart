import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

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

      final status = ctrl.model?.entry.status;
      if (status != null)
        details.add(TextSpan(
          text: '${details.isEmpty ? "" : ' • '}'
              '${Convert.adaptListStatus(status, info.type == Explorable.anime)}',
        ));

      if (info.airingAt != null)
        details.add(TextSpan(
          text: '${details.isEmpty ? "" : ' • '}'
              'Ep ${info.nextEpisode} in '
              '${Convert.timeUntilTimestamp(info.airingAt)}',
        ));

      if (status != null) {
        final progress = ctrl.model?.entry.progress ?? 0;
        if (info.nextEpisode != null && info.nextEpisode! - 1 > progress)
          details.add(TextSpan(
            text: '${details.isEmpty ? "" : ' • '}'
                '${info.nextEpisode! - 1 - progress} ep behind',
            style: Theme.of(context).textTheme.bodyText1,
          ));
      }
    }

    return CustomSliverHeader(
      title: info?.preferredTitle,
      image: info?.cover ?? imageUrl,
      banner: info?.banner,
      squareImage: false,
      implyLeading: true,
      heroId: ctrl.id,
      maxWidth: null,
      actions: [
        if (info?.siteUrl != null)
          IconShade(AppBarIcon(
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
}
