import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class MediaHeader extends StatefulWidget {
  final Media media;
  final int mediaId;
  final String imageUrl;
  final double coverWidth;
  final double coverHeight;
  final double bannerHeight;
  final double height;

  MediaHeader({
    @required this.media,
    @required this.mediaId,
    @required this.imageUrl,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.bannerHeight,
    @required this.height,
  });

  @override
  _MediaHeaderState createState() => _MediaHeaderState();
}

class _MediaHeaderState extends State<MediaHeader> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final overview = widget.media.model.overview;
      return CustomSliverHeader(
        height: widget.height,
        title: overview?.preferredTitle,
        actions: overview != null
            ? [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: _edit,
                  icon: Icon(
                    overview.entryStatus == null ? Icons.add : Icons.edit,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                IconButton(
                  tooltip: 'Favourite',
                  onPressed: _toggleFavourite,
                  icon: Icon(
                    overview.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ]
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Theme.of(context).primaryColor),
                      if (overview?.banner != null)
                        FadeImage(
                          overview.banner,
                          height: widget.bannerHeight,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: widget.height - widget.bannerHeight),
              ],
            ),
            Positioned.fill(
              bottom: widget.height - widget.bannerHeight - 1,
              child: Container(
                height: widget.bannerHeight - Config.MATERIAL_TAP_TARGET_SIZE,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Theme.of(context).backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Hero(
                tag: widget.mediaId,
                child: Container(
                  height: widget.coverHeight,
                  width: widget.coverWidth,
                  child: ClipRRect(
                    borderRadius: Config.BORDER_RADIUS,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(widget.imageUrl, fit: BoxFit.cover),
                        if (overview != null)
                          GestureDetector(
                            child: Image.network(
                              overview.cover,
                              fit: BoxFit.cover,
                            ),
                            onTap: () => showDialog(
                              context: context,
                              builder: (ctx) => PopUpAnimation(
                                ImageTextDialog(
                                  text: overview.preferredTitle,
                                  image: Image.network(
                                    overview.cover,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (overview != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          overview.preferredTitle,
                          style: Theme.of(context).textTheme.headline2,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      if (overview.nextEpisode != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Ep ${overview.nextEpisode} in ${overview.timeUntilAiring}',
                              style: Theme.of(context).textTheme.bodyText2,
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
                                    overview.entryStatus == null
                                        ? Icons.add
                                        : Icons.edit,
                                  ),
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
                                    overview.isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).errorColor,
                                  ),
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
    });
  }

  void _edit() => BrowseIndexer.openEditPage(
        widget.media.model.overview.id,
        (status) =>
            setState(() => widget.media.model.overview.entryStatus = status),
      );

  void _toggleFavourite() => widget.media.toggleFavourite().then((ok) => ok
      ? setState(
          () => widget.media.model.overview.isFavourite =
              !widget.media.model.overview.isFavourite,
        )
      : null);
}
