import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/text_grid.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  static SizedBox _sizedBox = const SizedBox(height: 20);

  Palette _palette;
  TextGrid _genreGrid;
  TextGrid _tagGrid;

  List<String> _genreIn;
  List<String> _genreNotIn;
  List<String> _tagIn;
  List<String> _tagNotIn;

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;

    _genreIn = Provider.of<ExplorableMedia>(context, listen: false).genreIn;
    _genreNotIn =
        Provider.of<ExplorableMedia>(context, listen: false).genreNotIn;
    _tagIn = Provider.of<ExplorableMedia>(context, listen: false).tagIn;
    _tagNotIn = Provider.of<ExplorableMedia>(context, listen: false).tagNotIn;

    _genreGrid = TextGrid(
      options: Provider.of<ExplorableMedia>(context, listen: false).genres,
      optionIn: _genreIn,
      optionNotIn: _genreNotIn,
    );

    _tagGrid = TextGrid(
      optionsDual: Provider.of<ExplorableMedia>(context, listen: false).tags,
      optionIn: _tagIn,
      optionNotIn: _tagNotIn,
    );
  }

  List<Widget> _gridSection(String name, TextGrid grid) {
    if (grid == null) {
      return [];
    }

    final result = [
      _sizedBox,
      Text(name, style: _palette.smallTitle),
      _sizedBox,
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
            Provider.of<ExplorableMedia>(context, listen: false)
                .setGenreTagFilters(
              newGenreIn: _genreIn,
              newGenreNotIn: _genreNotIn,
              newTagIn: _tagIn,
              newTagNotIn: _tagNotIn,
            );
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
