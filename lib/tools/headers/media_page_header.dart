import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/media_data.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class MediaPageHeader implements SliverPersistentHeaderDelegate {
  //Data
  final MediaData media;

  //Output settings
  final double coverWidth;
  final double coverHeight;
  final double minHeight = ViewConfig.MATERIAL_TAP_TARGET_SIZE + 10;
  final double maxHeight;
  final String tagImageUrl;

  MediaPageHeader({
    @required this.media,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.maxHeight,
    @required this.tagImageUrl,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final transition = maxHeight * 4.0 / 5.0;
    final shrinkPercentage =
        shrinkOffset < transition ? shrinkOffset / transition : 1.0;
    final buttonMinWidth = MediaQuery.of(context).size.width - coverWidth - 30;
    final addition = MediaQuery.of(context).size.width - 100 - buttonMinWidth;

    return Container(
      height: maxHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Hero(
                      tag: tagImageUrl,
                      child: ClipRRect(
                        borderRadius: ViewConfig.BORDER_RADIUS,
                        child: Container(
                          height: coverHeight,
                          width: coverWidth,
                          child: media.cover,
                        ),
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
                FavoriteButton(media, shrinkPercentage),
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
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  TickerProvider get vsync => null;
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
          borderRadius: ViewConfig.BORDER_RADIUS,
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
              widget.media.id,
              (status) => setState(() => widget.media.status = status),
            ),
          ),
        ),
      ),
    );
  }
}
