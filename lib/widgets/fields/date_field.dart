import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';

class DateField extends StatefulWidget {
  const DateField({required this.date, required this.onChanged});

  final DateTime? date;
  final Function(DateTime?) onChanged;

  @override
  DateFieldState createState() => DateFieldState();
}

class DateFieldState extends State<DateField> {
  DateTime? _date;

  Widget _picker(DateTime? initialDate) {
    return IconButton(
      tooltip: 'Date Picker',
      icon: const Icon(Ionicons.calendar_clear_outline),
      onPressed: () => showDatePicker(
        context: context,
        initialDate: initialDate!,
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        errorInvalidText: 'Enter date in valid range',
        errorFormatText: 'Enter valid date',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        fieldLabelText: '',
        helpText: '',
      ).then((pickedDate) {
        if (pickedDate == null) return;
        setState(() => _date = pickedDate);
        widget.onChanged(pickedDate);
      }),
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(
        minHeight: Consts.tapTargetSize,
        maxWidth: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Consts.borderRadiusMin,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: _date != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _picker(_date),
                  Text('${_date!.year}-${_date!.month}-${_date!.day}'),
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _date = null);
                      widget.onChanged(null);
                    },
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(
                      minHeight: Consts.tapTargetSize,
                      maxWidth: 30,
                    ),
                  ),
                ],
              )
            : Row(children: [_picker(DateTime.now())]),
      );

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
}
