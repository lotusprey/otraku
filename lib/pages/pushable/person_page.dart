import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/models/page_data/person_data.dart';
import 'package:otraku/models/sample_data/connection.dart';
import 'package:otraku/providers/page_item.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/favourite_button.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class PersonPage extends StatefulWidget {
  final int id;
  final Object tag;
  final Browsable type;

  PersonPage(this.id, this.tag, this.type);

  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  static const _space = SizedBox(height: 10);

  bool _isLoading = true;
  bool _showPrimaryResults = true;
  PersonData _person;

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
                          person: _person,
                          coverWidth: coverWidth,
                          coverHeight: coverWidth / 0.7,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
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
                      if (_person.primaryConnections.length > 0 &&
                          _person.secondaryConnections.length > 0)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TitleSegmentedControl(
                              value: _showPrimaryResults,
                              pairs: widget.type == Browsable.characters
                                  ? {'Anime': true, 'Manga': false}
                                  : {
                                      'Voice Acting': true,
                                      'Staff Roles': false,
                                    },
                              onNewValue: (value) =>
                                  setState(() => _showPrimaryResults = value),
                              onSameValue: (_) {},
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: ViewConfig.PADDING,
                        sliver: _MediaConnectionGrid(
                          _showPrimaryResults
                              ? _person.primaryConnections
                              : _person.secondaryConnections,
                        ),
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
    final func = widget.type == Browsable.characters
        ? Provider.of<PageItem>(context, listen: false).fetchCharacter
        : Provider.of<PageItem>(context, listen: false).fetchStaff;
    func(widget.id).then((person) {
      _person = person;
      _showPrimaryResults =
          _person.primaryConnections.length == 0 ? false : true;
      setState(() => _isLoading = false);
    });
  }
}

class _MediaConnectionGrid extends StatelessWidget {
  final List<Connection> media;

  _MediaConnectionGrid(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => _MediaConnectionTile(media[index]),
        childCount: media.length,
      ),
      itemExtent: 110,
    );
  }
}

class _MediaConnectionTile extends StatelessWidget {
  final Connection media;

  _MediaConnectionTile(this.media);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: ViewConfig.BORDER_RADIUS,
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: MediaIndexer(
                itemType: media.browsable,
                id: media.id,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 65,
                        height: 100,
                        child: ClipRRect(
                          child:
                              Image.network(media.imageUrl, fit: BoxFit.cover),
                          borderRadius: ViewConfig.BORDER_RADIUS,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  media.title,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Text(
                                media.text,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (media.others.length > 0)
              Expanded(
                child: MediaIndexer(
                  id: media.others[0].id,
                  itemType: media.others[0].browsable,
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    media.others[0].title,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Text(
                                  media.others[0].text,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          height: 100,
                          child: ClipRRect(
                            child: Image.network(
                              media.others[0].imageUrl,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: ViewConfig.BORDER_RADIUS,
                          ),
                        ),
                      ],
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

class _Header implements SliverPersistentHeaderDelegate {
  final PersonData person;
  final double coverWidth;
  final double coverHeight;

  _Header({
    @required this.person,
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
    final image = Image.network(person.imageUrl, fit: BoxFit.cover);

    return Container(
      width: double.infinity,
      height: maxExtent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: ViewConfig.MATERIAL_TAP_TARGET_SIZE + 10,
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: ViewConfig.BORDER_RADIUS,
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
