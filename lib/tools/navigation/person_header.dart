import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/models/anilist/person_model.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class PersonHeader extends StatelessWidget {
  final PersonModel person;
  final int personId;
  final String imageUrl;
  final Future<bool> Function() toggleFavourite;

  PersonHeader({
    this.person,
    this.personId,
    this.imageUrl,
    this.toggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width * 0.35;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _PersonHeader(
        person: person,
        personId: personId,
        coverWidth: coverWidth,
        coverHeight: coverWidth / 0.7,
        imageUrl: imageUrl,
        toggleFavourite: toggleFavourite,
      ),
    );
  }
}

class _PersonHeader implements SliverPersistentHeaderDelegate {
  final PersonModel person;
  final int personId;
  final double coverWidth;
  final double coverHeight;
  final String imageUrl;
  final Future<bool> Function() toggleFavourite;

  _PersonHeader({
    @required this.person,
    @required this.personId,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.imageUrl,
    @required this.toggleFavourite,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);
    final image = Image.network(imageUrl, fit: BoxFit.cover);

    return Container(
      height: maxExtent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: Config.MATERIAL_TAP_TARGET_SIZE + 10,
              left: 10,
              right: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: GestureDetector(
                    child: Hero(
                      tag: personId,
                      child: ClipRRect(
                        borderRadius: Config.BORDER_RADIUS,
                        child: Container(
                          width: coverWidth,
                          height: coverHeight,
                          child: image,
                        ),
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => PopUpAnimation(ImageDialog(image)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).backgroundColor,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                  if (person != null) ...[
                    if (shrinkPercentage > 0.5)
                      Flexible(
                        child: Opacity(
                          opacity: 1 < shrinkPercentage ? 1 : shrinkPercentage,
                          child: Text(
                            person.fullName,
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    FavoriteButton(
                      favourites: person.favourites,
                      isFavourite: person.isFavourite,
                      shrinkPercentage: shrinkPercentage,
                      toggle: toggleFavourite,
                    ),
                  ] else
                    const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => coverHeight + Config.MATERIAL_TAP_TARGET_SIZE + 10;

  @override
  double get minExtent => Config.MATERIAL_TAP_TARGET_SIZE;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}

class PersonInfo extends StatelessWidget {
  final PersonModel person;

  PersonInfo(this.person);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: Config.PADDING,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              person.fullName,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
            Text(
              person.altNames.join(', '),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (person.description.isNotEmpty)
              InputFieldStructure(
                title: 'Description',
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Text(
                      person.description,
                      style: Theme.of(context).textTheme.bodyText1,
                      overflow: TextOverflow.fade,
                      maxLines: 8,
                    ),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => PopUpAnimation(
                      TextDialog(
                        title: 'Description',
                        text: person.description,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
