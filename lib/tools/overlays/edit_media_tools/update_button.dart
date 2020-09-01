import 'package:flutter/material.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
import 'package:provider/provider.dart';

class UpdateButton extends StatefulWidget {
  final Palette palette;
  final ListEntryUserData data;
  final Function(ListEntryUserData) update;

  UpdateButton({
    @required this.palette,
    @required this.data,
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
              setState(() => _isLoading = true);
              Provider.of<MediaItem>(context, listen: false)
                  .updateUserData(widget.data)
                  .then((_) {
                widget.update(widget.data);
                Navigator.of(context).pop();
              });
            },
          )
        : const WaveBarLoader(barWidth: 10);
  }
}
