import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/auth.dart';
import 'package:otraku/providers/collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/single_media_list.dart';
import 'package:otraku/tools/navigation/media_control_header.dart';
import 'package:otraku/tools/navigation/headline_header.dart';
import 'package:otraku/tools/overlays/collection_sort_sheet.dart';
import 'package:provider/provider.dart';

class CollectionsTab extends StatefulWidget {
  final ScrollController scrollCtrl;
  final bool isAnimeCollection;

  CollectionsTab({
    @required this.scrollCtrl,
    @required this.isAnimeCollection,
    @required key,
  }) : super(key: key);

  @override
  _CollectionsTabState createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  //Query settings
  Collection _collection;
  String _scoreFormat;

  //Data
  List<String> _names = [];
  List<List<ListEntryMediaData>> _entryLists = [];
  Map<String, Object> _segmentedControlPairs;

  Palette _palette;

  @override
  Widget build(BuildContext context) {
    if (_collection.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No ${_collection.collectionName} results',
              style: _palette.smallTitle,
            ),
            IconButton(
              icon: const Icon(LineAwesomeIcons.retweet),
              color: _palette.faded,
              iconSize: Palette.ICON_MEDIUM,
              onPressed: () {
                _collection.setFilters(listIndex: -1, search: '');
                _collection.fetchMediaListCollection();
              },
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: widget.scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: false,
          floating: false,
          delegate: HeadlineHeader(
            context: context,
            headline: '${_collection.collectionName} List',
          ),
        ),
        SliverPersistentHeader(
          pinned: false,
          floating: true,
          delegate: MediaControlHeader(
            context: context,
            updateSegmentedControl: (value) => setState(
              () => _collection.setFilters(listIndex: value as int),
            ),
            segmentedControlPairs: _segmentedControlPairs,
            searchActivate: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (ctx) => SearchPage(
                  search: (value) => _collection.setFilters(search: value),
                  text: _collection.search,
                ),
              ),
            ),
            searchDeactivate: () => _collection.setFilters(search: ''),
            isSearchActive: _collection.search != '',
            filterActivate: () {},
            filterDeactivate: () {},
            isFilterActive: false,
            sort: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => CollectionSortSheet(widget.isAnimeCollection),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            ),
            refresh: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: const SizedBox(height: 15),
        ),
        ..._listBuilder(),
      ],
    );
  }

  //Return selected lists to output on the screen
  List<Widget> _listBuilder() {
    if (_names.length == 0) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'No results to the current filters',
              style: _palette.smallTitle,
            ),
          ),
        ),
      ];
    }

    if (_names.length == 1) {
      return [
        SliverPadding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
          sliver: SingleMediaList(
            entries: _entryLists[0],
            scoreFormat: _scoreFormat,
            name: _names[0],
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    for (int i = 0; i < _names.length; i++) {
      widgets
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _names[i],
                style: _palette.contrastedTitle,
              ),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
            sliver: SingleMediaList(
              entries: _entryLists[i],
              scoreFormat: _scoreFormat,
              name: _names[i],
            ),
          ),
        );
    }
    return widgets;
  }

  @override
  void initState() {
    super.initState();
    _scoreFormat = Provider.of<Auth>(context, listen: false).scoreFormat;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;

    if (widget.isAnimeCollection) {
      _collection = Provider.of<AnimeCollection>(context);
    } else {
      _collection = Provider.of<MangaCollection>(context);
    }

    final tuple = _collection.lists();

    if (tuple == null) {
      _names = [];
      _entryLists = [];
      return;
    }

    _names = tuple.item1;
    _entryLists = tuple.item2;

    _segmentedControlPairs = {'All': -1};
    final allNames = _collection.names;
    for (int i = 0; i < allNames.length; i++) {
      _segmentedControlPairs[allNames[i]] = i;
    }
  }
}
