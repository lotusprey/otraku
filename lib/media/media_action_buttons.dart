import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaEditButton extends StatefulWidget {
  const MediaEditButton(this.media);

  final Media media;

  @override
  State<MediaEditButton> createState() => _MediaEditButtonState();
}

class _MediaEditButtonState extends State<MediaEditButton> {
  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return ActionButton(
      icon: media.edit.status == null ? Icons.add : Icons.edit_outlined,
      tooltip: media.edit.status == null ? 'Add' : 'Edit',
      onTap: () => showSheet(
        context,
        EditView(
          EditTag(media.info.id),
          callback: (edit) => setState(() => media.edit = edit),
        ),
      ),
    );
  }
}

class MediaFavoriteButton extends StatefulWidget {
  const MediaFavoriteButton(this.info);

  final MediaInfo info;

  @override
  State<MediaFavoriteButton> createState() => _MediaFavoriteButtonState();
}

class _MediaFavoriteButtonState extends State<MediaFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.info.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.info.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => widget.info.isFavorite = !widget.info.isFavorite);
        toggleFavoriteMedia(
          widget.info.id,
          widget.info.type == DiscoverType.anime,
        ).then((ok) {
          if (!ok) {
            setState(() => widget.info.isFavorite = !widget.info.isFavorite);
          }
        });
      },
    );
  }
}

class MediaLanguageButton extends StatefulWidget {
  const MediaLanguageButton(this.id, this.tabCtrl);

  final int id;
  final TabController tabCtrl;

  @override
  State<MediaLanguageButton> createState() => _MediaLanguageButtonState();
}

class _MediaLanguageButtonState extends State<MediaLanguageButton> {
  late bool _hidden = widget.tabCtrl.index != MediaTab.characters.index;

  @override
  void initState() {
    super.initState();
    widget.tabCtrl.addListener(_listener);
  }

  @override
  void dispose() {
    widget.tabCtrl.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final hidden = widget.tabCtrl.index != MediaTab.characters.index;
    if (hidden != _hidden) setState(() => _hidden = hidden);
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox();

    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(mediaRelationsProvider(widget.id).select(
          (s) => s.languages.length < 2,
        ))) return const SizedBox();

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () {
            final mediaRelations = ref.read(mediaRelationsProvider(widget.id));
            final languages = mediaRelations.languages;
            final language = mediaRelations.language;

            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) => ref
                    .read(mediaRelationsProvider(widget.id).notifier)
                    .changeLanguage(languages.elementAt(i)),
                children: [
                  for (int i = 0; i < languages.length; i++)
                    Text(
                      languages.elementAt(i),
                      style: languages.elementAt(i) != language
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
