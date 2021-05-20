import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/html_content.dart';

Future<dynamic> showPopUp(BuildContext ctx, Widget child) =>
    showDialog(context: ctx, builder: (ctx) => _PopUpAnimation(child));

class _PopUpAnimation extends StatefulWidget {
  final Widget child;
  const _PopUpAnimation(this.child);

  @override
  __PopUpAnimationState createState() => __PopUpAnimationState();
}

class __PopUpAnimationState extends State<_PopUpAnimation>
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

class ImageDialog extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ImageDialog(this.url, [this.fit = BoxFit.cover]);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      shape: const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: Config.BORDER_RADIUS,
        child: Image.network(url, fit: fit),
      ),
    );
  }
}

class TextDialog extends StatelessWidget {
  final String title;
  final String text;
  const TextDialog({required this.title, required this.text});

  @override
  Widget build(BuildContext context) =>
      _Dialog(title: title, expand: false, child: Text(text));
}

class HtmlDialog extends StatelessWidget {
  final String title;
  final String text;
  const HtmlDialog({required this.title, required this.text});

  @override
  Widget build(BuildContext context) =>
      _Dialog(title: title, expand: true, child: HtmlContent(text));
}

class _Dialog extends StatelessWidget {
  final String title;
  final Widget child;
  final bool expand;

  const _Dialog({
    required this.title,
    required this.child,
    required this.expand,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      backgroundColor: Theme.of(context).backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Config.RADIUS),
                color: Theme.of(context).backgroundColor,
              ),
              padding: Config.PADDING,
              child: Text(title, style: Theme.of(context).textTheme.subtitle1),
            ),
            Flexible(
              fit: expand ? FlexFit.tight : FlexFit.loose,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Config.RADIUS),
                  color: Theme.of(context).primaryColor,
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: Config.PHYSICS,
                    padding: Config.PADDING,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
