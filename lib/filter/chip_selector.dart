import 'package:flutter/material.dart';
import 'package:otraku/utils/convert.dart';

/// A horizontal list of chips, where only one can be selected at a time.
class ChipSelector extends StatefulWidget {
  const ChipSelector({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final int? selected;
  final void Function(int?) onChanged;

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late int? _selected = widget.selected;

  @override
  void didUpdateWidget(covariant ChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return _Layout(
      title: widget.title,
      options: widget.options,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: FilterChip(
          backgroundColor: Theme.of(context).colorScheme.surface,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          label: Text(widget.options[index]),
          selected: index == _selected,
          onSelected: (selected) {
            setState(
              () => selected ? _selected = index : _selected = null,
            );
            widget.onChanged(_selected);
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
    return _Layout(
      title: widget.title,
      options: _options,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: FilterChip(
          backgroundColor: Theme.of(context).colorScheme.surface,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
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
class _Layout extends StatelessWidget {
  const _Layout({
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
          child: Text(title, style: Theme.of(context).textTheme.subtitle1),
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