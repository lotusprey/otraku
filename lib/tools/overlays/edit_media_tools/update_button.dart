import 'package:flutter/material.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:provider/provider.dart';

class UpdateButton extends StatefulWidget {
  final Palette palette;
  final EntryUserData oldData;
  final EntryUserData newData;
  final Function(EntryUserData) update;

  UpdateButton({
    @required this.palette,
    @required this.oldData,
    @required this.newData,
    @required this.update,
  });

  @override
  _UpdateButtonState createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
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
                Provider.of<MediaItem>(context, listen: false)
                    .updateUserData(widget.newData)
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
