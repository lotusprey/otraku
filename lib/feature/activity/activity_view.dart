import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/activity/activities_model.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/feature/activity/activities_provider.dart';
import 'package:otraku/feature/activity/activity_model.dart';
import 'package:otraku/feature/activity/activity_provider.dart';
import 'package:otraku/feature/activity/activity_card.dart';
import 'package:otraku/feature/activity/reply_card.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/composition/composition_view.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/sheets.dart';

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView(this.id, this.sourceTag);

  final int id;
  final ActivitiesTag? sourceTag;

  @override
  ConsumerState<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final _scrollCtrl = PagedController(
    loadMore: () => ref.read(activityProvider(widget.id).notifier).fetch(),
  );

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = ref.watch(
      activityProvider(widget.id).select((s) => s.value?.activity),
    );

    return AdaptiveScaffold(
      topBar: TopBar(
        trailing: [if (activity != null) _TopBarContent(activity)],
      ),
      floatingAction: HidingFloatingActionButton(
        key: const Key('Reply'),
        scrollCtrl: _scrollCtrl,
        child: FloatingActionButton(
          tooltip: 'New Reply',
          child: const Icon(Icons.edit_outlined),
          onPressed: () => showSheet(
            context,
            CompositionView(
              tag: ActivityReplyCompositionTag(
                id: null,
                activityId: widget.id,
              ),
              onSaved: (map) => ref.read(activityProvider(widget.id).notifier).appendReply(map),
            ),
          ),
        ),
      ),
      child: _View(
        id: widget.id,
        sourceTag: widget.sourceTag,
        scrollCtrl: _scrollCtrl,
      ),
    );
  }
}

class _TopBarContent extends StatelessWidget {
  const _TopBarContent(this.activity);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(
                Routes.user(activity.authorId, activity.authorAvatarUrl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: activity.authorId,
                    child: ClipRRect(
                      borderRadius: Theming.borderRadiusSmall,
                      child: CachedImage(
                        activity.authorAvatarUrl,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: Theming.offset),
                  Flexible(
                    child: Text(
                      activity.authorName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...switch (activity) {
            MessageActivity message => [
                if (message.isPrivate)
                  const Padding(
                    padding: EdgeInsets.only(left: Theming.offset),
                    child: Icon(Ionicons.eye_off_outline),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Theming.offset),
                  child: Icon(Icons.arrow_right_alt),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push(
                    Routes.user(
                      message.recipientId,
                      message.recipientAvatarUrl,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: Theming.borderRadiusSmall,
                    child: CachedImage(
                      message.recipientAvatarUrl,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ],
            _ when activity.isPinned => const [
                Padding(
                  padding: EdgeInsets.only(left: Theming.offset),
                  child: Icon(Icons.push_pin_outlined),
                ),
              ],
            _ => const [],
          },
        ],
      ),
    );
  }
}

class _View extends ConsumerWidget {
  const _View({
    required this.id,
    required this.sourceTag,
    required this.scrollCtrl,
  });

  final int id;
  final ActivitiesTag? sourceTag;
  final PagedController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      activityProvider(id),
      (_, s) => s.whenOrNull(
        error: (error, _) => SnackBarExtension.show(context, error.toString()),
      ),
    );

    final viewerId = ref.watch(viewerIdProvider);

    final analogClock = ref.watch(
      persistenceProvider.select((s) => s.options.analogClock),
    );

    return ref.watch(activityProvider(id)).unwrapPrevious().when(
          loading: () => const Center(child: Loader()),
          error: (_, __) => const Center(
            child: Text('Failed to load activity'),
          ),
          data: (data) {
            return ConstrainedView(
              child: CustomScrollView(
                physics: Theming.bouncyPhysics,
                controller: scrollCtrl,
                slivers: [
                  SliverRefreshControl(
                    onRefresh: () => ref.invalidate(activityProvider(id)),
                  ),
                  SliverToBoxAdapter(
                    child: ActivityCard(
                      withHeader: false,
                      analogClock: analogClock,
                      activity: data.activity,
                      footer: ActivityFooter(
                        viewerId: viewerId,
                        activity: data.activity,
                        toggleLike: () => _toggleLike(ref, data.activity),
                        toggleSubscription: () => _toggleSubscription(ref, data.activity),
                        togglePin: () => _togglePin(ref, data.activity),
                        remove: () => _remove(context, ref, data.activity),
                        onEdited: (map) => _onEdited(ref, map),
                        reply: () => _reply(context, ref, data.activity),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: data.replies.items.length,
                      (context, i) => ReplyCard(
                        activityId: id,
                        analogClock: analogClock,
                        reply: data.replies.items[i],
                        toggleLike: () => ref
                            .read(activityProvider(id).notifier)
                            .toggleReplyLike(data.replies.items[i].id),
                      ),
                    ),
                  ),
                  SliverFooter(loading: data.replies.hasNext),
                ],
              ),
            );
          },
        );
  }

  Future<Object?> _toggleLike(WidgetRef ref, Activity activity) {
    if (sourceTag != null) {
      return ref.read(activitiesProvider(sourceTag!).notifier).toggleLike(activity);
    }

    return ref.read(activityProvider(id).notifier).toggleLike();
  }

  Future<Object?> _toggleSubscription(WidgetRef ref, Activity activity) {
    if (sourceTag != null) {
      return ref.read(activitiesProvider(sourceTag!).notifier).toggleSubscription(activity);
    }

    return ref.read(activityProvider(id).notifier).toggleSubscription();
  }

  Future<Object?> _togglePin(WidgetRef ref, Activity activity) {
    if (sourceTag != null) {
      return ref.read(activitiesProvider(sourceTag!).notifier).togglePin(activity);
    }

    return ref.read(activityProvider(id).notifier).togglePin();
  }

  Future<Object?> _remove(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    Navigator.pop(context);

    if (sourceTag != null) {
      return ref.read(activitiesProvider(sourceTag!).notifier).remove(activity);
    }

    return ref.read(activityProvider(id).notifier).remove();
  }

  void _onEdited(WidgetRef ref, Map<String, dynamic> map) {
    final persistence = ref.read(persistenceProvider);

    final activity = Activity.maybe(
      map,
      persistence.accountGroup.account?.id,
      persistence.options.imageQuality,
    );

    if (activity == null) return;

    ref.read(activityProvider(id).notifier).replace(activity);
    if (sourceTag != null) {
      ref.read(activitiesProvider(sourceTag!).notifier).replace(activity);
    }
  }

  Future<void> _reply(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    return showSheet(
      context,
      CompositionView(
        defaultText: '@${activity.authorName} ',
        tag: ActivityReplyCompositionTag(id: null, activityId: id),
        onSaved: (map) => ref.read(activityProvider(id).notifier).appendReply(map),
      ),
    );
  }
}
