import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/models/media_item_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/overlays/edit_media_tools/grid_child.dart';
import 'package:otraku/tools/overlays/edit_media_tools/number_field.dart';
import 'package:otraku/tools/overlays/edit_media_tools/update_button.dart';
import 'package:provider/provider.dart';

class EditMediaSheet extends StatefulWidget {
  final Function(ListEntryUserData) update;
  final MediaItemData mediaObj;

  EditMediaSheet(this.update, this.mediaObj);

  @override
  _EditMediaSheetState createState() => _EditMediaSheetState();
}

class _EditMediaSheetState extends State<EditMediaSheet> {
  ListEntryUserData _data;
  Palette _palette;
  double _topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _topInset),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        color: _palette.background,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: Palette.ICON_MEDIUM,
                color: _palette.contrast,
                onPressed: () => Navigator.of(context).pop(),
              ),
              if (_data != null)
                UpdateButton(
                  palette: _palette,
                  data: _data,
                  update: widget.update,
                ),
            ],
          ),
          if (_data != null)
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverGrid.extent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2,
                    children: [
                      GridChild(
                        title: 'Status',
                        body: _DropDownImplementation(
                          widget.mediaObj,
                          _palette,
                        ),
                        palette: _palette,
                      ),
                      GridChild(
                        title: 'Progress',
                        body: SizedBox(
                          height: 40,
                          child: NumberField(
                            palette: _palette,
                            initialValue: _data.progress,
                            maxValue: _data.progressMax,
                          ),
                        ),
                        palette: _palette,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _topInset = Provider.of<ViewConfig>(context, listen: false).topInset + 20;

    Provider.of<MediaItem>(context, listen: false)
        .fetchUserData(widget.mediaObj.id)
        .then((data) {
      if (mounted) {
        setState(() => _data = data);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }
}

class _DropDownImplementation extends StatefulWidget {
  final MediaItemData mediaObj;
  final Palette palette;

  _DropDownImplementation(this.mediaObj, this.palette);

  @override
  __DropDownImplementationState createState() =>
      __DropDownImplementationState();
}

class __DropDownImplementationState extends State<_DropDownImplementation> {
  MediaListStatus _status;
  bool _isAnime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: widget.palette.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton(
        value: _status,
        hint: Text('Add'),
        onChanged: (value) => setState(() => _status = value),
        items: MediaListStatus.values
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    listStatusSpecification(v, _isAnime),
                    style: v != _status
                        ? widget.palette.paragraph
                        : widget.palette.exclamation,
                  ),
                ))
            .toList(),
        dropdownColor: widget.palette.primary,
        underline: SizedBox(),
        isExpanded: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _status = widget.mediaObj.mediaListStatus;
    _isAnime = widget.mediaObj.type == 'ANIME';
  }
}
