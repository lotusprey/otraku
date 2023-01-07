import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/custom_sliver_header.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:otraku/widgets/text_rail.dart';

class MediaHeader extends StatelessWidget {
  const MediaHeader(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => ref.watch(mediaProvider(id)).when(
            loading: _placeholder,
            error: (_, __) => _placeholder(),
            data: (data) {
              final info = data.info;
              final textRailItems = <String, bool>{};

              if (info.isAdult) textRailItems['Adult'] = true;
              if (info.format != null) {
                textRailItems[Convert.clarifyEnum(info.format)!] = false;
              }
              if (data.edit.status != null) {
                textRailItems[Convert.adaptListStatus(
                  data.edit.status!,
                  info.type == DiscoverType.anime,
                )] = false;
              }
              if (info.airingAt != null) {
                textRailItems['Ep ${info.nextEpisode} in '
                    '${Convert.timeUntilTimestamp(info.airingAt)}'] = true;
              }
              if (data.edit.status != null) {
                final progress = data.edit.progress;
                if (info.nextEpisode != null &&
                    info.nextEpisode! - 1 > progress) {
                  textRailItems['${info.nextEpisode! - 1 - progress}'
                      ' ep behind'] = true;
                }
              }

              return CustomSliverHeader(
                title: info.preferredTitle,
                image: info.cover,
                extraLargeImage: info.extraLargeCover,
                banner: info.banner,
                squareImage: false,
                implyLeading: true,
                heroId: id,
                maxWidth: null,
                actions: [
                  if (info.siteUrl != null)
                    TopBarShadowIcon(
                      tooltip: 'More',
                      icon: Ionicons.ellipsis_horizontal,
                      onTap: () => showSheet(
                        context,
                        FixedGradientDragSheet.link(context, info.siteUrl!),
                      ),
                    ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Toast.copy(context, info.preferredTitle!),
                      child: Text(
                        info.preferredTitle!,
                        maxLines: 8,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextRail(
                      textRailItems,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _placeholder() => CustomSliverHeader(
        heroId: id,
        image: coverUrl,
        squareImage: false,
        implyLeading: true,
        actions: const [],
        title: null,
        banner: null,
        maxWidth: null,
        child: null,
      );
}
