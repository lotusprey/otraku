import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/models/media_overview.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/helpers/fn_helper.dart';

class MediaHeader extends StatelessWidget {
  final MediaOverview overview;
  final String imageUrl;
  final Future<bool> Function() toggleFavourite;

  MediaHeader({
    @required this.overview,
    @required this.imageUrl,
    @required this.toggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150;
    final coverHeight = coverWidth / 0.7;
    final bannerHeight =
        coverHeight * 0.6 + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    final height = bannerHeight + coverHeight * 0.6;

    return CustomSliverHeader(
      height: height,
      title: overview?.preferredTitle,
      actions: overview != null
          ? [
              _EditButton(overview, false),
              _FavouriteButton(overview, false, toggleFavourite),
            ]
          : null,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: overview?.banner != null
                    ? FadeInImage.memoryNetwork(
                        image: overview.banner,
                        placeholder: FnHelper.transparentImage,
                        fadeInDuration: Config.FADE_DURATION,
                        fit: BoxFit.cover,
                        height: bannerHeight,
                        width: double.infinity,
                      )
                    : Container(color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: height - bannerHeight),
            ],
          ),
          Positioned.fill(
            bottom: height - bannerHeight - 1,
            child: Container(
              height: bannerHeight - Config.MATERIAL_TAP_TARGET_SIZE,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
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
                            _EditButton(overview, true),
                            const SizedBox(width: 10),
                            _FavouriteButton(overview, true, toggleFavourite),
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
  Widget build(BuildContext context) => widget.full
      ? RaisedButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          clipBehavior: Clip.hardEdge,
          onPressed: onPressed,
          child: Icon(
            widget.overview.entryStatus == null ? Icons.add : Icons.edit,
            color: Theme.of(context).backgroundColor,
          ),
        )
      : IconButton(
          onPressed: onPressed,
          icon: Icon(
            widget.overview.entryStatus == null ? Icons.add : Icons.edit,
            color: Theme.of(context).dividerColor,
          ),
        );

  void onPressed() => BrowseIndexer.openEditPage(
        widget.overview.id,
        (status) => setState(() => widget.overview.entryStatus = status),
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
  Widget build(BuildContext context) => widget.full
      ? RaisedButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          color: Theme.of(context).errorColor,
          clipBehavior: Clip.hardEdge,
          onPressed: onPressed,
          child: Icon(
            widget.overview.isFavourite
                ? Icons.favorite
                : Icons.favorite_border,
            color: Theme.of(context).backgroundColor,
          ),
        )
      : IconButton(
          onPressed: onPressed,
          icon: Icon(
            widget.overview.isFavourite
                ? Icons.favorite
                : Icons.favorite_border,
            color: Theme.of(context).dividerColor,
          ),
        );

  void onPressed() => widget.toggle().then((ok) => ok
      ? setState(
          () => widget.overview.isFavourite = !widget.overview.isFavourite,
        )
      : null);
}
