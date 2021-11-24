import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaHeader extends StatelessWidget {
  final MediaController ctrl;
  final String? imageUrl;
  final double coverWidth;
  final double coverHeight;
  final double bannerHeight;
  final double height;

  MediaHeader({
    required this.ctrl,
    required this.imageUrl,
    required this.coverWidth,
    required this.coverHeight,
    required this.bannerHeight,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final info = ctrl.model?.info;
    return CustomSliverHeader(
      height: height,
      title: info?.preferredTitle,
      actions: [
        if (info?.siteUrl != null)
          IconShade(AppBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => _showSheet(context, info!),
          )),
      ],
      background: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
          ),
          if (info?.banner != null)
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: FadeImage(info!.banner!),
                    onTap: () => showPopUp(context, ImageDialog(info.banner!)),
                  ),
                ),
                SizedBox(height: height - bannerHeight),
              ],
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height - bannerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 25,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Hero(
              tag: ctrl.id,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: Config.BORDER_RADIUS,
                  color: Theme.of(context).colorScheme.surface,
                ),
                height: coverHeight,
                width: coverWidth,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        Image.network(imageUrl!, fit: BoxFit.cover),
                      if (info != null)
                        GestureDetector(
                          child: Image.network(
                            info.cover!,
                            fit: BoxFit.cover,
                          ),
                          onTap: () =>
                              showPopUp(context, ImageDialog(info.cover!)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (info != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Toast.copy(context, info.preferredTitle!),
                        child: Text(
                          info.preferredTitle!,
                          style:
                              Theme.of(context).textTheme.headline2!.copyWith(
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
                    ),
                    if (info.nextEpisode != null)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Ep ${info.nextEpisode} in ${info.timeUntilAiring}',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
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
