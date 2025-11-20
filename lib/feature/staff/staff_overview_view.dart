import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/loaders.dart';

class StaffOverviewSubview extends StatelessWidget {
  const StaffOverviewSubview.asFragment({
    required this.staff,
    required this.invalidate,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const StaffOverviewSubview.withHeader({
    required this.staff,
    required this.invalidate,
    required Widget this.header,
  }) : scrollCtrl = null;

  final Staff staff;
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
              SliverTableList([
                ('Full', staff.fullName),
                if (staff.nativeName != null) ('Native', staff.nativeName!),
                ...staff.altNames.map((s) => ('Alternative', s)),
              ]),
              const SliverToBoxAdapter(child: SizedBox(height: Theming.offset)),
              SliverTableList([
                if (staff.dateOfBirth != null) ('Birth', staff.dateOfBirth!),
                if (staff.dateOfDeath != null) ('Death', staff.dateOfDeath!),
                if (staff.age != null) ('Age', staff.age!),
                if (staff.startYear != null)
                  ('Years Active', '${staff.startYear} - ${staff.endYear ?? 'Present'}'),
                if (staff.homeTown != null) ('Home Town', staff.homeTown!),
                if (staff.bloodType != null) ('Blood Type', staff.bloodType!),
              ]),
              if (staff.description.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                HtmlContent(staff.description, renderMode: RenderMode.sliverList),
              ],
            ],
          ),
        ),
        const SliverFooter(),
      ],
    );
  }
}
