import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/collection/progress_provider.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/feed/minimal_collection_grid.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
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
                onRefresh: () => ref.invalidate(progressProvider),
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

    final tag = CollectionTag(Options().id!, ofAnime);
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
