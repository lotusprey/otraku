import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/loaders.dart';

class CharacterOverviewSubview extends StatelessWidget {
  const CharacterOverviewSubview.asFragment({
    required this.character,
    required this.invalidate,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const CharacterOverviewSubview.withHeader({
    required this.character,
    required this.invalidate,
    required Widget this.header,
  }) : scrollCtrl = null;

  final Character character;
  final void Function() invalidate;
  final Widget? header;
  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final refreshControl = SliverRefreshControl(onRefresh: invalidate);

    return CustomScrollView(
      physics: Theming.bouncyPhysics,
      controller: scrollCtrl,
      slivers: [
        if (header != null) ...[
          header!,
          MediaQuery(
            data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
            child: refreshControl,
          ),
        ] else
          refreshControl,
        SliverPadding(
          padding: const .symmetric(horizontal: Theming.offset),
          sliver: SliverMainAxisGroup(
            slivers: [
              _NameTable(character),
              const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
              SliverTableList([
                if (character.dateOfBirth != null) ('Birth', character.dateOfBirth!),
                if (character.age != null) ('Age', character.age!),
                if (character.bloodType != null) ('Blood Type', character.bloodType!),
              ]),
              if (character.description.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                HtmlContent(character.description, renderMode: RenderMode.sliverList),
              ],
            ],
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}

class _NameTable extends StatefulWidget {
  const _NameTable(this.character);

  final Character character;

  @override
  State<_NameTable> createState() => __NameTableState();
}

class __NameTableState extends State<_NameTable> {
  var _showSpoilers = false;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverTableList([
          ('Full', widget.character.fullName),
          if (widget.character.nativeName != null) ('Native', widget.character.nativeName!),
          ...widget.character.altNames.map((s) => ('Alternative', s)),
          if (_showSpoilers)
            ...widget.character.altNamesSpoilers.map((s) => ('Alternative Spoiler', s)),
        ]),
        if (widget.character.altNamesSpoilers.isNotEmpty && !_showSpoilers)
          SliverToBoxAdapter(
            child: TextButton.icon(
              label: const Text('Show Spoilers'),
              icon: const Icon(Ionicons.eye_outline),
              onPressed: () => setState(() => _showSpoilers = true),
            ),
          ),
      ],
    );
  }
}
