import 'package:flutter/material.dart';
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

class ImageDialog extends StatefulWidget {
  const ImageDialog(this.url);

  final String url;

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog>
    with SingleTickerProviderStateMixin {
  final _transformCtrl = TransformationController();
  late final AnimationController _animationCtrl;
  late final CurvedAnimation _curveWrapper;
  Animation<Matrix4>? _animation;

  /// Last place the user double-tapped on.
  Offset? _lastOffset;

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _curveWrapper = CurvedAnimation(
      parent: _animationCtrl,
      curve: Curves.easeOutExpo,
    );
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _animationCtrl.dispose();
    super.dispose();
  }

  void _updateState() => _transformCtrl.value = _animation!.value;

  void _endAnimation() {
    _animation?.removeListener(_updateState);
    _animation = null;
    _animationCtrl.reset();
  }

  void _animateMatrixTo(Matrix4 goal) {
    _endAnimation();
    _animation = Matrix4Tween(
      begin: _transformCtrl.value,
      end: goal,
    ).animate(_curveWrapper);
    _animation!.addListener(_updateState);
    _animationCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(),
      child: GestureDetector(
        onDoubleTapDown: (details) => _lastOffset = details.localPosition,
        onDoubleTap: () {
          // If zoomed in, zoom out.
          if (_transformCtrl.value.getMaxScaleOnAxis() > 1) {
            _animateMatrixTo(Matrix4.identity());
            return;
          }

          // Can't be null, but checking just in case.
          if (_lastOffset == null) return;

          // If zoomed out, zoom in towards the tapped spot.
          final zoomed = _transformCtrl.value.clone();
          zoomed.translate(-_lastOffset!.dx, -_lastOffset!.dy, 0);
          zoomed.scale(2.0, 2.0, 1.0);
          _animateMatrixTo(zoomed);
        },
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          transformationController: _transformCtrl,
          child: Image.network(widget.url),
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
