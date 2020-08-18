import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/multichild_layouts/large_tile_grid.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/tools/navigation/media_control_header.dart';
import 'package:otraku/tools/navigation/headline_header.dart';
import 'package:otraku/tools/overlays/explore_sort_modal_sheet.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
import 'package:provider/provider.dart';
import 'package:otraku/providers/all_media.dart';

class ExploreTab extends StatefulWidget {
  final ScrollController scrollCtrl;

  ExploreTab(this.scrollCtrl);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  //Query settings
  Map<String, dynamic> _filters = {
    'page': 1,
    'perPage': 30,
    'type': 'ANIME',
    'sort': describeEnum(MediaSort.TRENDING_DESC),
    'id_not_in': [],
  };

  //Data
  List<Map<String, dynamic>> _data = [];

  //Output settings
  LargeTileConfiguration _tileConfig;
  bool _isLoading = true;
  bool _canIncrementPage = true;
  bool _didChangeDependencies = false;

  //Load data
  Future<void> _load({incrementPage = false}) async {
    setState(() => _isLoading = true);

    if (incrementPage) {
      _filters['page']++;
    } else {
      _filters['page'] = 1;
      _filters['id_not_in'] = [];
      _canIncrementPage = true;
      _data = [];
    }

    final data = await Provider.of<AllMedia>(context, listen: false)
        .fetchMedia(_filters);

    if (data.length > 0) {
      final idNotIn = _filters['id_not_in'];

      for (Map<String, dynamic> m in data) {
        idNotIn.add(m['id']);
      }

      _data += data;
    } else {
      _canIncrementPage = false;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  //Listens for the user reaching the bottom of the page
  void _onScroll() async {
    if (widget.scrollCtrl.position.pixels ==
            widget.scrollCtrl.position.maxScrollExtent &&
        _canIncrementPage) {
      await _load(incrementPage: true);
    }
  }

  //Configure 'search' variable for the query settings
  void _search(String search) {
    if (search == _filters['search']) {
      return;
    }

    if (search != '') {
      _filters['search'] = search;
      _filters.remove('sort');
    } else {
      if (!_filters.containsKey('search')) {
        return;
      }
      _filters.remove('search');
      _filters['sort'] = describeEnum(MediaSort.TRENDING_DESC);
    }

    _load();
  }

  //Clear output settings
  void _clear({bool search = false, bool filters = false}) {
    if (search) {
      _filters.remove('search');
      _filters['sort'] = describeEnum(MediaSort.TRENDING_DESC);
    }

    if (filters) {
      _filters.remove('genre_in');
      _filters.remove('genre_not_in');
      _filters.remove('tag_in');
      _filters.remove('tag_not_in');
    }

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: widget.scrollCtrl,
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: false,
          floating: false,
          delegate: HeadlineHeader(context: context, headline: 'Explore'),
        ),
        SliverPersistentHeader(
          pinned: false,
          floating: true,
          delegate: MediaControlHeader(
            context: context,
            updateSegmentedControl: (value) {
              _filters['type'] = value as String;
              _load();
            },
            segmentedControlPairs: {
              'Anime': 'ANIME',
              'Manga': 'MANGA',
            },
            searchActivate: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (ctx) => SearchPage(
                  search: _search,
                  text: _filters['search'],
                ),
              ),
            ),
            searchDeactivate: () => _clear(search: true),
            isSearchActive: _filters.containsKey('search'),
            filterActivate: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (ctx) => FilterPage(
                  loadMedia: _load,
                  filters: _filters,
                ),
              ),
            ),
            filterDeactivate: () => _clear(filters: true),
            isFilterActive: _filters.containsKey('genre_in') ||
                _filters.containsKey('genre_not_in') ||
                _filters.containsKey('tag_in') ||
                _filters.containsKey('tag_not_in'),
            refresh: () => _clear(search: true, filters: true),
            sort: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => ExploreSortModalSheet(_filters, _load),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        _data.length > 0
            ? SliverPadding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                sliver: LargeTileGrid(data: _data, tileConfig: _tileConfig),
              )
            : _isLoading
                ? const SliverFillRemaining(
                    child: WaveBarLoader(),
                  )
                : SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No results',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
        if (_data.length > 0)
          _isLoading
              ? const SliverFillRemaining(
                  child: WaveBarLoader(),
                )
              : const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didChangeDependencies) {
      widget.scrollCtrl.addListener(_onScroll);

      _tileConfig = Provider.of<ViewConfig>(
        context,
        listen: false,
      ).tileConfiguration;

      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_onScroll);
    super.dispose();
  }
}
