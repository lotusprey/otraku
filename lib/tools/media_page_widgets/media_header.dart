import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/models/media_item_data.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/tools/overlays/edit_media_sheet.dart';

class MediaHeader implements SliverPersistentHeaderDelegate {
  //Data
  final MediaItemData mediaObj;

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
    final fadeColor =
        palette.background.withAlpha((shrinkPercentage * 255).round());

    return Container(
      width: double.infinity,
      height: _maxExtent,
      color: palette.primary,
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
                  palette.background.withAlpha(130),
                  palette.background,
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
                      borderRadius: BorderRadius.circular(5),
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
                            style: palette.contrastedTitle,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        if (mediaObj.nextEpisode != null)
                          Flexible(
                            child: Text(
                              'Ep ${mediaObj.nextEpisode} in ${mediaObj.timeUntilAiring}',
                              style: palette.smallTitle,
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
                                          size: Palette.ICON_SMALL,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      mediaObj.popularity.toString(),
                                      style: palette.smallTitle,
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
                                          size: Palette.ICON_SMALL,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      mediaObj.favourites.toString(),
                                      style: palette.smallTitle,
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
                    size: Palette.ICON_MEDIUM,
                    color: palette.contrast,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _FavoriteButton(palette, mediaObj),
              ],
            ),
          ),
          Positioned(
            left: buttonInset,
            right: buttonInset,
            bottom: 0,
            child: _StatusButton(palette, mediaObj.mediaListStatus),
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
  final Palette palette;
  final MediaItemData mediaObj;

  _FavoriteButton(this.palette, this.mediaObj);

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
        color: widget.palette.contrast,
      ),
      onPressed: () => widget.mediaObj
          .toggleFavourite(context)
          .then((value) => setState(() {})),
    );
  }
}

class _StatusButton extends StatefulWidget {
  final Palette palette;
  final MediaListStatus mediaListStatus;

  _StatusButton(this.palette, this.mediaListStatus);

  @override
  __StatusButtonState createState() => __StatusButtonState();
}

class __StatusButtonState extends State<_StatusButton> {
  MediaListStatus status;

  void _update(ListEntryUserData data) =>
      setState(() => status = data.mediaListStatus);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: widget.palette.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            status == MediaListStatus.None ? Icons.add : Icons.edit,
            size: Palette.ICON_SMALL,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(status == MediaListStatus.None ? 'Add' : describeEnum(status),
              style: widget.palette.buttonText),
        ],
      ),
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (ctx) => EditMediaSheet(_update),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    status = widget.mediaListStatus;
  }
}
