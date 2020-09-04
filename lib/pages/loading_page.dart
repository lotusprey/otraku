import 'package:flutter/material.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  final Palette palette;

  LoadingPage(this.palette);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  int _loadStatus = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.palette.background,
      body: const Center(child: BlossomLoader()),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AnimeCollection>(context, listen: false)
        .fetchMediaListCollection()
        .then((_) => _validateStatus());
    Provider.of<MangaCollection>(context, listen: false)
        .fetchMediaListCollection()
        .then((_) => _validateStatus());
  }

  void _validateStatus() {
    _loadStatus++;
    if (_loadStatus == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TabManager()),
      );
    }
  }
}
