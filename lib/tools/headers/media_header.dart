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
  final MediaData mediaObj;

  //Output settings
  final double coverWidth;
  final double coverHeight;
  double _minExtent;
  double _maxExtent;

  MediaHeader({
    @required this.mediaObj,
    @required this.coverWidth,
    @required this.coverHeight,
    @required height,
  }) {
    _minExtent = 48;
    _maxExtent = height;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final buttonShrinkLimit = _maxExtent * 4.0 / 5.0;
    final shrinkPercentage = shrinkOffset < buttonShrinkLimit
        ? shrinkOffset / buttonShrinkLimit
        : 1.0;
    final buttonInset = 10.0 + shrinkPercentage * 50.0;
    final fadeColor = Theme.of(context)
        .backgroundColor
        .withAlpha((shrinkPercentage * 255).round());

    return Container(
      width: double.infinity,
      height: _maxExtent,
      color: Theme.of(context).primaryColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (mediaObj.banner != null) mediaObj.banner,
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: double.infinity,
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
                children: [
                  GestureDetector(
                    child: ClipRRect(
                      borderRadius: ViewConfig.RADIUS,
                      child: Container(
                        height: coverHeight,
                        width: coverWidth,
                        child: mediaObj.cover,
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => PopUpAnimation(
                        ImageTextDialog(
                          text: mediaObj.title,
                          image: mediaObj.cover,
                        ),
                      ),
                      barrierDismissible: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Text(
                            mediaObj.title,
                            style: Theme.of(context).textTheme.headline3,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        if (mediaObj.nextEpisode != null)
                          Flexible(
                            child: Text(
                              'Ep ${mediaObj.nextEpisode} in ${mediaObj.timeUntilAiring}',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mediaObj.popularity != null)
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Opacity(
                                      opacity: 1 - shrinkPercentage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 7,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: Design.ICON_SMALL,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      mediaObj.popularity.toString(),
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 10),
                            if (mediaObj.favourites != null)
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Opacity(
                                      opacity: 1 - shrinkPercentage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 7,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                          size: Design.ICON_SMALL,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      mediaObj.favourites.toString(),
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
              color: fadeColor,
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
                _FavoriteButton(mediaObj),
              ],
            ),
          ),
          Positioned(
            left: buttonInset,
            right: buttonInset,
            bottom: 0,
            child: _StatusButton(mediaObj),
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

  _FavoriteButton(this.media);

  @override
  __FavoriteButtonState createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.media.isFavourite ? Icons.favorite : Icons.favorite_border,
        color: Theme.of(context).dividerColor,
      ),
      onPressed: () => Provider.of<MediaItem>(context, listen: false)
          .toggleFavourite(widget.media.mediaId, widget.media.type)
          .then((ok) {
        if (ok)
          setState(
            () => widget.media.isFavourite = !widget.media.isFavourite,
          );
      }),
    );
  }
}

class _StatusButton extends StatefulWidget {
  final MediaData media;

  _StatusButton(this.media);

  @override
  __StatusButtonState createState() => __StatusButtonState();
}

class __StatusButtonState extends State<_StatusButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
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
    );
  }
}
