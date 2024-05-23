import 'package:flutter/material.dart';
import 'package:otraku/util/extensions.dart';
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
  }) =>
      ChipSelector._(
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
  }) =>
      ChipSelector._(
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
  const ChipMultiSelector({
    required this.title,
    required this.items,
    required this.values,
  });

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
            setState(
              () => isSelected
                  ? widget.values.add(value)
                  : widget.values.remove(value),
            );
          },
        );
      },
    );
  }
}

class EntrySortChipSelector extends StatefulWidget {
  const EntrySortChipSelector({
    required this.title,
    required this.current,
    required this.onChanged,
  });

  final String title;
  final EntrySort current;
  final void Function(EntrySort) onChanged;

  @override
  State<EntrySortChipSelector> createState() => _EntrySortChipSelectorState();
}

class _EntrySortChipSelectorState extends State<EntrySortChipSelector> {
  late var _current = widget.current;
  final _options = <String>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < EntrySort.values.length; i += 2) {
      _options.add(
        EntrySort.values.elementAt(i).name.noScreamingSnakeCase,
      );
    }
  }

  @override
  void didUpdateWidget(covariant EntrySortChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _current = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final current = _current.index ~/ 2;
    final descending = _current.index % 2 != 0;

    return _ChipSelector(
      title: widget.title,
      length: _options.length,
      itemBuilder: (context, index) => FilterChip(
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        label: Text(_options[index]),
        showCheckmark: false,
        avatar: current == index
            ? Icon(
                descending
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            : null,
        selected: current == index,
        onSelected: (_) {
          setState(
            () {
              int i = index * 2;
              if (current == index) {
                if (!descending) i++;
              } else {
                if (descending) i++;
              }
              _current = EntrySort.values.elementAt(i);
            },
          );
          widget.onChanged(_current);
        },
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.title,
    required this.length,
    required this.itemBuilder,
  });

  final String title;
  final int length;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
          child: Text(title),
        ),
        SizedBox(
          height: 40,
          child: ShadowedOverflowList(
            itemCount: length,
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
