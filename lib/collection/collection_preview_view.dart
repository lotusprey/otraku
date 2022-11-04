import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_grid.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_preview_provider.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
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
                title: 'Could not load collection preview',
                content: error.toString(),
              ),
            ),
          ),
        );

        Widget content;
        final notifier = ref.watch(collectionPreviewProvider(widget.tag));

        if (notifier.state.isLoading) {
          content = const SliverFillRemaining(child: Center(child: Loader()));
        } else {
          final entries = notifier.entries;
          if (entries.isEmpty) {
            content = const SliverFillRemaining(
              child: Center(child: Text('No current media')),
            );
          } else {
            content = CollectionGrid(
              items: entries,
              scoreFormat: notifier.scoreFormat,
              onProgressUpdate: (_, __) {},
            );
          }
        }

        return PageLayout(
          topBar: const TopBar(title: 'Current', canPop: false),
          floatingBar: FloatingBar(
            scrollCtrl: widget.scrollCtrl,
            children: [
              FloatingActionButton.extended(
                icon: const Icon(Ionicons.enter_outline),
                label: const Text('Expand'),
                onPressed: () =>
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
