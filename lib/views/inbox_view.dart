import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/activity/activities_view.dart';
import 'package:otraku/activity/activity_providers.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/collection/progress_provider.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/composition/composition_view.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/settings/settings_provider.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/grids/minimal_collection_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class InboxView extends StatelessWidget {
  const InboxView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = Consumer(
      builder: (context, ref, child) {
        final count = ref.watch(
          userSettingsProvider.select((s) => s.notificationCount),
        );

        final openNotifications = () {
          ref.read(userSettingsProvider.notifier).nullifyUnread();
          Navigator.pushNamed(context, RouteArg.notifications);
        };

        if (count < 1) {
          return TopBarIcon(
            tooltip: 'Notifications',
            icon: Ionicons.notifications_outline,
            onTap: openNotifications,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Tooltip(
            message: 'Notifications',
            child: GestureDetector(
              onTap: openNotifications,
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
                        count.toString(),
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

    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.watch(homeProvider);

        return PageLayout(
          floatingBar: FloatingBar(
            scrollCtrl: scrollCtrl,
            children: [
              ActionButton(
                tooltip: 'New Post',
                icon: Icons.edit_outlined,
                onTap: () => showSheet(
                  context,
                  CompositionView(
                    composition: Composition.status(null, ''),
                    onDone: (map) => ref
                        .read(activitiesProvider(null).notifier)
                        .insertActivity(map, Settings().id!),
                  ),
                ),
              ),
              ActionTabSwitcher(
                current: notifier.inboxOnFeed ? 1 : 0,
                onChanged: (i) => ref.read(homeProvider).inboxOnFeed = i == 1,
                items: const ['Progress', 'Feed'],
              ),
            ],
          ),
          topBar: TopBar(
            canPop: false,
            title: notifier.inboxOnFeed ? 'Feed' : 'Progress',
            items: [
              if (notifier.inboxOnFeed)
                TopBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => showActivityFilterSheet(context, ref, null),
                )
              else
                const SizedBox(width: 45),
              notificationIcon,
            ],
          ),
          child: DirectPageView(
            onChanged: null,
            current: notifier.inboxOnFeed ? 1 : 0,
            children: [
              _ProgressView(scrollCtrl),
              ActivitiesSubView(null, scrollCtrl),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressView extends StatefulWidget {
  const _ProgressView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  State<_ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<_ProgressView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Consumer(
        builder: (context, ref, _) {
          ref.listen<AsyncValue>(
            progressProvider.select((s) => s.state),
            (_, s) => s.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load current media',
                  content: error.toString(),
                ),
              ),
            ),
          );

          const titles = [
            'Releasing Anime',
            'Other Anime',
            'Releasing Manga',
            'Other Manga',
          ];
          final children = <Widget>[];

          ref.watch(progressProvider.select((s) => s.state)).when(
                error: (_, __) => children.add(
                  const SliverFillRemaining(
                    child: Center(child: Text('Could not load current media')),
                  ),
                ),
                loading: () => children.add(
                  const SliverFillRemaining(child: Center(child: Loader())),
                ),
                data: (data) {
                  for (int i = 0; i < data.lists.length; i++) {
                    if (data.lists[i].isEmpty) continue;

                    children.add(
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            titles[i],
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                      ),
                    );

                    children.add(
                      MinimalCollectionGrid(
                        items: data.lists[i],
                        updateProgress: (e) => _updateProgress(ref, e, i < 2),
                      ),
                    );
                  }
                },
              );

          return CustomScrollView(
            physics: Consts.physics,
            controller: widget.scrollCtrl,
            slivers: [
              SliverRefreshControl(
                onRefresh: () {
                  ref.invalidate(progressProvider);
                  return Future.value();
                },
              ),
              ...children,
              const SliverFooter(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateProgress(WidgetRef ref, Entry e, bool ofAnime) async {
    final result = await updateProgress(e.mediaId, e.progress);
    if (result is! List<String>) {
      if (mounted) {
        showPopUp(
          context,
          ConfirmationDialog(
            title: 'Could not update progress',
            content: result.toString(),
          ),
        );
      }
      return;
    }

    final tag = CollectionTag(Settings().id!, ofAnime);
    ref.read(collectionProvider(tag)).updateProgress(
          mediaId: e.mediaId,
          progress: e.progress,
          customLists: result,
          listStatus: EntryStatus.CURRENT,
          format: null,
          sort: ref.read(collectionFilterProvider(tag)).sort,
        );
  }
}
