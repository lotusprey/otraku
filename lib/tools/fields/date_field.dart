import 'package:flutter/material.dart';
import 'package:otraku/providers/app_config.dart';

class DateField extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onChanged;
  final String helpText;

  DateField({
    @required this.date,
    @required this.onChanged,
    @required this.helpText,
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
      onPressed: () => showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        helpText: widget.helpText,
        errorFormatText: 'Enter valid date',
        errorInvalidText: 'Enter date in valid range',
      ).then((pickedDate) {
        if (pickedDate == null) return;
        setState(() => date = pickedDate);
        widget.onChanged(pickedDate);
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: AppConfig.BORDER_RADIUS,
        ),
        child: date != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _picker(date),
                  Text(
                    '${date.year}-${date.month}-${date.day}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => date = null);
                      widget.onChanged(null);
                    },
                  ),
                ],
              )
            : Row(children: [_picker(DateTime.now())]),
      );
}
