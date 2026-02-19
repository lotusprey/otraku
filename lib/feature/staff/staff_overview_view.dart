import 'package:flutter/material.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/loaders.dart';

class StaffOverviewSubview extends StatelessWidget {
  const StaffOverviewSubview.asFragment({
    required this.staff,
    required this.invalidate,
    required this.highContrast,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const StaffOverviewSubview.withHeader({
    required this.staff,
    required this.invalidate,
    required this.highContrast,
    required Widget this.header,
  }) : scrollCtrl = null;

  final Staff staff;
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
              SliverTableList([
                (l10n.personInfoNameFull, staff.fullName),
                if (staff.nativeName != null) (l10n.personInfoNameNative, staff.nativeName!),
                ...staff.altNames.map((s) => (l10n.personInfoNameAlternative, s)),
              ], highContrast: highContrast),
              const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
              SliverTableList([
                if (staff.dateOfBirth != null) (l10n.personInfoBirth, staff.dateOfBirth!),
                if (staff.dateOfDeath != null) (l10n.personInfoDeath, staff.dateOfDeath!),
                if (staff.age != null) (l10n.personInfoAge, staff.age!),
                if (staff.startYear != null)
                  (
                    l10n.personInfoYearsActive,
                    '${staff.startYear} - ${staff.endYear ?? l10n.dateTimePresent}',
                  ),
                if (staff.homeTown != null) (l10n.personInfoHomeTown, staff.homeTown!),
                if (staff.bloodType != null) (l10n.personInfoBloodType, staff.bloodType!),
              ], highContrast: highContrast),
              if (staff.description.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                HtmlContent(staff.description, renderMode: .sliverList),
              ],
            ],
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}
