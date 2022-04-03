import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/constants/activity_type.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class FeedView extends StatelessWidget {
  FeedView(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      init: FeedController(id),
      tag: id.toString(),
      builder: (ctrl) => Scaffold(
        appBar: ShadowAppBar(
          title: 'Activities',
          actions: [FeedFilterIcon(ctrl)],
        ),
        body: SafeArea(
          child: GetBuilder<FeedController>(
            id: FeedController.ID_ACTIVITIES,
            tag: id.toString(),
            builder: (ctrl) {
              final activities = ctrl.activities;

              if (ctrl.isLoading) return const Center(child: Loader());

              if (activities.isEmpty)
                return Center(
                  child: Text(
                    'No Activities',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                );

              return ListView.builder(
                physics: Consts.PHYSICS,
                padding: Consts.PADDING,
                controller: ctrl.scrollCtrl,
                itemBuilder: (_, i) =>
                    ActivityBox(ctrl: ctrl, model: ctrl.activities[i]),
                itemCount: ctrl.activities.length,
              );
            },
          ),
        ),
      ),
    );
  }
}

class FeedFilterIcon extends StatelessWidget {
  FeedFilterIcon(this.feedCtrl);

  final FeedController feedCtrl;

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      tooltip: 'Filter',
      icon: Ionicons.funnel_outline,
      onTap: () {
        final typeIn = feedCtrl.typeIn;
        double initialHeight =
            Consts.TAP_TARGET_SIZE * ActivityType.values.length + 20;

        // If on the home feed - following/global selection.
        bool? onFollowing;
        Widget? onFollowingSelection;
        if (feedCtrl.id == null) {
          onFollowing = feedCtrl.onFollowing;
          onFollowingSelection = TabSegments(
            items: const {'Following': true, 'Global': false},
            current: () => onFollowing!,
            onChanged: (bool val) => onFollowing = val,
          );
          initialHeight += Consts.TAP_TARGET_SIZE;
        }

        showSheet(
          context,
          OpaqueSheet(
              initialHeight: initialHeight,
              builder: (context, scrollCtrl) => ListView(
                    controller: scrollCtrl,
                    physics: Consts.PHYSICS,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        padding: Consts.PADDING,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final a in ActivityType.values)
                            CheckBoxField(
                              title: a.text,
                              initial: typeIn.contains(a),
                              onChanged: (val) =>
                                  val ? typeIn.add(a) : typeIn.remove(a),
                            )
                        ],
                      ),
                      if (onFollowingSelection != null) onFollowingSelection,
                    ],
                  )),
        ).then((_) => feedCtrl.setFilters(typeIn, onFollowing));
      },
    );
  }
}
