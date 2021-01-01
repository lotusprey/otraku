import 'package:flutter/material.dart';
import 'package:otraku/services/config.dart';

class OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final int index;
  final Function(int) onTap;

  OptionSheet({
    @required this.title,
    @required this.options,
    @required this.index,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: options.length * Config.MATERIAL_TAP_TARGET_SIZE + 50.0,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Config.BORDER_RADIUS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 46, bottom: 10),
            child: Text(title, style: Theme.of(context).textTheme.subtitle1),
          ),
          Expanded(
            child: ListView.builder(
              physics: Config.PHYSICS,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(
                  options[i],
                  style: i != index
                      ? Theme.of(context).textTheme.bodyText1
                      : Theme.of(context).textTheme.bodyText2,
                ),
                trailing: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i != index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor,
                  ),
                ),
                onTap: () {
                  onTap(i);
                  Navigator.pop(context);
                },
              ),
              itemCount: options.length,
            ),
          ),
        ],
      ),
    );
  }
}
