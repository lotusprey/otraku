import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    required this.title,
    required this.initialValue,
    this.validator,
  });

  final String title;
  final String initialValue;
  final String? Function(String)? validator;

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final _textCtrl = TextEditingController(text: widget.initialValue);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: _textCtrl,
          decoration: InputDecoration(
            isDense: true,
            hint: const Text('Enter'),
            hintStyle: TextStyle(color: ColorScheme.of(context).onSurfaceVariant),
            border: const OutlineInputBorder(borderRadius: Theming.borderRadiusSmall),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) {
              return 'The field cannot be empty.';
            }

            if (widget.validator != null) {
              return widget.validator!(text);
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _textCtrl.text.trim());
            }
          },
          child: const Text('Confirm'),
        ),
      ],
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
  const ConfirmationDialog._({
    required this.title,
    required this.content,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String title;
  final String? content;
  final String primaryAction;
  final String? secondaryAction;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? content,
    String primaryAction = 'Ok',
    String? secondaryAction,
    void Function()? onConfirm,
  }) =>
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog._(
          title: title,
          content: content,
          primaryAction: primaryAction,
          secondaryAction: secondaryAction,
        ),
      ).then((ok) => ok == true ? onConfirm?.call() : null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content != null ? Text(content!) : null,
      actions: [
        if (secondaryAction != null)
          TextButton(
            child: Text(secondaryAction!),
            onPressed: () => Navigator.pop(context, false),
          ),
        TextButton(
          child: Text(primaryAction),
          onPressed: () => Navigator.pop(context, true),
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

class _ImageDialogState extends State<ImageDialog> with SingleTickerProviderStateMixin {
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
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
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
          zoomed.translateByVector3(
            Vector3(-_lastOffset!.dx, -_lastOffset!.dy, 0),
          );
          zoomed.scaleByVector3(
            Vector3(2.0, 2.0, 1.0),
          );
          _animateMatrixTo(zoomed);
        },
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          transformationController: _transformCtrl,
          child: CachedImage(
            widget.url,
            fit: BoxFit.contain,
            width: null,
            height: null,
          ),
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
  Widget build(BuildContext context) => _DialogColumn(
        title: title,
        child: SelectableText(text),
      );
}

class HtmlDialog extends StatelessWidget {
  const HtmlDialog({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _DialogColumn(title: title, child: HtmlContent(text));
}

class _DialogColumn extends StatelessWidget {
  const _DialogColumn({required this.title, required this.child});

  final String title;
  final Widget child;

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
              padding: const EdgeInsets.symmetric(vertical: Theming.offset),
              child: Text(
                title,
                style: TextTheme.of(context).titleMedium,
              ),
            ),
            const Divider(height: 2, thickness: 2),
            Flexible(
              fit: FlexFit.loose,
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: Theming.offset),
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
