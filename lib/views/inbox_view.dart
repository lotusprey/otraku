import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/list_status.dart';
import 'package:otraku/constants/media_status.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/feed_controller.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/list_entry_model.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/feed_view.dart';
import 'package:otraku/widgets/activity_box.dart';
import 'package:otraku/widgets/layouts/minimal_collection_grid.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_refresh_control.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/navigation/header_layout.dart';

class InboxView extends StatelessWidget {
  InboxView(this.feedCtrl, this.scrollCtrl);

  final FeedController feedCtrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = GetBuilder<HomeController>(
      id: HomeController.ID_NOTIFICATIONS,
      builder: (homeCtrl) {
        if (homeCtrl.notificationCount < 1)
          return AppBarIcon(
            tooltip: 'Notifications',
            icon: Ionicons.notifications_outline,
            onTap: () => Navigator.pushNamed(context, RouteArg.notifications),
          );

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Tooltip(
            message: 'Notifications',
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, RouteArg.notifications),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    child: Icon(
                      Ionicons.notifications_outline,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                      maxHeight: 20,
                    ),
                    margin: const EdgeInsets.only(right: 15, bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        homeCtrl.notificationCount.toString(),
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context).colorScheme.background,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return GetBuilder<HomeController>(
      id: HomeController.ID_HOME,
      builder: (ctrl) {
        return HeaderLayout(
          topItems: [
            Expanded(
              child: TabSegments(
                items: const {'Progress': false, 'Feed': true},
                initial: ctrl.onFeed,
                onChanged: (bool val) => ctrl.onFeed = val,
              ),
            ),
            if (ctrl.onFeed)
              FeedFilterIcon(feedCtrl)
            else
              const SizedBox(width: 45),
            notificationIcon,
          ],
          builder: (context, offsetTop) {
            late final Widget child;

            if (ctrl.onFeed)
              child = _Feed(feedCtrl, scrollCtrl, offsetTop);
            else
              child = GetBuilder<CollectionController>(
                id: CollectionController.ID_BODY,
                tag: '${Settings().id}true',
                builder: (animeCtrl) => GetBuilder<CollectionController>(
                  id: CollectionController.ID_BODY,
                  tag: '${Settings().id}false',
                  builder: (mangaCtrl) => CustomScrollView(
                    controller: scrollCtrl,
                    slivers: [
                      SliverToBoxAdapter(child: SizedBox(height: offsetTop)),
                      ..._progressWidgets(context, animeCtrl, mangaCtrl),
                      SliverToBoxAdapter(
                        child: SizedBox(height: NavLayout.offset(context)),
                      ),
                    ],
                  ),
                ),
              );

            return AnimatedSwitcher(
              duration: Consts.TRANSITION_DURATION,
              child: child,
            );
          },
        );
      },
    );
  }

  List<Widget> _progressWidgets(
    BuildContext context,
    CollectionController animeCtrl,
    CollectionController mangaCtrl,
  ) {
    final slivers = <Widget>[];

    if (animeCtrl.isLoading)
      slivers.add(const SliverFillRemaining(child: Center(child: Loader())));
    else {
      final entries = animeCtrl.listWithStatus(ListStatus.CURRENT);
      if (entries.isNotEmpty) {
        final releasing = <ListEntryModel>[];
        final other = <ListEntryModel>[];
        for (final e in entries)
          e.status == MediaStatus.RELEASING.name
              ? releasing.add(e)
              : other.add(e);

        _addProgressSection(
          title: 'Releasing Anime',
          items: releasing,
          context: context,
          slivers: slivers,
          ctrl: animeCtrl,
        );
        _addProgressSection(
          title: 'Other Anime',
          items: other,
          context: context,
          slivers: slivers,
          ctrl: animeCtrl,
        );
      }
    }

    if (mangaCtrl.isLoading && slivers.length > 1)
      slivers.add(const SliverFillRemaining(child: Center(child: Loader())));
    else {
      final entries = mangaCtrl.listWithStatus(ListStatus.CURRENT);
      if (entries.isNotEmpty) {
        final releasing = <ListEntryModel>[];
        final other = <ListEntryModel>[];
        for (final e in entries)
          e.status == MediaStatus.RELEASING.name
              ? releasing.add(e)
              : other.add(e);

        _addProgressSection(
          title: 'Releasing Manga',
          items: releasing,
          context: context,
          slivers: slivers,
          ctrl: mangaCtrl,
        );
        _addProgressSection(
          title: 'Other Manga',
          items: other,
          context: context,
          slivers: slivers,
          ctrl: mangaCtrl,
        );
      }
    }

    if (slivers.isEmpty)
      slivers.add(const SliverFillRemaining(
        child: Center(
          child: Text('You don\'t watch/read anything in the moment.'),
        ),
      ));

    return slivers;
  }

  void _addProgressSection({
    required BuildContext context,
    required List<Widget> slivers,
    required String title,
    required List<ListEntryModel> items,
    required CollectionController ctrl,
  }) {
    if (items.isEmpty) return;

    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(title, style: Theme.of(context).textTheme.headline2),
      ),
    ));

    slivers.add(SliverPadding(
      padding: Consts.PADDING,
      sliver: MinimalCollectionGrid(
        items: items,
        updateProgress: ctrl.updateProgress,
      ),
    ));
  }
}

class _Feed extends StatefulWidget {
  _Feed(this.ctrl, this.scrollCtrl, this.offsetTop);

  final FeedController ctrl;
  final ScrollController scrollCtrl;
  final double offsetTop;

  @override
  State<_Feed> createState() => __FeedState();
}

class __FeedState extends State<_Feed> {
  Future<void> _listener() async {
    if (widget.ctrl.isLoading ||
        widget.scrollCtrl.position.pixels <
            widget.scrollCtrl.position.maxScrollExtent - 100)
      return Future.value();

    await widget.ctrl.fetchPage();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_listener);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      id: FeedController.ID_ACTIVITIES,
      builder: (feedCtrl) {
        late Widget content;
        if (feedCtrl.isLoading)
          content = const SliverFillRemaining(child: Center(child: Loader()));
        else {
          final activities = feedCtrl.activities;
          if (activities.isEmpty)
            content = SliverFillRemaining(
              child: Center(
                child: Text(
                  'No Activities',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            );
          else
            content = SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ActivityBox(ctrl: feedCtrl, model: activities[i]),
                childCount: activities.length,
              ),
            );
        }

        return CustomScrollView(
          physics: Consts.PHYSICS,
          controller: widget.scrollCtrl,
          slivers: [
            SliverRefreshControl(
              onRefresh: () => widget.ctrl.fetchPage(clean: true),
              canRefresh: () => !widget.ctrl.isLoading,
              offsetTop: widget.offsetTop - 10,
            ),
            SliverPadding(padding: Consts.PADDING, sliver: content),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: NavLayout.offset(context) + 10,
              ),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child:
                      feedCtrl.hasNextPage ? const Loader() : const SizedBox(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
