import 'package:flutter/material.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';

class DropDownField<T> extends StatefulWidget {
  final String title;
  final T initialValue;
  final Map<String, T> items;
  final Function(T) onChange;

  DropDownField({
    @required this.title,
    @required this.initialValue,
    @required this.items,
    @required this.onChange,
  });

  @override
  _DropDownFieldState createState() => _DropDownFieldState();
}

class _DropDownFieldState<T> extends State<DropDownField> {
  T value;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> menuItems = [];
    for (final key in widget.items.keys) {
      menuItems.add(DropdownMenuItem(
        value: widget.items[key],
        child: Text(
          key,
          style: widget.items[key] != value
              ? Theme.of(context).textTheme.bodyText1
              : Theme.of(context).textTheme.bodyText2,
        ),
      ));
    }

    return InputFieldStructure(
      title: widget.title,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: AppConfig.BORDER_RADIUS,
        ),
        child: DropdownButton(
          value: value,
          items: menuItems,
          onChanged: (val) {
            setState(() => value = val);
            widget.onChange(val);
          },
          hint: Text('Choose', style: Theme.of(context).textTheme.subtitle1),
          iconEnabledColor: Theme.of(context).disabledColor,
          dropdownColor: Theme.of(context).primaryColor,
          underline: const SizedBox(),
          isExpanded: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }
}
