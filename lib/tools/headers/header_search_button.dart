import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/media_group_provider.dart';
import 'package:otraku/providers/theming.dart';

class HeaderSearchButton extends StatelessWidget {
  final MediaGroupProvider provider;
  final Palette palette;

  HeaderSearchButton(this.provider, this.palette);

  @override
  Widget build(BuildContext context) {
    return provider.search != null
        ? GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  text: provider.search,
                  searchFn: (value) => provider.search = value,
                ),
              ),
            ),
            onLongPress: () => provider.search = null,
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: palette.accent,
              ),
              child: const Icon(
                LineAwesomeIcons.search,
                size: Palette.ICON_MEDIUM,
                color: Colors.white,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(LineAwesomeIcons.search),
            color: palette.faded,
            iconSize: Palette.ICON_MEDIUM,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  text: provider.search,
                  searchFn: (value) => provider.search = value,
                ),
              ),
            ),
          );
  }
}
