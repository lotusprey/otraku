import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';

class DropDownImplementation extends StatefulWidget {
  final EntryUserData data;
  final Palette palette;

  DropDownImplementation(this.data, this.palette);

  @override
  _DropDownImplementationState createState() => _DropDownImplementationState();
}

class _DropDownImplementationState extends State<DropDownImplementation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: widget.palette.foreground,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: DropdownButton(
        value: widget.data.status,
        items: MediaListStatus.values
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    listStatusSpecification(v, widget.data.type == 'ANIME'),
                    style: v != widget.data.status
                        ? widget.palette.paragraph
                        : widget.palette.exclamation,
                  ),
                ))
            .toList(),
        onChanged: (status) => setState(() => widget.data.status = status),
        hint: Text('Add', style: widget.palette.detail),
        iconEnabledColor: widget.palette.faded,
        dropdownColor: widget.palette.foreground,
        underline: const SizedBox(),
        isExpanded: true,
      ),
    );
  }
}
