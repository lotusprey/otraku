import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';

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
          (id: media.info.id, setComplete: false),
          callback: (edit) => setState(() => media.edit = edit),
        ),
      ),
    );
  }
}

class MediaFavoriteButton extends StatefulWidget {
  const MediaFavoriteButton(this.info, this.toggleFavorite);

  final MediaInfo info;
  final Future<bool> Function() toggleFavorite;

  @override
  State<MediaFavoriteButton> createState() => _MediaFavoriteButtonState();
}

class _MediaFavoriteButtonState extends State<MediaFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return ActionButton(
      icon: info.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: info.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => info.isFavorite = !info.isFavorite);
        widget.toggleFavorite().then((ok) {
          if (!ok) {
            setState(() => info.isFavorite = !info.isFavorite);
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
        final languages = ref.watch(
          mediaRelationsProvider(widget.id).select(
            (s) => s.valueOrNull?.languages,
          ),
        );
        final language = ref.watch(
          mediaRelationsProvider(widget.id).select(
            (s) => s.valueOrNull?.language,
          ),
        );

        if (language == null || languages == null || languages.length < 2) {
          return const SizedBox();
        }

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () => showSheet(
            context,
            GradientSheet([
              for (int i = 0; i < languages.length; i++)
                GradientSheetButton(
                  text: languages.elementAt(i),
                  selected: languages.elementAt(i) == language,
                  onTap: () => ref
                      .read(mediaRelationsProvider(widget.id).notifier)
                      .changeLanguage(languages.elementAt(i)),
                ),
            ]),
          ),
        );
      },
    );
  }
}
