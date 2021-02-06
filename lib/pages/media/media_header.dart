import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/helpers/fn_helper.dart';

class MediaHeader extends StatefulWidget {
  final Media media;
  final String imageUrl;
  final double coverWidth;
  final double coverHeight;
  final double bannerHeight;
  final double height;

  MediaHeader({
    @required this.media,
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
    return Obx(
      () => CustomSliverHeader(
        height: widget.height,
        title: widget.media.overview?.preferredTitle,
        actions: widget.media.overview != null
            ? [
                IconButton(
                  onPressed: _edit,
                  icon: Icon(
                    widget.media.overview.entryStatus == null
                        ? Icons.add
                        : Icons.edit,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                IconButton(
                  onPressed: _toggleFavourite,
                  icon: Icon(
                    widget.media.overview.isFavourite
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
                  child: widget.media.overview?.banner != null
                      ? FadeInImage.memoryNetwork(
                          image: widget.media.overview.banner,
                          placeholder: FnHelper.transparentImage,
                          fadeInDuration: Config.FADE_DURATION,
                          fit: BoxFit.cover,
                          height: widget.bannerHeight,
                          width: double.infinity,
                        )
                      : Container(color: Theme.of(context).primaryColor),
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
                tag: widget.imageUrl,
                child: Container(
                  height: widget.coverHeight,
                  width: widget.coverWidth,
                  child: ClipRRect(
                    borderRadius: Config.BORDER_RADIUS,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(widget.imageUrl, fit: BoxFit.cover),
                        if (widget.media.overview != null)
                          GestureDetector(
                            child: Image.network(
                              widget.media.overview.cover,
                              fit: BoxFit.cover,
                            ),
                            onTap: () => showDialog(
                              context: context,
                              builder: (ctx) => PopUpAnimation(
                                ImageTextDialog(
                                  text: widget.media.overview.preferredTitle,
                                  image: Image.network(
                                    widget.media.overview.cover,
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
              if (widget.media.overview != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          widget.media.overview.preferredTitle,
                          style: Theme.of(context).textTheme.headline3,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      if (widget.media.overview.nextEpisode != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Ep ${widget.media.overview.nextEpisode} in ${widget.media.overview.timeUntilAiring}',
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
                              RaisedButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                clipBehavior: Clip.hardEdge,
                                onPressed: _edit,
                                child: Icon(
                                  widget.media.overview.entryStatus == null
                                      ? Icons.add
                                      : Icons.edit,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              RaisedButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                color: Theme.of(context).errorColor,
                                clipBehavior: Clip.hardEdge,
                                onPressed: _toggleFavourite,
                                child: Icon(
                                  widget.media.overview.isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              )
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
      ),
    );
  }

  void _edit() => BrowseIndexer.openEditPage(
        widget.media.overview.id,
        (status) => setState(() => widget.media.overview.entryStatus = status),
      );

  void _toggleFavourite() => widget.media.toggleFavourite().then((ok) => ok
      ? setState(
          () => widget.media.overview.isFavourite =
              !widget.media.overview.isFavourite,
        )
      : null);
}
