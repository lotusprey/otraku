import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';

class DateField extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onChange;
  final String helpText;
  final Palette palette;

  DateField({
    @required this.date,
    @required this.onChange,
    @required this.helpText,
    @required this.palette,
  });

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime date;

  @override
  void initState() {
    super.initState();
    date = widget.date;
  }

  Widget _picker(DateTime initialDate) {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      color: widget.palette.faded,
      iconSize: Palette.ICON_MEDIUM,
      onPressed: () => showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        helpText: widget.helpText,
        errorFormatText: 'Enter valid date',
        errorInvalidText: 'Enter date in valid range',
        builder: (_, child) => Theme(
          data: ThemeData(
            backgroundColor: widget.palette.background,
            primaryColor: widget.palette.foreground,
            accentColor: widget.palette.accent,
            errorColor: widget.palette.error,
          ),
          child: child,
        ),
      ).then((pickedDate) {
        if (pickedDate == null) return;
        setState(() => date = pickedDate);
        widget.onChange(pickedDate);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.palette.foreground,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: date != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _picker(date),
                Text(
                  '${date.year}-${date.month}-${date.day}',
                  style: widget.palette.paragraph,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  color: widget.palette.faded,
                  iconSize: Palette.ICON_MEDIUM,
                  onPressed: () {
                    setState(() => date = null);
                    widget.onChange(null);
                  },
                ),
              ],
            )
          : Row(children: [_picker(DateTime.now())]),
    );
  }
}
