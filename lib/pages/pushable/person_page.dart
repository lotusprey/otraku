import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/page_data/person_data.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/multichild_layouts/media_connection_grid.dart';
import 'package:otraku/tools/title_segmented_control.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class PersonPage extends StatefulWidget {
  final int id;
  final String tagImageUrl;
  final Browsable type;

  PersonPage(this.id, this.tagImageUrl, this.type);

  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  static const _space = SizedBox(height: 10);

  Function(int, PersonData) loadFunc;
  PersonData _person;

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width * 0.35;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: _person != null
              ? CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: _Header(
                        person: _person,
                        coverWidth: coverWidth,
                        coverHeight: coverWidth / 0.7,
                        tagImageUrl: widget.tagImageUrl,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: ViewConfig.PADDING,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _space,
                            Text(
                              _person.fullName,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            Text(
                              _person.altNames.join(', '),
                              style: Theme.of(context).textTheme.bodyText1,
                              maxLines: 3,
                            ),
                            _space,
                            if (_person.description != null &&
                                _person.description != '')
                              InputFieldStructure(
                                title: 'Description',
                                body: GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: ViewConfig.BORDER_RADIUS,
                                    ),
                                    child: Text(
                                      _person.description,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      overflow: TextOverflow.fade,
                                      maxLines: 8,
                                    ),
                                  ),
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => PopUpAnimation(
                                      TextDialog(
                                        title: 'Description',
                                        text: _person.description,
                                      ),
                                    ),
                                  ),
                                ),
                                enforceHeight: false,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_person.leftConnections.length > 0 &&
                        _person.rightConnections.length > 0) ...[
                      SliverToBoxAdapter(child: _space),
                      SliverToBoxAdapter(
                        child: TitleSegmentedControl(
                          initialValue: _person.currentlyOnLeftPage,
                          pairs: widget.type == Browsable.characters
                              ? {'Anime': true, 'Manga': false}
                              : {
                                  'Voice Acting': true,
                                  'Staff Roles': false,
                                },
                          onNewValue: (onTheLeft) => setState(
                              () => _person.currentlyOnLeftPage = onTheLeft),
                          onSameValue: (_) {},
                          small: true,
                        ),
                      ),
                    ],
                    SliverPadding(
                      padding: ViewConfig.PADDING,
                      sliver: MediaConnectionGrid(
                        _person.connections,
                        () async {
                          if (_person.hasNextPage)
                            loadFunc(widget.id, _person)
                                .then((_) => setState(() {}));
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: _person.hasNextPage
                              ? const BlossomLoader()
                              : null,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).dividerColor,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Hero(
                        tag: widget.tagImageUrl,
                        child: Container(
                          width: coverWidth,
                          height: coverWidth / 0.7,
                          child: ClipRRect(
                            borderRadius: ViewConfig.BORDER_RADIUS,
                            child: Image.network(
                              widget.tagImageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadFunc = widget.type == Browsable.characters
        ? Provider.of<PageItem>(context, listen: false).fetchCharacter
        : Provider.of<PageItem>(context, listen: false).fetchStaff;

    loadFunc(widget.id, null).then((person) {
      if (mounted) setState(() => _person = person);
    });
  }
}

class _Header implements SliverPersistentHeaderDelegate {
  final PersonData person;
  final double coverWidth;
  final double coverHeight;
  final String tagImageUrl;

  _Header({
    @required this.person,
    @required this.coverWidth,
    @required this.coverHeight,
    @required this.tagImageUrl,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);
    final image = Image.network(person.imageUrl, fit: BoxFit.cover);

    return Container(
      height: maxExtent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: ViewConfig.MATERIAL_TAP_TARGET_SIZE + 10,
              left: 10,
              right: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: GestureDetector(
                    child: Hero(
                      tag: tagImageUrl,
                      child: ClipRRect(
                        borderRadius: ViewConfig.BORDER_RADIUS,
                        child: Container(
                          width: coverWidth,
                          height: coverHeight,
                          child: image,
                        ),
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
                  if (shrinkPercentage > 0.5)
                    Opacity(
                      opacity: min(1, shrinkPercentage),
                      child: Text(
                        person.fullName,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  FavoriteButton(person, shrinkPercentage),
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
      coverHeight + ViewConfig.MATERIAL_TAP_TARGET_SIZE + 10;

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
