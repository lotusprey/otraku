import 'package:flutter/material.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class MediaHeader extends StatefulWidget {
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
  _MediaHeaderState createState() => _MediaHeaderState();
}

class _MediaHeaderState extends State<MediaHeader> {
  @override
  Widget build(BuildContext context) {
    final info = widget.ctrl.model?.info;
    return CustomSliverHeader(
      height: widget.height,
      title: info?.preferredTitle,
      actions: info != null
          ? [
              ActionIcon(
                dimmed: false,
                tooltip: 'Edit',
                onTap: _edit,
                icon: widget.ctrl.model!.entry.status == null
                    ? Icons.add
                    : Icons.edit,
              ),
              ActionIcon(
                dimmed: false,
                tooltip: 'Favourite',
                onTap: _toggleFavourite,
                icon: info.isFavourite ? Icons.favorite : Icons.favorite_border,
              ),
            ]
          : const [],
      background: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          if (info?.banner != null)
            Column(
              children: [
                Expanded(child: FadeImage(info!.banner)),
                SizedBox(height: widget.height - widget.bannerHeight),
              ],
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: widget.height - widget.bannerHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 25,
                    color: Theme.of(context).backgroundColor,
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
              tag: widget.ctrl.id,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: Config.BORDER_RADIUS,
                  color: Theme.of(context).primaryColor,
                ),
                height: widget.coverHeight,
                width: widget.coverWidth,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.imageUrl != null)
                        Image.network(widget.imageUrl!, fit: BoxFit.cover),
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
                      child: Text(
                        info.preferredTitle!,
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                          shadows: [
                            Shadow(
                              color: Theme.of(context).backgroundColor,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.fade,
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
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: _edit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  widget.ctrl.model!.entry.status == null
                                      ? Icons.add
                                      : Icons.edit,
                                ),
                              ),
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: _toggleFavourite,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  info.isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).errorColor,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
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

  void _edit() => ExploreIndexer.openEditPage(
        widget.ctrl.model!.info.id,
        widget.ctrl.model!.entry,
        (EntryModel entry) => setState(() => widget.ctrl.model!.entry = entry),
      );

  void _toggleFavourite() => widget.ctrl.toggleFavourite().then((ok) => ok
      ? setState(
          () => widget.ctrl.model!.info.isFavourite =
              !widget.ctrl.model!.info.isFavourite,
        )
      : null);
}
