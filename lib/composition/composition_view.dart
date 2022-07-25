import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/composition/composition_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class CompositionView extends StatefulWidget {
  CompositionView({required this.composition, required this.onDone});

  final Composition composition;

  /// When the edit is saved, a map with the new data is passed back.
  /// It can later be deserialized into the appropriate model.
  final void Function(Map<String, dynamic>) onDone;

  @override
  State<CompositionView> createState() => _CompositionViewState();
}

class _CompositionViewState extends State<CompositionView> {
  late final _ctrl = TextEditingController(text: widget.composition.text);
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => widget.composition.text = _ctrl.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpaqueSheetView(
      builder: (context, scrollCtrl) =>
          _CompositionContent(scrollCtrl: scrollCtrl, textCtrl: _ctrl),
      buttons: BottomBar(
        child: _loading
            ? const SizedBox(
                height: Consts.tapTargetSize,
                child: Center(child: Loader()),
              )
            : Row(
                children: [
                  _FormatButton(
                    tag: 'b',
                    name: 'Bold',
                    icon: Icons.format_bold_outlined,
                    textCtrl: _ctrl,
                  ),
                  _FormatButton(
                    tag: 'i',
                    name: 'Italic',
                    icon: Icons.format_italic_outlined,
                    textCtrl: _ctrl,
                  ),
                  _FormatButton(
                    tag: 'del',
                    name: 'Strikethrough',
                    icon: Icons.format_strikethrough_outlined,
                    textCtrl: _ctrl,
                  ),
                  const Spacer(),
                  if (widget.composition.isPrivate != null)
                    _PrivateButton(
                      widget.composition.isPrivate!,
                      (v) => widget.composition.isPrivate = v,
                    ),
                  TopBarIcon(
                    tooltip: 'Post',
                    icon: Ionicons.send_outline,
                    onTap: () async {
                      setState(() => _loading = true);

                      try {
                        widget.onDone(
                          await saveComposition(widget.composition),
                        );
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        showPopUp(
                          context,
                          ConfirmationDialog(
                            title: 'Could not post',
                            content: e.toString(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  _FormatButton({
    required this.tag,
    required this.name,
    required this.icon,
    required this.textCtrl,
  });

  final String tag;
  final String name;
  final IconData icon;
  final TextEditingController textCtrl;

  @override
  Widget build(BuildContext context) => TopBarIcon(
        icon: icon,
        tooltip: '$name Format',
        onTap: () {
          final txt = textCtrl.text;
          final beg = textCtrl.selection.start;
          final end = textCtrl.selection.end;
          final text = '${txt.substring(0, beg)}'
              '<$tag>'
              '${txt.substring(beg, end)}'
              '</$tag>'
              '${txt.substring(end)}';

          final offset = textCtrl.selection.isCollapsed
              ? textCtrl.selection.end + tag.length + 2
              : textCtrl.selection.end + tag.length * 2 + 5;
          textCtrl.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: offset),
          );
        },
      );
}

class _PrivateButton extends StatefulWidget {
  _PrivateButton(this.isPrivate, this.onChanged);

  final bool isPrivate;
  final void Function(bool) onChanged;

  @override
  State<_PrivateButton> createState() => __PrivateButtonState();
}

class __PrivateButtonState extends State<_PrivateButton> {
  late var _isPrivate = widget.isPrivate;

  @override
  Widget build(BuildContext context) => TopBarIcon(
        tooltip: _isPrivate ? 'Make Public' : 'Make Private',
        icon: _isPrivate ? Ionicons.eye_outline : Ionicons.eye_off_outline,
        onTap: () {
          setState(() => _isPrivate = !_isPrivate);
          widget.onChanged(_isPrivate);
          Toast.show(
            context,
            _isPrivate ? 'Message is now private' : 'Message is now public',
          );
        },
      );
}

class _CompositionContent extends StatefulWidget {
  _CompositionContent({required this.scrollCtrl, required this.textCtrl});

  final ScrollController scrollCtrl;
  final TextEditingController textCtrl;

  @override
  State<_CompositionContent> createState() => _CompositionContentState();
}

class _CompositionContentState extends State<_CompositionContent> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 60,
    );

    final onChanged = (val) => setState(() => _tab = val);

    return Stack(
      children: [
        DirectPageView(
          current: _tab,
          onChanged: onChanged,
          children: [
            TextField(
              controller: widget.textCtrl,
              scrollController: widget.scrollCtrl,
              style: Theme.of(context).textTheme.bodyText2,
              maxLines: null,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.background,
                contentPadding: padding,
              ),
            ),
            Padding(
              padding: padding,
              child: HtmlContent(widget.textCtrl.text),
            ),
          ],
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: CompactSegmentSwitcher(
            current: _tab,
            items: const ['Edit', 'Preview'],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
