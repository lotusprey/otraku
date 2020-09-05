import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/text_grid.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  final Function loadMedia;

  FilterPage({
    @required this.loadMedia,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  static SizedBox _sizedBox = const SizedBox(height: 20);

  Palette _palette;
  TextGrid _genreGrid;
  TextGrid _tagGrid;

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;

    // _genreIn = widget.filters['genre_in'] ?? [];
    // _genreNotIn = widget.filters['genre_not_in'] ?? [];

    _genreGrid = TextGrid(
      options: Provider.of<ExplorableMedia>(context, listen: false).genres,
      optionIn: Provider.of<ExplorableMedia>(context, listen: false).genreIn,
      optionNotIn:
          Provider.of<ExplorableMedia>(context, listen: false).genreNotIn,
    );

    _tagGrid = TextGrid(
      optionsDual: Provider.of<ExplorableMedia>(context, listen: false).tags,
      optionIn: Provider.of<ExplorableMedia>(context, listen: false).tagIn,
      optionNotIn:
          Provider.of<ExplorableMedia>(context, listen: false).tagNotIn,
    );

    // Provider.of<ExplorableMedia>(context, listen: false)
    //     .fetchGenres()
    //     .then((data) => setState(() {
    //           _genreGrid = TextGrid(
    //             optionsDual: data.map((g) => Tuple(g, null)).toList(),
    //             optionIn: _genreIn,
    //             optionNotIn: _genreNotIn,
    //           );
    //         }));

    // _tagIn = widget.filters['tag_in'] ?? [];
    // _tagNotIn = widget.filters['tag_not_in'] ?? [];

    // Provider.of<ExplorableMedia>(context, listen: false)
    //     .fetchTags()
    //     .then((data) => setState(() {
    //           List<Tuple<String, String>> tags = [];

    //           for (Map<String, String> value in data) {
    //             tags.add(Tuple(value['name'], value['description']));
    //           }

    //           _tagGrid = TextGrid(
    //             optionsDual: tags,
    //             optionIn: _tagIn,
    //             optionNotIn: _tagNotIn,
    //           );
    //         }));
  }

  List<Widget> _gridSection(String name, TextGrid grid) {
    if (grid == null) {
      return [];
    }

    final result = [
      widget._sizedBox,
      Text(name, style: _palette.smallTitle),
      widget._sizedBox,
      grid,
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: _palette.background,
        actionsForegroundColor: _palette.accent,
        middle: Text('Filters', style: _palette.contrastedTitle),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.done,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () {
            // if (_genreIn.length == 0) {
            //   widget.filters.remove('genre_in');
            // } else {
            //   widget.filters['genre_in'] = _genreIn;
            // }

            // if (_genreNotIn.length == 0) {
            //   widget.filters.remove('genre_not_in');
            // } else {
            //   widget.filters['genre_not_in'] = _genreNotIn;
            // }

            // if (_tagIn.length == 0) {
            //   widget.filters.remove('tag_in');
            // } else {
            //   widget.filters['tag_in'] = _tagIn;
            // }

            // if (_tagNotIn.length == 0) {
            //   widget.filters.remove('tag_not_in');
            // } else {
            //   widget.filters['tag_not_in'] = _tagNotIn;
            // }

            widget.loadMedia();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            ..._gridSection('Genres', _genreGrid),
            ..._gridSection('Tags', _tagGrid),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
