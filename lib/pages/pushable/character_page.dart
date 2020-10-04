import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/character_data.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class CharacterPage extends StatefulWidget {
  final int id;
  final Object tag;

  CharacterPage(this.id, this.tag);

  @override
  _CharacterPageState createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  bool _isLoading = true;
  CharacterData _character;

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width * 0.35;

    return Scaffold(
      body: Hero(
        tag: widget.tag,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).backgroundColor,
            child: !_isLoading
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: _Header(
                          character: _character,
                          coverWidth: coverWidth,
                          coverHeight: coverWidth / 0.7,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InputFieldStructure(
                            title: 'Description',
                            body: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: ViewConfig.RADIUS,
                                ),
                                child: Text(
                                  _character.description,
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
                                    text: _character.description,
                                  ),
                                ),
                              ),
                            ),
                            enforceHeight: false,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(height: 500),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PageItem>(context, listen: false)
        .fetchCharacter(widget.id)
        .then((character) {
      _character = character;
      setState(() => _isLoading = false);
    });
  }
}

class _Header implements SliverPersistentHeaderDelegate {
  final CharacterData character;
  final double coverWidth;
  final double coverHeight;

  _Header({
    @required this.character,
    @required this.coverWidth,
    @required this.coverHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);
    final image = Image.network(character.imageUrl, fit: BoxFit.cover);

    return Container(
      width: double.infinity,
      height: maxExtent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: coverHeight.floor(),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: ViewConfig.RADIUS,
                      child: Container(
                        width: coverWidth,
                        height: coverHeight,
                        child: image,
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => PopUpAnimation(
                        ImageDialog(image),
                      ),
                      barrierDismissible: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 60,
                  child: Text(
                    character.fullName,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                Flexible(
                  flex: 60,
                  child: Text(
                    character.altNames.join(', '),
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 3,
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
                    offset: Offset(0, 3),
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
                  FavoriteButton(character, shrinkPercentage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent =>
      coverHeight + ViewConfig.MATERIAL_TAP_TARGET_SIZE + 120;

  @override
  double get minExtent => ViewConfig.MATERIAL_TAP_TARGET_SIZE;

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
