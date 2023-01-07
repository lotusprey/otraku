import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_grid.dart';
import 'package:otraku/collection/collection_list.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_preview_provider.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class CollectionPreviewView extends StatefulWidget {
  const CollectionPreviewView({
    required this.tag,
    required this.scrollCtrl,
    super.key,
  });

  final CollectionTag tag;
  final ScrollController scrollCtrl;

  @override
  State<CollectionPreviewView> createState() => _CollectionPreviewViewState();
}

class _CollectionPreviewViewState extends State<CollectionPreviewView> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          collectionPreviewProvider(widget.tag).select((s) => s.state),
          (_, s) => s.whenOrNull(
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Failed to load collection preview',
                content: error.toString(),
              ),
            ),
          ),
        );

        Widget content;
        bool notEmpty = false;
        final notifier = ref.watch(collectionPreviewProvider(widget.tag));

        if (notifier.state.isLoading) {
          content = const SliverFillRemaining(child: Center(child: Loader()));
        } else {
          final entries = notifier.entries;
          if (entries.isEmpty) {
            content = const SliverFillRemaining(
              child: Center(child: Text('No current/repeating media')),
            );
          } else {
            notEmpty = true;
            content = Options().collectionPreviewItemView == 0
                ? CollectionList(
                    items: entries,
                    scoreFormat: notifier.scoreFormat,
                    onProgressUpdate: (_, __) {},
                  )
                : CollectionGrid(
                    items: entries,
                    scoreFormat: notifier.scoreFormat,
                    onProgressUpdate: (_, __) {},
                  );
          }
        }

        return PageLayout(
          topBar: TopBar(
            title: 'Current',
            canPop: false,
            trailing: [
              if (notEmpty)
                TopBarIcon(
                  tooltip: 'Random',
                  icon: Ionicons.shuffle_outline,
                  onTap: () {
                    final entries = ref.read(
                      collectionPreviewProvider(widget.tag).select(
                        (s) => s.entries,
                      ),
                    );
                    final e = entries[Random().nextInt(entries.length)];

                    Navigator.pushNamed(
                      context,
                      RouteArg.media,
                      arguments: RouteArg(id: e.mediaId, info: e.imageUrl),
                    );
                  },
                ),
            ],
          ),
          floatingBar: FloatingBar(
            scrollCtrl: widget.scrollCtrl,
            children: [
              ExpandedActionButton(
                title: 'Expand',
                icon: Ionicons.enter_outline,
                onTap: () =>
                    ref.read(homeProvider).expandCollection(widget.tag.ofAnime),
              ),
            ],
          ),
          child: ConstrainedView(
            child: CustomScrollView(
              physics: Consts.physics,
              controller: widget.scrollCtrl,
              slivers: [
                SliverRefreshControl(
                  onRefresh: () =>
                      ref.invalidate(collectionPreviewProvider(widget.tag)),
                ),
                content,
                const SliverFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
