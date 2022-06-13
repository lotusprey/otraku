import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/widgets/fields/search_field.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class SearchToolField extends StatefulWidget {
  SearchToolField({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? value;

  /// If [null], search mode cannot be turned on; [value] & [hint] are ignored.
  final void Function(String?)? onChanged;

  @override
  _SearchToolFieldState createState() => _SearchToolFieldState();
}

class _SearchToolFieldState extends State<SearchToolField> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant SearchToolField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          if (_value == null || widget.onChanged == null) ...[
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (widget.onChanged != null)
              TopBarIcon(
                tooltip: 'Search',
                icon: Ionicons.search_outline,
                onTap: () => widget.onChanged?.call(''),
              ),
          ] else
            Expanded(
              child: SearchField(
                value: _value!,
                hint: widget.title,
                onChange: (val) => widget.onChanged?.call(val),
                onHide: () => widget.onChanged?.call(null),
              ),
            ),
        ],
      ),
    );
  }
}

class FilterMediaToolButton extends StatefulWidget {
  FilterMediaToolButton(this.filters);

  final FilterModel filters;

  @override
  _FilterMediaToolButtonState createState() => _FilterMediaToolButtonState();
}

class _FilterMediaToolButtonState extends State<FilterMediaToolButton> {
  late bool _active;

  @override
  void initState() {
    super.initState();
    _active = _isActive();
  }

  @override
  void didUpdateWidget(covariant FilterMediaToolButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _active = _isActive();
  }

  @override
  Widget build(BuildContext context) => TopBarIcon(
        tooltip: 'Filter',
        icon: Ionicons.funnel_outline,
        onTap: () => showSheet(context, FilterView(widget.filters)).then((_) {
          if (_active != _isActive()) setState(() => _active = !_active);
        }),
        colour: _active ? Theme.of(context).colorScheme.primary : null,
      );

  bool _isActive() {
    final f = widget.filters;
    if (f.country != null ||
        f.statuses.isNotEmpty ||
        f.formats.isNotEmpty ||
        f.genreIn.isNotEmpty ||
        f.genreNotIn.isNotEmpty ||
        f.tagIn.isNotEmpty ||
        f.tagNotIn.isNotEmpty) return true;

    if (f is ExploreFilterModel && f.onList != null) return true;

    return false;
  }
}
