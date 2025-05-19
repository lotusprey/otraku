import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/edit/edit_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/dialogs.dart';

class EditButtons extends StatelessWidget {
  const EditButtons(
    this.ref,
    this.tag,
    this.entryEdit,
    this.callback,
  );

  final WidgetRef ref;
  final EditTag tag;
  final EntryEdit? entryEdit;
  final void Function(EntryEdit)? callback;

  @override
  Widget build(BuildContext context) {
    final entryEdit = this.entryEdit;
    if (entryEdit == null) return const SizedBox();

    final saveButton = BottomBarButton(
      text: 'Save',
      icon: Ionicons.save_outline,
      onTap: () async {
        final err = await ref.read(entryEditProvider(tag).notifier).save();

        if (err == null) {
          callback?.call(entryEdit);
          if (context.mounted) Navigator.pop(context);
          return;
        }

        if (context.mounted) {
          SnackBarExtension.show(context, 'Could not update entry');
          Navigator.pop(context);
        }
      },
    );

    final removeButton = entryEdit.baseEntry.entryId == null
        ? const Spacer()
        : BottomBarButton(
            text: 'Remove',
            icon: Ionicons.trash_bin_outline,
            foregroundColor: ColorScheme.of(context).error,
            onTap: () => ConfirmationDialog.show(
              context,
              title: 'Remove entry?',
              primaryAction: 'Yes',
              secondaryAction: 'No',
              onConfirm: () async {
                final err =
                    await ref.read(entryEditProvider(tag).notifier).remove();

                if (err == null) {
                  callback?.call(entryEdit);
                  if (context.mounted) Navigator.pop(context);
                  return;
                }

                if (context.mounted) {
                  SnackBarExtension.show(context, 'Could not remove entry');
                  Navigator.pop(context);
                }
              },
            ),
          );

    return BottomBar(
      Theming.of(context).rightButtonOrientation
          ? [removeButton, saveButton]
          : [saveButton, removeButton],
    );
  }
}
