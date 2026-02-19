import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/loaders.dart';

class CharacterOverviewSubview extends StatelessWidget {
  const CharacterOverviewSubview.asFragment({
    required this.character,
    required this.invalidate,
    required this.highContrast,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const CharacterOverviewSubview.withHeader({
    required this.character,
    required this.invalidate,
    required this.highContrast,
    required Widget this.header,
  }) : scrollCtrl = null;

  final Character character;
  final void Function() invalidate;
  final Widget? header;
  final ScrollController? scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              _NameTable(character, l10n, highContrast),
              const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
              SliverTableList([
                if (character.dateOfBirth != null) (l10n.personInfoBirth, character.dateOfBirth!),
                if (character.age != null) (l10n.personInfoAge, character.age!),
                if (character.bloodType != null) (l10n.personInfoBloodType, character.bloodType!),
              ], highContrast: highContrast),
              if (character.description.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                HtmlContent(character.description, renderMode: .sliverList),
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
  const _NameTable(this.character, this.l10n, this.highContrast);

  final Character character;
  final AppLocalizations l10n;
  final bool highContrast;

  @override
  State<_NameTable> createState() => __NameTableState();
}

class __NameTableState extends State<_NameTable> {
  var _showSpoilers = false;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return SliverMainAxisGroup(
      slivers: [
        SliverTableList([
          (l10n.personInfoNameFull, widget.character.fullName),
          if (widget.character.nativeName != null)
            (l10n.personInfoNameNative, widget.character.nativeName!),
          ...widget.character.altNames.map((s) => (l10n.personInfoNameAlternative, s)),
          if (_showSpoilers)
            ...widget.character.altNamesSpoilers.map(
              (s) => (l10n.personInfoNameAlternativeSpoiler, s),
            ),
        ], highContrast: widget.highContrast),
        if (widget.character.altNamesSpoilers.isNotEmpty && !_showSpoilers)
          SliverToBoxAdapter(
            child: TextButton.icon(
              label: Text(l10n.actionSpoilersShow),
              icon: const Icon(Ionicons.eye_outline),
              onPressed: () => setState(() => _showSpoilers = true),
            ),
          ),
      ],
    );
  }
}
