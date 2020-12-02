import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class FilterGrid extends StatelessWidget {
  final List<String> options;
  final List<Object> values;
  final List<String> descriptions;
  final List<String> optionIn;
  final List<String> optionNotIn;
  final int rows;
  final double whRatio;

  FilterGrid({
    @required this.options,
    @required this.values,
    @required this.optionIn,
    @required this.optionNotIn,
    @required this.rows,
    @required this.whRatio,
    this.descriptions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rows * 30.0 + (rows - 1) * 10 + 20,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: Config.PHYSICS,
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: whRatio,
        ),
        itemBuilder: (_, index) => _FilterOption(
          title: options[index],
          value: values[index],
          optionIn: optionIn,
          optionNotIn: optionNotIn,
          description: descriptions.length > index ? descriptions[index] : null,
        ),
        itemCount: options.length,
      ),
    );
  }
}

class _FilterOption extends StatefulWidget {
  final String title;
  final Object value;
  final List<String> optionIn;
  final List<String> optionNotIn;
  final String description;

  _FilterOption({
    @required this.title,
    @required this.value,
    @required this.optionIn,
    @required this.optionNotIn,
    this.description,
  });

  @override
  _FilterOptionState createState() => _FilterOptionState();
}

class _FilterOptionState extends State<_FilterOption> {
  static const SizedBox _sizedBox = const SizedBox(width: 5);
  static BorderRadius _borderRadius = BorderRadius.circular(20);

  int _state;

  @override
  void initState() {
    super.initState();
    _state = widget.optionIn.contains(widget.value)
        ? 1
        : widget.optionNotIn.contains(widget.value)
            ? -1
            : 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _state == 0
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: _borderRadius,
              ),
              child: Center(
                child: Text(widget.title,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            )
          : _state == 1
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: _borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      _sizedBox,
                      Icon(Icons.add,
                          size: 15, color: Theme.of(context).dividerColor),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).errorColor,
                    borderRadius: _borderRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      _sizedBox,
                      Icon(Icons.remove,
                          size: 15, color: Theme.of(context).dividerColor),
                    ],
                  ),
                ),
      onTap: () {
        if (_state == 0) {
          widget.optionIn.add(widget.value);
          setState(() => _state = 1);
        } else if (_state == 1) {
          widget.optionIn.remove(widget.value);
          widget.optionNotIn.add(widget.value);
          setState(() => _state = -1);
        } else {
          widget.optionNotIn.remove(widget.value);
          setState(() => _state = 0);
        }
      },
      onLongPress: () {
        if (widget.description != null) {
          showDialog(
            context: context,
            builder: (_) => PopUpAnimation(
              TextDialog(title: widget.title, text: widget.description),
            ),
          );
        }
      },
    );
  }
}
