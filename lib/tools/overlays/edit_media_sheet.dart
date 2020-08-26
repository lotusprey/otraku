import 'package:flutter/material.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
import 'package:provider/provider.dart';

class EditMediaSheet extends StatelessWidget {
  final Function(ListEntryUserData) update;

  EditMediaSheet(this.update);

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return Container(
      margin: EdgeInsets.only(
        top: Provider.of<ViewConfig>(context, listen: false).topInset + 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        color: palette.background,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: Palette.ICON_MEDIUM,
                color: palette.contrast,
                onPressed: () => Navigator.of(context).pop(),
              ),
              _UpdateButton(palette),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateButton extends StatefulWidget {
  final Palette _palette;

  _UpdateButton(this._palette);

  @override
  __UpdateButtonState createState() => __UpdateButtonState();
}

class __UpdateButtonState extends State<_UpdateButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: WaveBarLoader(barWidth: 12),
          ),
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: widget._palette.accent,
          child: Text('Save', style: widget._palette.buttonText),
          onPressed: () => setState(() => _isLoading = true),
        ),
      ],
    );
  }
}

class _Content extends StatefulWidget {
  final Function(ListEntryUserData) update;

  _Content(this.update);

  @override
  __ContentState createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
