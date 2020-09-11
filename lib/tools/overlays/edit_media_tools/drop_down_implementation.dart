import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/theming.dart';

class DropDownImplementation extends StatefulWidget {
  final EntryUserData data;
  final bool isAnime;
  final Palette palette;

  DropDownImplementation(this.data, this.isAnime, this.palette);

  @override
  _DropDownImplementationState createState() => _DropDownImplementationState();
}

class _DropDownImplementationState extends State<DropDownImplementation> {
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
        value: widget.data.status,
        hint: Text('Add'),
        onChanged: (value) {
          setState(() => widget.data.status = value);
          widget.data.status = value;
        },
        items: MediaListStatus.values
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    listStatusSpecification(v, widget.isAnime),
                    style: v != widget.data.status
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
}
