import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/collection/collection_provider.dart';
import 'package:otraku/modules/edit/edit_model.dart';
import 'package:otraku/modules/edit/edit_providers.dart';
import 'package:otraku/common/utils/persistence.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
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
      builder: (context, ref, __) {
        final saveButton = _loading
            ? const Expanded(child: Center(child: Loader()))
            : _saveButton(context, ref);
        final removeButton = widget.oldEdit.entryId == null
            ? const Spacer()
            : _removeButton(context, ref);

        return BottomBar(
          Persistence().leftHanded
              ? [saveButton, removeButton]
              : [removeButton, saveButton],
        );
      },
    );
  }

  Widget _saveButton(BuildContext context, WidgetRef ref) => BottomBarButton(
        text: 'Save',
        icon: Ionicons.save_outline,
        onTap: () async {
          final oldEdit = widget.oldEdit;
          final newEdit = ref.read(newEditProvider(widget.tag));
          setState(() => _loading = true);

          final tag =
              (userId: Persistence().id!, ofAnime: oldEdit.type == 'ANIME');
          final err = await ref
              .read(collectionProvider(tag).notifier)
              .saveEntry(oldEdit, newEdit);

          if (err == null) {
            widget.callback?.call(newEdit);
            if (context.mounted) Navigator.pop(context);
            return;
          }

          if (context.mounted) {
            Navigator.pop(context);
            showPopUp(
              context,
              ConfirmationDialog(title: 'Could not update entry', content: err),
            );
          }
        },
      );

  Widget _removeButton(BuildContext context, WidgetRef ref) => BottomBarButton(
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
              final tag = (
                userId: Persistence().id!,
                ofAnime: oldEdit.type == 'ANIME',
              );

              final err = await ref
                  .read(collectionProvider(tag).notifier)
                  .removeEntry(oldEdit);

              if (err == null) {
                widget.callback?.call(oldEdit.emptyCopy());
                if (context.mounted) Navigator.pop(context);
                return;
              }

              if (context.mounted) {
                Navigator.pop(context);
                showPopUp(
                  context,
                  ConfirmationDialog(
                    title: 'Could not remove entry',
                    content: err,
                  ),
                );
              }
            },
          ),
        ),
      );
}
