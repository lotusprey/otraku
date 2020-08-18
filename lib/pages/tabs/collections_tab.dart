import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/models/list_entry.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/navigation/media_control_header.dart';
import 'package:otraku/tools/navigation/headline_header.dart';
import 'package:otraku/tools/overlays/collection_sort_modal_sheet.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
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
  Map<String, dynamic> _filters = {'sort': 'SCORE_DESC'};

  //Data
  List<String> _listNames = [];
  List<List<ListEntry>> _listEntries = [];
  Map<String, Object> _segmentedControlPairs;

  //Output settings
  String _searchValue;
  int _listIndex = -1;
  bool _isLoading = true;
  bool _didChangeDependencies = false;
  Palette _palette;

  //Load data
  void _load() async {
    if (!_collection.isLoaded) {
      setState(() => _isLoading = true);
      await _collection.fetchMediaListCollection(_filters);
    }

    _setData();

    _segmentedControlPairs = {'All': -1};
    for (int i = 0; i < _listNames.length; i++) {
      _segmentedControlPairs[_listNames[i]] = i;
    }

    if (mounted && _isLoading == true) {
      setState(() => _isLoading = false);
    }
  }

  //Fill lists
  void _setData() {
    final tuple = _collection.getData(_listIndex, _searchValue);

    if (tuple == null) {
      _listNames = [];
      _listEntries = [];
      return;
    }

    _listNames = tuple.item1;
    _listEntries = tuple.item2;
  }

  //Clear output settings
  void _clear({bool seach = false, bool index = false}) {
    if (seach) {
      _searchValue = null;
    }
    if (index) {
      _listIndex = -1;
    }
  }

  //Refresh data
  void _refresh() {
    _clear(seach: true, index: true);
    _collection.unload();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const WaveBarLoader()
        : _collection.names.length > 0
            ? CustomScrollView(
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
                      headline: '${_collection.name} List',
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    floating: true,
                    delegate: MediaControlHeader(
                      context: context,
                      updateSegmentedControl: (value) => setState(() {
                        _listIndex = value;
                        _setData();
                      }),
                      segmentedControlPairs: _segmentedControlPairs,
                      searchActivate: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => SearchPage(
                            search: (value) => setState(() {
                              _searchValue = value;
                              _setData();
                            }),
                            text: _searchValue,
                          ),
                        ),
                      ),
                      searchDeactivate: () => setState(() {
                        _clear(seach: true);
                        _setData();
                      }),
                      isSearchActive: _searchValue != null,
                      filterActivate: () {},
                      filterDeactivate: () {},
                      isFilterActive: false,
                      sort: () => showModalBottomSheet(
                        context: context,
                        builder: (ctx) => CollectionSortModalSheet(_filters),
                        backgroundColor: Colors.transparent,
                      ),
                      refresh: _refresh,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 15),
                  ),
                  ..._listBuilder(),
                ],
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No ${_collection.name} results',
                      style: _palette.titleSmall,
                    ),
                    IconButton(
                      icon: const Icon(LineAwesomeIcons.retweet),
                      color: _palette.faded,
                      iconSize: Palette.ICON_MEDIUM,
                      onPressed: _refresh,
                    ),
                  ],
                ),
              );
  }

  //Return filtered lists to output on the screen
  List<Widget> _listBuilder() {
    List<Widget> widgets = [];
    for (int i = 0; i < _listNames.length; i++) {
      widgets
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _listNames[i],
                style: _palette.titleContrasted,
              ),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
            sliver: MediaList(
              entries: _listEntries[i],
              scoreFormat: _scoreFormat,
              name: _listNames[i],
            ),
          ),
        );
    }
    return widgets;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isAnimeCollection) {
      _collection = Provider.of<AnimeCollection>(context);
    } else {
      _collection = Provider.of<MangaCollection>(context);
    }

    if (!_didChangeDependencies) {
      _load();
      _palette = Provider.of<Theming>(context, listen: false).palette;
      _scoreFormat =
          Provider.of<AnimeCollection>(context, listen: false).scoreFormat;
      _didChangeDependencies = true;
    }
  }
}
