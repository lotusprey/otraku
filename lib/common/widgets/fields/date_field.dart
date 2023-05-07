import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DateField extends StatefulWidget {
  const DateField({required this.date, required this.onChanged});

  final DateTime? date;
  final Function(DateTime?) onChanged;

  @override
  DateFieldState createState() => DateFieldState();
}

class DateFieldState extends State<DateField> {
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  @override
  void didUpdateWidget(covariant DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _date = widget.date;
  }

  Widget _picker(DateTime? initialDate) {
    return SizedBox(
      width: 40,
      child: IconButton(
        tooltip: 'Date Picker',
        icon: const Icon(Ionicons.calendar_clear_outline),
        onPressed: () => showDatePicker(
          context: context,
          initialDate: initialDate!,
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          errorInvalidText: 'Enter date in valid range',
          errorFormatText: 'Enter valid date',
          confirmText: 'Done',
          cancelText: 'Cancel',
          fieldLabelText: '',
          helpText: '',
        ).then((pickedDate) {
          if (pickedDate == null) return;
          setState(() => _date = pickedDate);
          widget.onChanged(pickedDate);
        }),
        padding: const EdgeInsets.all(0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
        child: _date != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _picker(_date),
                  Text('${_date!.year}-${_date!.month}-${_date!.day}'),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _date = null);
                        widget.onChanged(null);
                      },
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                ],
              )
            : Row(children: [_picker(DateTime.now())]),
      );
}
