import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/html_content.dart';

Future<T?> showPopUp<T>(BuildContext context, Widget child) => showDialog<T>(
      context: context,
      builder: (context) => PopUpAnimation(child),
    );

class PopUpAnimation extends StatefulWidget {
  const PopUpAnimation(this.child);

  final Widget child;

  @override
  PopUpAnimationState createState() => PopUpAnimationState();
}

class PopUpAnimationState extends State<PopUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.1,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _anim,
        child: widget.child,
      );
}

class InputDialog extends StatelessWidget {
  const InputDialog({required this.initial, required this.onChanged});

  final String initial;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    String text = initial;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: TextFormField(
          maxLines: 5,
          autofocus: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1,
          decoration: const InputDecoration(
            filled: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          keyboardType: TextInputType.name,
          initialValue: initial,
          onChanged: (t) => text = t,
          onEditingComplete: () {
            onChanged(text.trim());
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

// A basic container for a dialog.
class DialogBox extends StatelessWidget {
  const DialogBox(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: child,
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    this.mainAction = 'Ok',
    this.content,
    this.secondaryAction,
    this.onConfirm,
  });

  final String title;
  final String? content;
  final String mainAction;
  final String? secondaryAction;
  final void Function()? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content != null ? Text(content!) : null,
      actions: [
        if (secondaryAction != null)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(secondaryAction!),
            onPressed: () => Navigator.pop(context),
          ),
        TextButton(
          child: Text(mainAction),
          onPressed: () {
            onConfirm?.call();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog(this.url, [this.fit = BoxFit.cover]);

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      shape: const RoundedRectangleBorder(borderRadius: Consts.borderRadiusMin),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: Consts.borderRadiusMin,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: Image.network(url, fit: fit),
        ),
      ),
    );
  }
}

class TextDialog extends StatelessWidget {
  const TextDialog({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) =>
      _DialogColumn(title: title, expand: false, child: Text(text));
}

class HtmlDialog extends StatelessWidget {
  const HtmlDialog({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) =>
      _DialogColumn(title: title, expand: true, child: HtmlContent(text));
}

class _DialogColumn extends StatelessWidget {
  const _DialogColumn({
    required this.title,
    required this.child,
    required this.expand,
  });

  final String title;
  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return DialogBox(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(title, style: Theme.of(context).textTheme.headline2),
            ),
            const Divider(height: 2, thickness: 2),
            Flexible(
              fit: expand ? FlexFit.tight : FlexFit.loose,
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
