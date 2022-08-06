import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/composition/composition_model.dart';
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
  final _tab = ValueNotifier(0);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => widget.composition.text = _ctrl.text);
    _tab.addListener(
      () => _tab.value == 0 ? _focus.requestFocus() : _focus.unfocus(),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpaqueSheetView(
      builder: (context, scrollCtrl) => _CompositionView(
        tab: _tab,
        focus: _focus,
        textCtrl: _ctrl,
        scrollCtrl: scrollCtrl,
      ),
      buttons: BottomBar(
        child: _ButtonRow(
          tab: _tab,
          textCtrl: _ctrl,
          composition: widget.composition,
          onSave: () async {
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
      ),
    );
  }
}

/// A view with 2 tabs - one for editing and one for an html preview.
class _CompositionView extends StatelessWidget {
  _CompositionView({
    required this.tab,
    required this.focus,
    required this.textCtrl,
    required this.scrollCtrl,
  });

  final ValueNotifier<int> tab;
  final FocusNode focus;
  final TextEditingController textCtrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 60,
    );

    return ValueListenableBuilder(
      valueListenable: tab,
      builder: (context, int i, _) => Stack(
        children: [
          DirectPageView(
            current: i,
            onChanged: (val) => tab.value = val,
            children: [
              SingleChildScrollView(
                controller: scrollCtrl,
                child: TextField(
                  autofocus: true,
                  focusNode: focus,
                  controller: textCtrl,
                  style: Theme.of(context).textTheme.bodyText2,
                  maxLines: null,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.background,
                    contentPadding: padding,
                  ),
                ),
              ),
              SingleChildScrollView(
                controller: scrollCtrl,
                child: Padding(
                  padding: padding,
                  child: HtmlContent(textCtrl.text),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: CompactSegmentSwitcher(
              current: i,
              items: const ['Compose', 'Preview'],
              onChanged: (val) => tab.value = val,
            ),
          ),
        ],
      ),
    );
  }
}

/// A button menu. Some of the buttons are hidden,
/// when the user isn't on the editing tab.
class _ButtonRow extends StatefulWidget {
  const _ButtonRow({
    required this.tab,
    required this.composition,
    required this.textCtrl,
    required this.onSave,
  });

  final ValueNotifier<int> tab;
  final Composition composition;
  final TextEditingController textCtrl;
  final void Function() onSave;

  @override
  State<_ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<_ButtonRow> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: Loader());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ValueListenableBuilder(
          valueListenable: widget.tab,
          builder: (context, i, child) => i == 0 ? child! : const SizedBox(),
          child: Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FormatButton(
                  tag: 'b',
                  name: 'Bold',
                  icon: Icons.format_bold_outlined,
                  textCtrl: widget.textCtrl,
                ),
                _FormatButton(
                  tag: 'i',
                  name: 'Italic',
                  icon: Icons.format_italic_outlined,
                  textCtrl: widget.textCtrl,
                ),
                _FormatButton(
                  tag: 'del',
                  name: 'Strikethrough',
                  icon: Icons.format_strikethrough_outlined,
                  textCtrl: widget.textCtrl,
                ),
                _FormatButton(
                  tag: 'center',
                  name: 'Center',
                  icon: Icons.align_horizontal_center_outlined,
                  textCtrl: widget.textCtrl,
                ),
                _FormatButton(
                  tag: 'code',
                  name: 'Code',
                  icon: Icons.code_outlined,
                  textCtrl: widget.textCtrl,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                widget.onSave();
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Encloses the current text selection in a given tag.
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
        tooltip: name,
        onTap: () {
          final txt = textCtrl.text;
          final beg = textCtrl.selection.start;
          final end = textCtrl.selection.end;
          if (beg < 0) return;
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

/// Controls whether a message will be created as private or public.
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
