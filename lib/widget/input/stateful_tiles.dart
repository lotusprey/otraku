import 'package:flutter/material.dart';

/// A wrapper around [SwitchListTile.adaptive], which handles state.
class StatefulSwitchListTile extends StatefulWidget {
  const StatefulSwitchListTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final Widget title;
  final Widget? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  State<StatefulSwitchListTile> createState() => _StatefulSwitchListTileState();
}

class _StatefulSwitchListTileState extends State<StatefulSwitchListTile> {
  late bool _value = widget.value;

  @override
  void didUpdateWidget(covariant StatefulSwitchListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      // The active color needs to be overriden, because
      // the cupertino selected state won't pick it up otherwise.
      activeTrackColor: ColorScheme.of(context).primary,
      title: widget.title,
      subtitle: widget.subtitle,
      value: _value,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

/// A wrapper around [CheckboxListTile.adaptive], which handles state.
class StatefulCheckboxListTile extends StatefulWidget {
  const StatefulCheckboxListTile({
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.title,
  });

  final bool? value;
  final void Function(bool?) onChanged;
  final Widget? title;
  final bool tristate;

  @override
  State<StatefulCheckboxListTile> createState() =>
      _StatefulCheckboxListTileState();
}

class _StatefulCheckboxListTileState extends State<StatefulCheckboxListTile> {
  late bool? _value = widget.value;

  @override
  void didUpdateWidget(covariant StatefulCheckboxListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile.adaptive(
      // The active color needs to be overriden, because
      // the cupertino selected state won't pick it up otherwise.
      activeColor: ColorScheme.of(context).primary,
      title: widget.title,
      tristate: widget.tristate,
      value: _value,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

class StatefulSegmentedButton<T> extends StatefulWidget {
  const StatefulSegmentedButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.segments,
  });

  final T value;
  final void Function(T) onChanged;
  final List<ButtonSegment<T>> segments;

  @override
  State<StatefulSegmentedButton<T>> createState() =>
      _StatefulSegmentedButtonState<T>();
}

class _StatefulSegmentedButtonState<T>
    extends State<StatefulSegmentedButton<T>> {
  late var _value = widget.value;

  @override
  void didUpdateWidget(covariant StatefulSegmentedButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      selected: {_value},
      segments: widget.segments,
      onSelectionChanged: (value) {
        setState(() => _value = value.first);
        widget.onChanged(_value);
      },
    );
  }
}
