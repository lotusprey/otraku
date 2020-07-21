import 'package:flutter/material.dart';
import 'package:otraku/models/list_entry.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/media_list.dart';
import 'package:otraku/tools/navigation/custom_header_delegate.dart';
import 'package:otraku/tools/navigation/headline_header.dart';
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
    setState(() => _isLoading = true);

    if (!_collection.isLoaded) {
      await _collection.fetchMediaListCollection();
    }

    final tuple = _collection.getData(-1, null);
    _listNames = tuple.item1;
    _listEntries = tuple.item2;

    _segmentedControlPairs = {'All': -1};
    for (int i = 0; i < _listNames.length; i++) {
      _segmentedControlPairs[_listNames[i]] = i;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  //Clear output settings
  void _clear() {
    setState(() => _searchValue = null);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const WaveBarLoader()
        : _listNames.length > 0
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
                    delegate: CustomHeaderDelegate(
                      context: context,
                      updateSegmentedControl: (value) => setState(() {
                        _listIndex = value;
                        //TODO
                      }),
                      segmentedControlPairs: _segmentedControlPairs,
                      searchActivate: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => SearchPage(
                            search: (value) =>
                                setState(() => _searchValue = value),
                            text: _searchValue,
                          ),
                        ),
                      ),
                      searchDeactivate: _clear,
                      isSearchActive: _searchValue != null,
                      filterActivate: () {},
                      filterDeactivate: () {},
                      isFilterActive: false,
                      sort: () {},
                      refresh: () {
                        _clear();
                        _collection.unload();
                        _load();
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 15),
                  ),
                  ..._listBuilder(),
                ],
              )
            : Center(
                child: Text(
                  'No ${_collection.name} results',
                  style: _palette.titleSmall,
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
                style: _palette.titleInactive,
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

    // for (int i = 0; i < _listNames.length; i++) {}
    // if (_listIndex != -1) {
    //   List<ListEntry> entries;

    //   if (_searchValue == null) {
    //     entries = _listEntries[_listIndex];
    //   } else {
    //     entries = [];
    //     for (ListEntry entry in _listEntries[_listIndex]) {
    //       if (entry.title.toLowerCase().contains(_searchValue)) {
    //         entries.add(entry);
    //       }
    //     }
    //   }

    //   if (entries.length != 0) {
    //     return [
    //       SliverToBoxAdapter(
    //         child: Padding(
    //           padding: padding,
    //           child: Text(
    //             _listNames[_listIndex],
    //             style: _palette.titleInactive,
    //           ),
    //         ),
    //       ),
    //       SliverPadding(
    //         padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
    //         sliver: MediaList(
    //           entries: entries,
    //           scoreFormat: _scoreFormat,
    //           name: _listNames[_listIndex],
    //         ),
    //       ),
    //     ];
    //   }

    //   return [
    //     SliverFillRemaining(
    //       child: Center(
    //         child: Text(
    //           'No compatible entries',
    //           style: _palette.titleSmall,
    //         ),
    //       ),
    //     ),
    //   ];
    // }

    // List<Widget> lists = [];
    // for (int i = 0; i < _listNames.length; i++) {
    //   List<ListEntry> entries;

    //   if (_searchValue == null) {
    //     entries = _listEntries[i];
    //   } else {
    //     entries = [];
    //     for (ListEntry entry in _listEntries[i]) {
    //       if (entry.title.toLowerCase().contains(_searchValue)) {
    //         entries.add(entry);
    //       }
    //     }
    //   }

    //   if (entries.length != 0) {
    //     lists
    //       ..add(
    //         SliverToBoxAdapter(
    //           child: Padding(
    //             padding: padding,
    //             child: Text(
    //               _listNames[i],
    //               style: _palette.titleInactive,
    //             ),
    //           ),
    //         ),
    //       )
    //       ..add(
    //         SliverPadding(
    //           padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
    //           sliver: MediaList(
    //             entries: entries,
    //             scoreFormat: _scoreFormat,
    //             name: _listNames[i],
    //           ),
    //         ),
    //       );
    //   }
    // }

    // if (lists.length == 0) {
    //   return [
    //     SliverFillRemaining(
    //       child: Center(
    //         child: Text(
    //           'No compatible entries',
    //           style: _palette.titleSmall,
    //         ),
    //       ),
    //     ),
    //   ];
    // }

    // return lists;
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
