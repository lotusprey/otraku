import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/loaders/loaders.dart';

class StaffOverviewSubview extends StatelessWidget {
  const StaffOverviewSubview({
    required this.staff,
    required this.scrollCtrl,
    required this.invalidate,
  });

  final Staff staff;
  final ScrollController scrollCtrl;
  final void Function() invalidate;

  @override
  Widget build(BuildContext context) {
    return ConstrainedView(
      child: CustomScrollView(
        physics: Theming.bouncyPhysics,
        controller: scrollCtrl,
        slivers: [
          SliverRefreshControl(onRefresh: invalidate),
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
              (
                'Years Active',
                '${staff.startYear} - ${staff.endYear ?? 'Present'}',
              ),
            if (staff.homeTown != null) ('Home Town', staff.homeTown!),
            if (staff.bloodType != null) ('Blood Type', staff.bloodType!),
          ]),
          if (staff.description.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 15)),
            HtmlContent(
              staff.description,
              renderMode: RenderMode.sliverList,
            ),
          ],
          const SliverFooter(),
        ],
      ),
    );
  }
}
