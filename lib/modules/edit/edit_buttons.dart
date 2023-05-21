import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_models.dart';
import 'package:otraku/modules/collection/collection_preview_provider.dart';
import 'package:otraku/modules/collection/collection_providers.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/edit/edit_providers.dart';
import 'package:otraku/modules/filter/filter_providers.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/common/utils/options.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';

class EditButtons extends StatefulWidget {
  const EditButtons(this.tag, this.oldEdit, this.callback);

  final EditTag tag;
  final Edit oldEdit;
  final void Function(Edit)? callback;

  @override
  State<EditButtons> createState() => _EditButtonsState();
}

class _EditButtonsState extends State<EditButtons> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) => BottomBar([
        _loading
            ? const Expanded(child: Center(child: Loader()))
            : BottomBarButton(
                text: 'Save',
                icon: Ionicons.save_outline,
                onTap: () async {
                  final oldEdit = widget.oldEdit;
                  final newEdit = ref.read(newEditProvider(widget.tag));
                  setState(() => _loading = true);

                  final entry = await updateEntry(newEdit, Options().id!);

                  if (entry is! Entry) {
                    if (mounted) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not update entry',
                          content: entry.toString(),
                        ),
                      );
                    }
                    return;
                  }

                  final ofAnime = newEdit.type == 'ANIME';
                  final tag = (userId: Options().id!, ofAnime: ofAnime);

                  if (ref.read(homeProvider).didExpandCollection(ofAnime)) {
                    await ref.read(collectionProvider(tag)).updateEntry(
                          entry,
                          oldEdit,
                          newEdit,
                          ref.read(collectionFilterProvider(tag)).sort,
                        );
                  } else if (newEdit.status == EntryStatus.CURRENT ||
                      newEdit.status == EntryStatus.REPEATING) {
                    if (oldEdit.status == EntryStatus.CURRENT ||
                        oldEdit.status == EntryStatus.REPEATING) {
                      ref.read(collectionPreviewProvider(tag)).update(entry);
                    } else {
                      ref.read(collectionPreviewProvider(tag)).add(entry);
                    }
                  } else if (oldEdit.status == EntryStatus.CURRENT ||
                      oldEdit.status == EntryStatus.REPEATING) {
                    ref
                        .read(collectionPreviewProvider(tag))
                        .remove(entry.mediaId);
                  }

                  widget.callback?.call(newEdit);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
        widget.oldEdit.entryId == null
            ? const Spacer()
            : BottomBarButton(
                text: 'Remove',
                icon: Ionicons.trash_bin_outline,
                warning: true,
                onTap: () => showPopUp(
                  context,
                  ConfirmationDialog(
                    title: 'Remove entry?',
                    mainAction: 'Yes',
                    secondaryAction: 'No',
                    onConfirm: () async {
                      setState(() => _loading = true);

                      final oldEdit = widget.oldEdit;
                      final err = await removeEntry(oldEdit.entryId!);

                      if (mounted) {
                        Navigator.pop(context);

                        if (err != null) {
                          showPopUp(
                            context,
                            ConfirmationDialog(
                              title: 'Could not remove entry',
                              content: err.toString(),
                            ),
                          );
                          return;
                        }
                      } else {
                        if (err != null) return;
                      }

                      final ofAnime = oldEdit.type == 'ANIME';
                      final tag = (userId: Options().id!, ofAnime: ofAnime);

                      if (ref.read(homeProvider).didExpandCollection(ofAnime)) {
                        ref.read(collectionProvider(tag)).removeEntry(oldEdit);
                      } else if (oldEdit.status == EntryStatus.CURRENT ||
                          oldEdit.status == EntryStatus.REPEATING) {
                        ref
                            .read(collectionPreviewProvider(tag))
                            .remove(oldEdit.mediaId);
                      }

                      widget.callback?.call(oldEdit.emptyCopy());
                    },
                  ),
                ),
              ),
      ]),
    );
  }
}
