import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/collection/collection_providers.dart';
import 'package:otraku/collection/progress_provider.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class EditButtons extends StatefulWidget {
  const EditButtons(this.mediaId, this.oldEdit, this.callback);

  final int mediaId;
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
      builder: (context, ref, __) => BottomBarDualButtonRow(
        primary: _loading
            ? null
            : BottomBarButton(
                text: 'Save',
                icon: Ionicons.save_outline,
                onTap: () async {
                  final newEdit = ref.read(editProvider);
                  setState(() => _loading = true);

                  final result = await updateEntry(newEdit);

                  if (result is! int) {
                    if (mounted) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not update entry',
                          content: result.toString(),
                        ),
                      );
                    }
                    return;
                  }

                  newEdit.entryId = result;
                  if (newEdit.entryId == null) return;
                  widget.callback?.call(newEdit);

                  final isAnime = newEdit.type == 'ANIME';
                  final tag = CollectionTag(Settings().id!, isAnime);
                  final entry =
                      await ref.read(collectionProvider(tag)).updateEntry(
                            widget.oldEdit,
                            newEdit,
                            ref.read(collectionFilterProvider(tag)).sort,
                          );
                  if (entry == null) return;

                  if (widget.oldEdit.status == null) {
                    ref.read(progressProvider).add(entry, isAnime);
                  } else {
                    ref.read(progressProvider).update(entry);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
        secondary: widget.oldEdit.entryId == null
            ? null
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
                    onConfirm: () {
                      setState(() => _loading = true);

                      final oldEdit = widget.oldEdit;
                      removeEntry(oldEdit.entryId!).then((err) {
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

                        final tag = CollectionTag(
                          Settings().id!,
                          oldEdit.type == 'ANIME',
                        );
                        ref.read(collectionProvider(tag)).removeEntry(oldEdit);

                        if (oldEdit.status == EntryStatus.CURRENT) {
                          ref.read(progressProvider).remove(oldEdit.mediaId);
                        }

                        widget.callback?.call(oldEdit.emptyCopy());
                      });
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
