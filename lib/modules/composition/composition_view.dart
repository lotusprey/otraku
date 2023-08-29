import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/composition/composition_model.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';

class CompositionView extends StatefulWidget {
  const CompositionView({required this.composition, required this.onDone});

  final Composition composition;

  /// When the edit is saved, a map with the new data is passed back.
  /// It can later be deserialized into the appropriate model.
  final void Function(Map<String, dynamic>) onDone;

  @override
  State<CompositionView> createState() => _CompositionViewState();
}

class _CompositionViewState extends State<CompositionView>
    with SingleTickerProviderStateMixin {
  late final _textCtrl = TextEditingController(text: widget.composition.text);
  late final _tabCtrl = TabController(length: 2, vsync: this);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() => widget.composition.text = _textCtrl.text);
    _tabCtrl.addListener(
      () {
        setState(() {});
        _tabCtrl.index == 0 ? _focus.requestFocus() : _focus.unfocus();
      },
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _textCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpaqueSheetView(
      builder: (context, scrollCtrl) => _CompositionView(
        focus: _focus,
        tabCtrl: _tabCtrl,
        textCtrl: _textCtrl,
        scrollCtrl: scrollCtrl,
      ),
      buttons: _BottomBar(
        textCtrl: _textCtrl,
        isEditing: _tabCtrl.index == 0,
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
    );
  }
}

class _CompositionView extends StatelessWidget {
  const _CompositionView({
    required this.focus,
    required this.tabCtrl,
    required this.textCtrl,
    required this.scrollCtrl,
  });

  final FocusNode focus;
  final TabController tabCtrl;
  final TextEditingController textCtrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(
      left: 20,
      right: 20,
      top: 60,
      bottom: MediaQuery.of(context).padding.bottom + BottomBar.height + 10,
    );

    return Stack(
      children: [
        TabBarView(
          controller: tabCtrl,
          children: [
            SingleChildScrollView(
              controller: scrollCtrl,
              child: TextField(
                autofocus: true,
                focusNode: focus,
                controller: textCtrl,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(contentPadding: padding),
                maxLines: null,
              ),
            ),
            SingleChildScrollView(
              controller: scrollCtrl,
              child: Padding(
                padding: padding,
                child: HtmlContent('<p>${textCtrl.text}</p>'),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Consts.radiusMax),
            child: BackdropFilter(
              filter: Consts.blurFilter,
              child: Container(
                padding: Consts.padding,
                color: Theme.of(context).navigationBarTheme.backgroundColor,
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Compose'),
                      icon: Icon(Icons.edit_outlined),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Preview'),
                      icon: Icon(Icons.preview_outlined),
                    ),
                  ],
                  selected: {tabCtrl.index},
                  onSelectionChanged: (i) => tabCtrl.index = i.first,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A button menu. Some of the buttons are hidden,
/// when the user isn't on the editing tab.
class _BottomBar extends StatefulWidget {
  const _BottomBar({
    required this.isEditing,
    required this.composition,
    required this.textCtrl,
    required this.onSave,
  });

  final bool isEditing;
  final Composition composition;
  final TextEditingController textCtrl;
  final void Function() onSave;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const BottomBar(
        [Expanded(child: Center(child: Loader()))],
      );
    }

    return BottomBar([
      if (widget.isEditing) ...[
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
          widget.onSave();
        },
      ),
    ]);
  }
}

/// Encloses the current text selection in a given tag.
class _FormatButton extends StatelessWidget {
  const _FormatButton({
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
  const _PrivateButton(this.isPrivate, this.onChanged);

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
