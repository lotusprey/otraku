import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/config.dart';

class DateField extends StatefulWidget {
  final DateTime? date;
  final Function(DateTime?) onChanged;
  final String helpText;

  DateField({
    required this.date,
    required this.onChanged,
    required this.helpText,
  });

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final constraints = const BoxConstraints(
    maxWidth: 30,
    minHeight: Config.MATERIAL_TAP_TARGET_SIZE,
  );

  DateTime? _date;

  Widget _picker(DateTime? initialDate) {
    return IconButton(
      tooltip: 'Pick ${widget.helpText}',
      icon: const Icon(Ionicons.calendar_clear_outline),
      onPressed: () => showDatePicker(
        context: context,
        initialDate: initialDate!,
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        helpText: widget.helpText,
        errorInvalidText: 'Enter date in valid range',
        errorFormatText: 'Enter valid date',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        fieldLabelText: '',
      ).then((pickedDate) {
        if (pickedDate == null) return;
        setState(() => _date = pickedDate);
        widget.onChanged(pickedDate);
      }),
      padding: const EdgeInsets.all(0),
      constraints: constraints,
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Config.BORDER_RADIUS,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: _date != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _picker(_date),
                  Text('${_date!.year}-${_date!.month}-${_date!.day}'),
                  IconButton(
                    tooltip: 'Pick ${widget.helpText}',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _date = null);
                      widget.onChanged(null);
                    },
                    padding: const EdgeInsets.all(0),
                    constraints: constraints,
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
