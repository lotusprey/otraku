import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/models/media_overview.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/models/transparent_image.dart';

class MediaHeader implements SliverPersistentHeaderDelegate {
  final MediaOverview overview;
  final double coverWidth;
  final double coverHeight;
  final double maxHeight;
  final String imageUrl;
  final Future<bool> Function() toggleFavourite;

  MediaHeader({
    @required this.overview,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.maxHeight,
    @required this.imageUrl,
    @required this.toggleFavourite,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage =
        shrinkOffset < maxHeight ? shrinkOffset / maxHeight : 1.0;

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
          if (overview?.banner != null)
            FadeInImage.memoryNetwork(
              image: overview.banner,
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
                      width: coverWidth,
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(imageUrl, fit: BoxFit.cover),
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
                              style: Theme.of(context).textTheme.headline3,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          if (overview.nextEpisode != null)
                            Flexible(
                              child: Text(
                                'Ep ${overview.nextEpisode} in ${overview.timeUntilAiring}',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _EditButton(overview, true),
                                _FavouriteButton(
                                  overview,
                                  true,
                                  toggleFavourite,
                                ),
                              ],
                            ),
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).dividerColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (shrinkPercentage > 0.4)
                    Expanded(
                      child: Opacity(
                        opacity: shrinkPercentage,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                overview.preferredTitle,
                                style: Theme.of(context).textTheme.headline6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _EditButton(overview, false),
                            _FavouriteButton(overview, false, toggleFavourite),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

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

class _EditButton extends StatefulWidget {
  final MediaOverview overview;
  final bool full;

  _EditButton(this.overview, this.full);

  @override
  __EditButtonState createState() => __EditButtonState();
}

class __EditButtonState extends State<_EditButton> {
  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      widget.overview.entryStatus == null ? Icons.add : Icons.edit,
      color: Theme.of(context).dividerColor,
    );

    return widget.full
        ? RaisedButton(
            clipBehavior: Clip.hardEdge,
            onPressed: onPressed,
            child: icon,
          )
        : IconButton(
            icon: icon,
            onPressed: onPressed,
          );
  }

  void onPressed() => Get.to(
        EditEntryPage(
          widget.overview.id,
          (status) => setState(() => widget.overview.entryStatus = status),
        ),
        binding: BindingsBuilder.put(
          () => Entry()..fetchEntry(widget.overview.id),
        ),
      );
}

class _FavouriteButton extends StatefulWidget {
  final MediaOverview overview;
  final bool full;
  final Future<bool> Function() toggle;

  _FavouriteButton(this.overview, this.full, this.toggle);

  @override
  __FavouriteButtonState createState() => __FavouriteButtonState();
}

class __FavouriteButtonState extends State<_FavouriteButton> {
  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      widget.overview.isFavourite ? Icons.favorite : Icons.favorite_border,
      color: Theme.of(context).dividerColor,
    );

    return widget.full
        ? RaisedButton(
            color: Theme.of(context).errorColor,
            clipBehavior: Clip.hardEdge,
            onPressed: onPressed,
            child: icon,
          )
        : IconButton(icon: icon, onPressed: onPressed);
  }

  void onPressed() => widget.toggle().then((ok) => ok
      ? setState(
          () => widget.overview.isFavourite = !widget.overview.isFavourite,
        )
      : null);
}
