import 'package:flutter/material.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';

class SaveButton extends StatefulWidget {
  final bool isAnime;
  final Palette palette;
  final EntryUserData oldData;
  final EntryUserData newData;
  final Function(EntryUserData) update;

  SaveButton({
    @required this.isAnime,
    @required this.palette,
    @required this.oldData,
    @required this.newData,
    @required this.update,
  });

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? IconButton(
            icon: const Icon(Icons.done),
            iconSize: Palette.ICON_MEDIUM,
            color: widget.palette.contrast,
            onPressed: () {
              if (widget.oldData.isSimilarTo(widget.newData)) {
                Navigator.of(context).pop();
              } else {
                setState(() => _isLoading = true);
                final CollectionProvider collection = widget.isAnime
                    ? Provider.of<AnimeCollection>(context, listen: false)
                    : Provider.of<MangaCollection>(context, listen: false);
                collection
                    .updateEntry(widget.oldData, widget.newData)
                    .then((ok) {
                  if (ok) widget.update(widget.newData);
                  Navigator.of(context).pop();
                });
              }
            },
          )
        : const BlossomLoader(size: 30);
  }
}
