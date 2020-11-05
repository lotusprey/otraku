import 'package:flutter/material.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ListSettingsPage extends StatelessWidget {
  final Map<String, dynamic> changes;

  ListSettingsPage(this.changes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lists',
      ),
      body: ListView(
        padding: AppConfig.PADDING,
        children: [
          _SwitchTile(
            label: 'Split Completed Anime',
            initialValue: Provider.of<Users>(context, listen: false)
                .settings
                .splitCompletedAnime,
            onChanged: (value) {
              const splitAnime = 'splitCompletedAnime';
              if (changes.containsKey(splitAnime)) {
                changes.remove(splitAnime);
              } else {
                changes[splitAnime] = value;
              }
            },
          ),
          _SwitchTile(
            label: 'Split Completed Manga',
            initialValue: Provider.of<Users>(context, listen: false)
                .settings
                .splitCompletedManga,
            onChanged: (value) {
              const splitManga = 'splitCompletedManga';
              if (changes.containsKey(splitManga)) {
                changes.remove(splitManga);
              } else {
                changes[splitManga] = value;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final String label;
  final bool initialValue;
  final Function(bool) onChanged;

  _SwitchTile({
    @required this.label,
    @required this.initialValue,
    @required this.onChanged,
  });

  @override
  _SwitchTileState createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  static const padding = const EdgeInsets.symmetric(horizontal: 10);

  bool value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: padding,
      title: Text(
        widget.label,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      value: value,
      onChanged: (val) {
        widget.onChanged(val);
        setState(() => value = val);
      },
      activeColor: Theme.of(context).accentColor,
    );
  }

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }
}
