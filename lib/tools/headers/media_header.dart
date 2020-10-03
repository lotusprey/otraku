import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/media_data.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class MediaHeader implements SliverPersistentHeaderDelegate {
  //Data
  final MediaData media;

  //Output settings
  final double coverWidth;
  final double coverHeight;
  double _minExtent;
  double _maxExtent;

  MediaHeader({
    @required this.media,
    @required this.coverWidth,
    @required this.coverHeight,
    @required height,
  }) {
    _minExtent = ViewConfig.MATERIAL_TAP_TARGET_SIZE + 10;
    _maxExtent = height;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final transition = _maxExtent * 4.0 / 5.0;
    final shrinkPercentage =
        shrinkOffset < transition ? shrinkOffset / transition : 1.0;
    final buttonMinWidth = MediaQuery.of(context).size.width - coverWidth - 30;
    final addition = MediaQuery.of(context).size.width - 100 - buttonMinWidth;

    return Container(
      width: double.infinity,
      height: _maxExtent,
      color: Theme.of(context).primaryColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media.banner != null) media.banner,
          Container(
            padding: const EdgeInsets.only(
              top: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).backgroundColor.withAlpha(130),
                  Theme.of(context).backgroundColor,
                ],
              ),
            ),
            child: Container(
              height: coverHeight,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: ClipRRect(
                      borderRadius: ViewConfig.RADIUS,
                      child: Container(
                        height: coverHeight,
                        width: coverWidth,
                        child: media.cover,
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => PopUpAnimation(
                        ImageTextDialog(
                          text: media.title,
                          image: media.cover,
                        ),
                      ),
                      barrierDismissible: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Text(
                            media.title,
                            style: Theme.of(context).textTheme.headline3,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        if (media.nextEpisode != null)
                          Flexible(
                            child: Text(
                              'Ep ${media.nextEpisode} in ${media.timeUntilAiring}',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        const Flexible(child: SizedBox(height: 40)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (shrinkOffset > 0)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Theme.of(context)
                  .backgroundColor
                  .withAlpha((shrinkPercentage * 255).round()),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).dividerColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _FavoriteButton(media, shrinkPercentage),
              ],
            ),
          ),
          Positioned(
            right: shrinkPercentage * 40 + 10,
            bottom: shrinkPercentage * 7 + 10,
            child: _StatusButton(
              media,
              buttonMinWidth + addition * shrinkPercentage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}

class _FavoriteButton extends StatefulWidget {
  final MediaData media;
  final double shrinkPercentage;

  _FavoriteButton(this.media, this.shrinkPercentage);

  @override
  __FavoriteButtonState createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.shrinkPercentage < 0.5)
          Text(
            widget.media.favourites.toString(),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        IconButton(
          icon: Icon(
            widget.media.isFavourite ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).dividerColor,
          ),
          onPressed: () => Provider.of<MediaItem>(context, listen: false)
              .toggleFavourite(widget.media.mediaId, widget.media.type)
              .then((ok) {
            if (ok)
              setState(
                () {
                  widget.media.isFavourite = !widget.media.isFavourite;
                  if (widget.media.isFavourite)
                    widget.media.favourites++;
                  else
                    widget.media.favourites--;
                },
              );
          }),
        ),
      ],
    );
  }
}

class _StatusButton extends StatefulWidget {
  final MediaData media;
  final double width;

  _StatusButton(this.media, this.width);

  @override
  __StatusButtonState createState() => __StatusButtonState();
}

class __StatusButtonState extends State<_StatusButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: RaisedButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: ViewConfig.RADIUS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              widget.media.status == null ? Icons.add : Icons.edit,
              size: Design.ICON_SMALL,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
                widget.media.status == null
                    ? 'Add'
                    : listStatusSpecification(
                        widget.media.status,
                        widget.media.type == 'ANIME',
                      ),
                style: Theme.of(context).textTheme.button),
          ],
        ),
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => EditEntryPage(
              widget.media.mediaId,
              (status) => setState(() => widget.media.status = status),
            ),
          ),
        ),
      ),
    );
  }
}
