import 'package:flutter/material.dart';
import 'package:otraku/widgets/containers/theme_preview.dart';

class ThemePreviewRow extends StatefulWidget {
  const ThemePreviewRow({
    Key? key,
    required this.colorSchemeMap,
    required this.title,
    required this.activeKey,
    required this.themes,
    required this.onTap,
  }) : super(key: key);

  final Map<String, int> colorSchemeMap;
  final String title;
  final int activeKey;
  final Iterable<MapEntry<String, ColorScheme>> themes;
  final void Function(String name) onTap;

  @override
  State<StatefulWidget> createState() => _ThemePreviewRowState();
}

class _ThemePreviewRowState extends State<ThemePreviewRow> {
  late int activeNow = widget.activeKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 5),
                  child: Text(widget.title)),
              Container(
                  height: 210,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var item in widget.themes)
                        ThemePreview(
                            key: Key(item.key),
                            name: item.key,
                            scheme: item.value,
                            active:
                                activeNow == widget.colorSchemeMap[item.key],
                            onTap: (name) {
                              widget.onTap(name);
                              setState(() =>
                                  {activeNow = widget.colorSchemeMap[name]!});
                            }),
                    ],
                  )),
            ],
          )),
    );
  }
}
