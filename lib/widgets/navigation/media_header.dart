import 'package:flutter/material.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

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
                Expanded(child: FadeImage(info!.banner!)),
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
}
