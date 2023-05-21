import 'package:flutter/material.dart';
import 'package:otraku/common/utils/convert.dart';

/// A horizontal list of chips, where only one can be selected at a time.
class ChipSelector extends StatefulWidget {
  const ChipSelector({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.mustHaveSelected = false,
  }) : assert(selected != null || !mustHaveSelected);

  final String title;
  final List<String> options;
  final int? selected;
  final void Function(int?) onChanged;

  /// Whether it's allowed for [selected] to be `null`.
  final bool mustHaveSelected;

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late int? _current = widget.selected;

  @override
  void didUpdateWidget(covariant ChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return ChipSelectorLayout(
      title: widget.title,
      options: widget.options,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: FilterChip(
          label: Text(widget.options[index]),
          selected: index == _current,
          onSelected: (selected) {
            if (_current == index && widget.mustHaveSelected) return;

            setState(() => selected ? _current = index : _current = null);
            widget.onChanged(_current);
          },
        ),
      ),
    );
  }
}

/// A horizontal list of chips, where multiple can be selected at a time.
/// Note: The state mutates [selected] directly.
class ChipEnumMultiSelector<T extends Enum> extends StatefulWidget {
  const ChipEnumMultiSelector({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<T> options;
  final List<String> selected;

  @override
  State<ChipEnumMultiSelector> createState() => _ChipEnumMultiSelectorState();
}

class _ChipEnumMultiSelectorState extends State<ChipEnumMultiSelector> {
  final _options = <String>[];
  final _values = <String>[];

  @override
  void initState() {
    super.initState();
    for (final o in widget.options) {
      _options.add(Convert.clarifyEnum(o.name)!);
      _values.add(o.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChipSelectorLayout(
      title: widget.title,
      options: _options,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: FilterChip(
          label: Text(_options[index]),
          selected: widget.selected.contains(_values[index]),
          onSelected: (selected) {
            setState(
              () => selected
                  ? widget.selected.add(_values[index])
                  : widget.selected.remove(_values[index]),
            );
          },
        ),
      ),
    );
  }
}

/// A common wrapper between the chip selectors.
class ChipSelectorLayout extends StatelessWidget {
  const ChipSelectorLayout({
    required this.title,
    required this.options,
    required this.itemBuilder,
  });

  final String title;
  final List<String> options;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(title, style: Theme.of(context).textTheme.labelMedium),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 10),
            itemCount: options.length,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
