import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/characters/character.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class CharacterInfo extends StatelessWidget {
  const CharacterInfo(this.id, this.ctrl);

  final int id;
  final ScrollController ctrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final refreshControl = SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(characterProvider(id));
            return Future.value();
          },
        );

        final imageWidth = MediaQuery.of(context).size.width < 430.0
            ? MediaQuery.of(context).size.width * 0.30
            : 100.0;
        final imageHeight = imageWidth * Consts.coverHtoWRatio;

        return ref.watch(characterProvider(id)).when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => CustomScrollView(slivers: [refreshControl]),
              data: (data) {
                final headerRow = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: id,
                      child: ClipRRect(
                        borderRadius: Consts.borderRadiusMin,
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Theme.of(context).colorScheme.surface,
                          child: GestureDetector(
                            child: FadeImage(data.imageUrl),
                            onTap: () => showPopUp(
                              context,
                              ImageDialog(data.imageUrl),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TODO flexible?
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => Toast.copy(context, data.name),
                            child: Text(
                              data.name,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                          ),
                          if (data.altNames.isNotEmpty)
                            Text(data.altNames.join(', ')),
                          if (data.altNamesSpoilers.isNotEmpty)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'Spoiler names',
                                style: Theme.of(context).textTheme.bodyText1,
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
                  ],
                );

                final infoGrid = SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMinWidthAndFixedHeight(
                    height: Consts.tapTargetSize,
                    minWidth: 130,
                  ),
                  delegate: SliverChildListDelegate([
                    _InfoTile('Favourites', data.favorites.toString()),
                    if (data.gender != null) _InfoTile('Gender', data.gender!),
                    if (data.age != null) _InfoTile('Age', data.age!),
                    if (data.dateOfBirth != null)
                      _InfoTile('Date of Birth', data.dateOfBirth!),
                    if (data.bloodType != null)
                      _InfoTile('Blood Type', data.bloodType!),
                  ]),
                );

                return PageLayout(
                  floatingBar: FloatingBar(
                    scrollCtrl: ctrl,
                    children: [_FavoriteButton(data)],
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: Consts.layoutBig),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomScrollView(
                          controller: ctrl,
                          slivers: [
                            refreshControl,
                            SliverToBoxAdapter(child: headerRow),
                            infoGrid,
                            if (data.description.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Container(
                                  child: HtmlContent(data.description),
                                  padding: Consts.padding,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: Consts.borderRadiusMin,
                                  ),
                                ),
                              ),
                            const SliverFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
      },
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  _FavoriteButton(this.character);

  final Character character;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon:
          widget.character.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.character.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(
          () => widget.character.isFavorite = !widget.character.isFavorite,
        );
        toggleFavoriteCharacter(widget.character.id).then((ok) {
          if (!ok) {
            setState(
              () => widget.character.isFavorite = !widget.character.isFavorite,
            );
          }
        });
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  _InfoTile(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: Consts.borderRadiusMin,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(subtitle, maxLines: 1),
        ],
      ),
    );
  }
}
