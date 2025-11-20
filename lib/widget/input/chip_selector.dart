import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';
import 'package:otraku/feature/media/media_models.dart';

/// A horizontal list of chips, where only one can be selected at a time.
class ChipSelector<T> extends StatefulWidget {
  const ChipSelector._({
    required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.mustHaveSelected,
  });

  /// Allows for nothing to be selected.
  factory ChipSelector({
    required String title,
    required List<(String label, T value)> items,
    required T? value,
    required void Function(T?) onChanged,
  }) => ChipSelector._(
    title: title,
    items: items,
    value: value,
    onChanged: onChanged,
    mustHaveSelected: false,
  );

  /// Requires an option to be selected. [onChanged] will never receive `null`.
  factory ChipSelector.ensureSelected({
    required String title,
    required List<(String label, T value)> items,
    required T value,
    required void Function(T) onChanged,
  }) => ChipSelector._(
    title: title,
    items: items,
    value: value,
    onChanged: (v) => onChanged(v ?? value),
    mustHaveSelected: true,
  );

  final String title;
  final List<(String label, T value)> items;
  final T? value;
  final void Function(T?) onChanged;
  final bool mustHaveSelected;

  @override
  State<ChipSelector<T>> createState() => _ChipSelectorState<T>();
}

class _ChipSelectorState<T> extends State<ChipSelector<T>> {
  late T? _value = widget.value;

  @override
  void didUpdateWidget(covariant ChipSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return _ChipSelector(
      title: widget.title,
      length: widget.items.length,
      itemBuilder: (context, i) {
        final (label, value) = widget.items[i];

        return FilterChip(
          label: Text(label),
          selected: value == _value,
          onSelected: (selected) {
            // Should not pass `null` if [widget.mustHaveSelected].
            if (value == _value && widget.mustHaveSelected) return;

            setState(() => selected ? _value = value : _value = null);
            widget.onChanged(_value);
          },
        );
      },
    );
  }
}

/// A horizontal list of chips, where zero or more are selected.
/// Note: [values] are mutated directly.
class ChipMultiSelector<T> extends StatefulWidget {
  const ChipMultiSelector({required this.title, required this.items, required this.values});

  final String title;
  final List<(String label, T value)> items;
  final List<T> values;

  @override
  State<ChipMultiSelector<T>> createState() => _ChipMultiSelectorState<T>();
}

class _ChipMultiSelectorState<T> extends State<ChipMultiSelector<T>> {
  @override
  Widget build(BuildContext context) {
    return _ChipSelector(
      title: widget.title,
      length: widget.items.length,
      itemBuilder: (context, i) {
        final (label, value) = widget.items[i];

        return FilterChip(
          label: Text(label),
          selected: widget.values.contains(value),
          onSelected: (isSelected) {
            setState(() => isSelected ? widget.values.add(value) : widget.values.remove(value));
          },
        );
      },
    );
  }
}

class EntrySortChipSelector extends StatefulWidget {
  const EntrySortChipSelector({required this.title, required this.value, required this.onChanged});

  final String title;
  final EntrySort value;
  final void Function(EntrySort) onChanged;

  @override
  State<EntrySortChipSelector> createState() => _EntrySortChipSelectorState();
}

class _EntrySortChipSelectorState extends State<EntrySortChipSelector> {
  late var _value = widget.value;
  final _labels = <String>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < EntrySort.values.length; i += 2) {
      _labels.add(EntrySort.values[i].label);
    }
  }

  @override
  void didUpdateWidget(covariant EntrySortChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final unorderedValue = _value.index ~/ 2;
    final isDescending = _value.index % 2 != 0;

    return _ChipSelector(
      title: widget.title,
      length: _labels.length,
      itemBuilder: (context, index) => FilterChip(
        backgroundColor: ColorScheme.of(context).surface,
        labelStyle: TextStyle(color: ColorScheme.of(context).onSecondaryContainer),
        label: Text(_labels[index]),
        showCheckmark: false,
        avatar: unorderedValue == index
            ? Icon(
                isDescending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: ColorScheme.of(context).onPrimaryContainer,
              )
            : null,
        selected: unorderedValue == index,
        onSelected: (_) {
          setState(() {
            int i = index * 2;
            if (unorderedValue == index) {
              if (!isDescending) i++;
            } else {
              if (isDescending) i++;
            }
            _value = EntrySort.values.elementAt(i);
          });
          widget.onChanged(_value);
        },
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({required this.title, required this.length, required this.itemBuilder});

  final String title;
  final int length;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const .only(
            top: Theming.offset / 2,
            bottom: Theming.offset / 2,
            right: Theming.offset,
          ),
          child: Text(title),
        ),
        SizedBox(
          height: 40,
          child: ShadowedOverflowList(itemCount: length, itemBuilder: itemBuilder),
        ),
      ],
    );
  }
}
