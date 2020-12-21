import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/models/page_data/media_overview.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/models/transparent_image.dart';

class MediaPageHeader implements SliverPersistentHeaderDelegate {
  final MediaOverview media;
  final double coverWidth;
  final double coverHeight;
  final double minHeight = Config.MATERIAL_TAP_TARGET_SIZE + 10;
  final double maxHeight;
  final String imageUrl;

  MediaPageHeader({
    @required this.media,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.maxHeight,
    @required this.imageUrl,
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
          if (media?.banner != null)
            FadeInImage.memoryNetwork(
              image: media.banner,
              placeholder: transparentImage,
              fadeInDuration: Config.FADE_DURATION,
              fit: BoxFit.cover,
            ),
          Container(
            padding: const EdgeInsets.only(
              top: Config.MATERIAL_TAP_TARGET_SIZE,
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
                  Hero(
                    tag: imageUrl,
                    child: Container(
                      height: coverHeight,
                      width: coverWidth,
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(imageUrl, fit: BoxFit.cover),
                            if (media != null)
                              GestureDetector(
                                child: Image.network(
                                  media.cover,
                                  fit: BoxFit.cover,
                                ),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (ctx) => PopUpAnimation(
                                    ImageTextDialog(
                                      text: media.preferredTitle,
                                      image: Image.network(
                                        media.cover,
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
                  if (media != null)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              media.preferredTitle,
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
                          const Flexible(
                            child: SizedBox(height: 60),
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
                media != null
                    ? FavoriteButton(media, shrinkPercentage)
                    : const SizedBox(),
              ],
            ),
          ),
          if (media != null)
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
  final MediaOverview media;
  final double width;

  _StatusButton(this.media, this.width);

  @override
  __StatusButtonState createState() => __StatusButtonState();
}

class __StatusButtonState extends State<_StatusButton> {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        child: RaisedButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: Config.BORDER_RADIUS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.media.status == null ? Icons.add : Icons.edit,
                size: Styles.ICON_SMALL,
                color: Theme.of(context).backgroundColor,
              ),
              const SizedBox(width: 10),
              Text(
                  widget.media.entryStatus == null
                      ? 'Add'
                      : listStatusSpecification(
                          widget.media.entryStatus,
                          widget.media.browsable == Browsable.anime,
                        ),
                  style: Theme.of(context).textTheme.button),
            ],
          ),
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => EditEntryPage(
                widget.media.id,
                (status) => setState(() => widget.media.entryStatus = status),
              ),
            ),
          ),
        ),
      );
}
