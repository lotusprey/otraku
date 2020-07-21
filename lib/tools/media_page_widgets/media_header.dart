import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/media_object.dart';
import 'package:otraku/providers/theming.dart';

class MediaHeader implements SliverPersistentHeaderDelegate {
  //Data
  final MediaObject mediaObj;

  //Output settings
  final Palette palette;
  final double coverWidth;
  final double coverHeight;
  double _minExtent;
  double _maxExtent;

  MediaHeader({
    @required this.palette,
    @required this.mediaObj,
    @required this.coverWidth,
    @required this.coverHeight,
    @required height,
  }) {
    _minExtent = 40;
    _maxExtent = height;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      width: double.infinity,
      height: _maxExtent,
      color: palette.primary,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (mediaObj.banner != null) mediaObj.banner,
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black38,
                  palette.background,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: Palette.ICON_MEDIUM,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    _FavoriteButton(mediaObj),
                  ],
                ),
                Container(
                  height: coverHeight,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          height: coverHeight,
                          width: coverWidth,
                          child: mediaObj.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(mediaObj.title, style: palette.titleClear),
                            if (mediaObj.nextEpisode != null)
                              Text(
                                'Ep ${mediaObj.nextEpisode} in ${mediaObj.timeUntilAiring}',
                                style: palette.titleSmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                RaisedButton(
                  color: palette.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        mediaObj.mediaListStatus == MediaListStatus.None
                            ? Icons.add
                            : Icons.edit,
                        size: Palette.ICON_SMALL,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                          mediaObj.mediaListStatus == MediaListStatus.None
                              ? 'Add'
                              : describeEnum(mediaObj.mediaListStatus),
                          style: palette.titleClear),
                    ],
                  ),
                  onPressed: () {},
                ),
              ],
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
  final MediaObject mediaObj;

  _FavoriteButton(this.mediaObj);

  @override
  __FavoriteButtonState createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.mediaObj.isFavourite ? Icons.favorite : Icons.favorite_border,
        size: Palette.ICON_MEDIUM,
        color: Colors.white,
      ),
      onPressed: () => widget.mediaObj
          .toggleFavourite(context)
          .then((value) => setState(() {})),
    );
  }
}
