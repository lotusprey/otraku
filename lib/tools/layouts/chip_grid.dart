import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/tools/fields/chip_field.dart';

class ChipGrid<T> extends StatefulWidget {
  final String title;
  final String placeholder;
  final List<String> options;
  final List<T> values;
  final List<T> inclusive;
  final List<T> exclusive;

  ChipGrid({
    @required this.title,
    @required this.placeholder,
    @required this.options,
    @required this.values,
    @required this.inclusive,
    this.exclusive,
  });

  @override
  _ChipGridState createState() => _ChipGridState();
}

class _ChipGridState extends State<ChipGrid> {
  @override
  Widget build(BuildContext context) {
    final list = List.generate(
        widget.inclusive.length + (widget.exclusive?.length ?? 0), (index) {
      final value = index < widget.inclusive.length
          ? widget.inclusive[index]
          : widget.exclusive[index - widget.inclusive.length];
      return ChipField(
        key: UniqueKey(),
        title: FnHelper.clarifyEnum(value),
        initiallyPositive: index < widget.inclusive.length,
        onChanged: widget.exclusive == null
            ? null
            : (changed) {
                if (changed) {
                  widget.exclusive.remove(value);
                  widget.inclusive.add(value);
                } else {
                  widget.inclusive.remove(value);
                  widget.exclusive.add(value);
                }
              },
        onRemoved: () {
          if (index < widget.inclusive.length)
            setState(() => widget.inclusive.remove(value));
          else
            setState(() => widget.exclusive.remove(value));
        },
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.subtitle1),
            Row(
              children: [
                if (list.length > 0)
                  GestureDetector(
                    onTap: () => setState(() {
                      widget.inclusive.clear();
                      widget.exclusive?.clear();
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).disabledColor,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).backgroundColor,
                        size: Styles.ICON_SMALLER,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(FluentSystemIcons.ic_fluent_settings_dev_filled),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => _OptionSheet(
                      options: widget.options,
                      values: widget.values,
                      inclusive: [...widget.inclusive],
                      exclusive: widget.exclusive != null
                          ? [...widget.exclusive]
                          : null,
                      onDone: (inclusive, exclusive) {
                        setState(() {
                          widget.inclusive.clear();
                          for (final i in inclusive) widget.inclusive.add(i);
                          if (widget.exclusive != null) {
                            widget.exclusive.clear();
                            for (final e in exclusive) widget.exclusive.add(e);
                          }
                        });
                      },
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ],
        ),
        list.length > 0
            ? Wrap(spacing: 10, runSpacing: 10, children: list)
            : SizedBox(
                height: Config.MATERIAL_TAP_TARGET_SIZE,
                child: Center(
                  child: Text(
                    'No selected ${widget.placeholder}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
      ],
    );
  }
}

class _OptionSheet<T> extends StatelessWidget {
  final List<String> options;
  final List<T> values;
  final List<T> inclusive;
  final List<T> exclusive;
  final Function(List<T>, List<T>) onDone;

  _OptionSheet({
    @required this.onDone,
    @required this.options,
    @required this.values,
    @required this.inclusive,
    this.exclusive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: Config.PHYSICS,
              itemBuilder: (_, index) => exclusive == null
                  ? _TwoStateField(
                      title: options[index],
                      initial: inclusive.contains(values[index]),
                      onChanged: (val) {
                        if (val)
                          inclusive.add(values[index]);
                        else
                          inclusive.remove(values[index]);
                      },
                    )
                  : _ThreeStateField(
                      title: options[index],
                      initialState: inclusive.contains(values[index])
                          ? 1
                          : exclusive.contains(values[index])
                              ? 2
                              : 0,
                      onChanged: (state) {
                        if (state == 0) {
                          exclusive.remove(values[index]);
                        } else if (state == 1) {
                          inclusive.add(values[index]);
                        } else {
                          inclusive.remove(values[index]);
                          exclusive.add(values[index]);
                        }
                      },
                    ),
              itemCount: options.length,
            ),
          ),
          FlatButton.icon(
            onPressed: () {
              onDone(inclusive, exclusive);
              Navigator.pop(context);
            },
            icon: Icon(
              FluentSystemIcons.ic_fluent_checkmark_filled,
              color: Theme.of(context).accentColor,
            ),
            label: Text('Done', style: Theme.of(context).textTheme.bodyText2),
          ),
        ],
      ),
    );
  }
}

class _TwoStateField extends StatefulWidget {
  final String title;
  final bool initial;
  final Function(bool) onChanged;

  _TwoStateField({
    @required this.title,
    @required this.initial,
    @required this.onChanged,
  });

  @override
  __TwoStateFieldState createState() => __TwoStateFieldState();
}

class __TwoStateFieldState extends State<_TwoStateField> {
  bool _active;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyText1),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: !_active
              ? Theme.of(context).primaryColor
              : Theme.of(context).accentColor,
        ),
        child: _active
            ? Icon(
                Icons.done,
                color: Theme.of(context).dividerColor,
                size: Styles.ICON_SMALL,
              )
            : null,
      ),
      onTap: () {
        setState(() => _active = !_active);
        widget.onChanged(_active);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _active = widget.initial;
  }
}

class _ThreeStateField extends StatefulWidget {
  final String title;
  final int initialState;
  final Function(int) onChanged;

  _ThreeStateField({
    @required this.title,
    @required this.initialState,
    @required this.onChanged,
  });

  @override
  _ThreeStateFieldState createState() => _ThreeStateFieldState();
}

class _ThreeStateFieldState extends State<_ThreeStateField> {
  int _state;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyText1),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _state == 0
              ? Theme.of(context).primaryColor
              : _state == 1
                  ? Theme.of(context).accentColor
                  : Theme.of(context).errorColor,
        ),
        child: _state != 0
            ? Icon(
                _state == 1 ? Icons.add : Icons.remove,
                color: Theme.of(context).dividerColor,
                size: Styles.ICON_SMALL,
              )
            : null,
      ),
      onTap: () {
        if (_state < 2) {
          setState(() => _state++);
        } else {
          setState(() => _state = 0);
        }
        widget.onChanged(_state);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    if (_state < 0 || _state > 2) _state = 0;
  }
}
