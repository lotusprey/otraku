import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/media/media_provider.dart';
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
    return FloatingActionButton(
      tooltip: media.edit.status == null ? 'Add' : 'Edit',
      heroTag: 'edit',
      child: media.edit.status == null
          ? const Icon(Icons.add)
          : const Icon(Icons.edit_outlined),
      onPressed: () => showSheet(
        context,
        EditView(
          (id: media.info.id, setComplete: false),
          callback: (edit) => setState(() => media.edit = edit),
        ),
      ),
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

        return FloatingActionButton(
          tooltip: 'Language',
          heroTag: 'language',
          child: const Icon(Ionicons.globe_outline),
          onPressed: () => showSheet(
            context,
            SimpleSheet.list([
              for (int i = 0; i < languages.length; i++)
                ListTile(
                  title: Text(languages.elementAt(i)),
                  selected: languages.elementAt(i) == language,
                  onTap: () {
                    ref
                        .read(mediaRelationsProvider(widget.id).notifier)
                        .changeLanguage(languages.elementAt(i));
                    Navigator.pop(context);
                  },
                ),
            ]),
          ),
        );
      },
    );
  }
}
