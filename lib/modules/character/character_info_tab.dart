import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/common/widgets/table_list.dart';
import 'package:otraku/modules/character/character_provider.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/utils/toast.dart';

class CharacterInfoTab extends StatelessWidget {
  const CharacterInfoTab(this.id, this.imageUrl, this.scrollCtrl);

  final int id;
  final String? imageUrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width < 430.0 ? size.width * 0.30 : 100.0;
    final imageHeight = imageWidth * Consts.coverHtoWRatio;

    return Consumer(
      builder: (context, ref, _) {
        final character = ref.watch(characterProvider(id));
        final imageUrl = character.valueOrNull?.imageUrl ?? this.imageUrl;

        final header = SliverToBoxAdapter(
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Hero(
                      tag: id,
                      child: ClipRRect(
                        borderRadius: Consts.borderRadiusMin,
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: GestureDetector(
                            child: CachedImage(imageUrl),
                            onTap: () =>
                                showPopUp(context, ImageDialog(imageUrl)),
                          ),
                        ),
                      ),
                    ),
                  ),
                character.unwrapPrevious().maybeWhen(
                      orElse: () => const SizedBox(),
                      data: (data) => Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () => Toast.copy(context, data.name),
                              child: Text(
                                data.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (data.altNames.isNotEmpty)
                              Text(data.altNames.join(', ')),
                            if (data.altNamesSpoilers.isNotEmpty)
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  'Spoiler names',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                onTap: () => showPopUp(
                                  context,
                                  TextDialog(
                                    title: 'Spoiler names',
                                    text: data.altNamesSpoilers.join(', '),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );

        final refreshControl = SliverRefreshControl(
          onRefresh: () => ref.invalidate(characterProvider(id)),
        );

        return ConstrainedView(
          child: character.unwrapPrevious().when(
                loading: () => CustomScrollView(
                  physics: Consts.physics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverFillRemaining(child: Center(child: Loader())),
                    const SliverFooter(),
                  ],
                ),
                error: (_, __) => CustomScrollView(
                  physics: Consts.physics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverFillRemaining(
                      child: Center(child: Text('No data')),
                    ),
                    const SliverFooter(),
                  ],
                ),
                data: (data) => CustomScrollView(
                  physics: Consts.physics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverToBoxAdapter(child: SizedBox(height: 15)),
                    TableList([
                      ('Favorites', data.favorites.toString()),
                      if (data.dateOfBirth != null)
                        ('Birth', data.dateOfBirth!),
                      if (data.age != null) ('Age', data.age!),
                      if (data.gender != null) ('Gender', data.gender!),
                      if (data.bloodType != null)
                        ('Blood Type', data.bloodType!),
                    ]),
                    if (data.description.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      HtmlContent(
                        data.description,
                        renderMode: RenderMode.sliverList,
                      ),
                    ],
                    const SliverFooter(),
                  ],
                ),
              ),
        );
      },
    );
  }
}
