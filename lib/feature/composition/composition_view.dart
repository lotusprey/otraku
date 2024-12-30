import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/markdown.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/layout/navigation_tool.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/sheets.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/composition/composition_provider.dart';

class CompositionView extends StatelessWidget {
  const CompositionView({
    required this.tag,
    required this.onSaved,
    this.defaultText,
  });

  final CompositionTag tag;

  /// In rare cases we may want to set default text
  /// when a new composition is opened.
  final String? defaultText;

  /// When the edit is saved, a map with the new data is passed back to get
  /// deserialized.
  final void Function(Map<String, dynamic>) onSaved;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ref.watch(compositionProvider(tag)).when(
              loading: () => SheetWithButtonRow(
                builder: (context, scrollCtrl) => const Center(child: Loader()),
              ),
              error: (_, __) => SheetWithButtonRow(
                builder: (context, scrollCtrl) => const Center(
                  child: Text('Failed Loading'),
                ),
              ),
              data: (data) {
                if (defaultText != null && data.text.isEmpty) {
                  data.text = defaultText!;
                }

                return _CompositionView(
                  composition: data,
                  trySave: () async {
                    final result = await ref
                        .read(compositionProvider(tag).notifier)
                        .save();

                    return result.maybeWhen(
                      data: (data) {
                        onSaved(result.value!);
                        Navigator.pop(context);
                        return true;
                      },
                      orElse: () => false,
                    );
                  },
                );
              },
            );
      },
    );
  }
}

class _CompositionView extends StatefulWidget {
  const _CompositionView({required this.composition, required this.trySave});

  final Composition composition;
  final Future<bool> Function() trySave;

  @override
  State<_CompositionView> createState() => __CompositionViewState();
}

class __CompositionViewState extends State<_CompositionView>
    with SingleTickerProviderStateMixin {
  late final _textCtrl = TextEditingController(text: widget.composition.text);
  late final _tabCtrl = TabController(length: 2, vsync: this);
  String _parsedText = '';
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(
      () {
        setState(() {});
        if (_tabCtrl.index == 0) {
          _focus.requestFocus();
        } else {
          _focus.unfocus();
          _parsedText = parseMarkdown(_textCtrl.text);
        }
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
    return SheetWithButtonRow(
      builder: (context, scrollCtrl) => _CompositionBody(
        focus: _focus,
        tabCtrl: _tabCtrl,
        textCtrl: _textCtrl,
        scrollCtrl: scrollCtrl,
        parsedText: _parsedText,
      ),
      buttons: _BottomBar(
        composition: widget.composition,
        textCtrl: _textCtrl,
        isEditing: _tabCtrl.index == 0,
        trySave: widget.trySave,
      ),
    );
  }
}

class _CompositionBody extends StatelessWidget {
  const _CompositionBody({
    required this.focus,
    required this.tabCtrl,
    required this.textCtrl,
    required this.scrollCtrl,
    required this.parsedText,
  });

  final FocusNode focus;
  final TabController tabCtrl;
  final TextEditingController textCtrl;
  final ScrollController scrollCtrl;
  final String parsedText;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(
      left: 20,
      right: 20,
      top: 60,
      bottom: MediaQuery.paddingOf(context).bottom + Theming.offset,
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
                style: TextTheme.of(context).bodyMedium,
                decoration: InputDecoration(contentPadding: padding),
                maxLines: null,
              ),
            ),
            SingleChildScrollView(
              controller: scrollCtrl,
              child: Padding(
                padding: padding,
                child: HtmlContent(parsedText),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Theming.radiusBig),
            child: BackdropFilter(
              filter: Theming.blurFilter,
              child: Container(
                padding: Theming.paddingAll,
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
    required this.composition,
    required this.isEditing,
    required this.textCtrl,
    required this.trySave,
  });

  final Composition composition;
  final bool isEditing;
  final TextEditingController textCtrl;
  final Future<bool> Function() trySave;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    return BottomBar([
      if (widget.isEditing) ...[
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FormatButton(
                startDelimiter: '**',
                endDelimiter: '**',
                name: 'Bold',
                icon: Icons.format_bold_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '*',
                endDelimiter: '*',
                name: 'Italic',
                icon: Icons.format_italic_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '~~',
                endDelimiter: '~~',
                name: 'Strikethrough',
                icon: Icons.format_strikethrough_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '~!',
                endDelimiter: '!~',
                name: 'Spoiler',
                icon: Icons.hide_image_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '[',
                endDelimiter: ']()',
                name: 'Link',
                icon: Icons.link_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: 'img(',
                endDelimiter: ')',
                name: 'Image',
                icon: Icons.image_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: 'youtube(',
                endDelimiter: ')',
                name: 'YouTube Video',
                icon: Icons.video_collection_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: 'webm(',
                endDelimiter: ')',
                name: 'WebM Video',
                icon: Icons.videocam_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '~~~',
                endDelimiter: '~~~',
                name: 'Center',
                icon: Icons.align_horizontal_center_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '# ',
                endDelimiter: '',
                name: 'Header',
                icon: Icons.title_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '> ',
                endDelimiter: '',
                name: 'Quote',
                icon: Icons.format_quote_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '`',
                endDelimiter: '`',
                name: 'Code',
                icon: Icons.code_outlined,
                textCtrl: widget.textCtrl,
              ),
              _FormatButton(
                startDelimiter: '```',
                endDelimiter: '```',
                name: 'Code Block',
                icon: Icons.code_off_outlined,
                textCtrl: widget.textCtrl,
              ),
            ],
          ),
        ),
        Container(
          width: 3,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorScheme.of(context).outline,
          ),
        ),
      ] else
        const Spacer(),
      if (widget.composition is PrivateComposition)
        _PrivateButton(widget.composition as PrivateComposition),
      IconButton(
        tooltip: 'Post',
        icon: const Icon(Ionicons.send_outline),
        onPressed: _locked
            ? null
            : () async {
                setState(() => _locked = true);
                widget.composition.text = widget.textCtrl.text;
                if (await widget.trySave()) return;

                setState(() => _locked = false);
                if (context.mounted) {
                  SnackBarExtension.show(context, 'Failed to save');
                }
              },
      ),
    ]);
  }
}

/// Encloses the current text selection in a given markdown tag.
class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.startDelimiter,
    required this.endDelimiter,
    required this.name,
    required this.icon,
    required this.textCtrl,
  });

  final String startDelimiter;
  final String endDelimiter;
  final String name;
  final IconData icon;
  final TextEditingController textCtrl;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: name,
        icon: Icon(icon),
        onPressed: () {
          final txt = textCtrl.text;
          final beg = textCtrl.selection.start;
          final end = textCtrl.selection.end;
          if (beg < 0) return;
          final text = '${txt.substring(0, beg)}'
              '$startDelimiter'
              '${txt.substring(beg, end)}'
              '$endDelimiter'
              '${txt.substring(end)}';

          final offset = textCtrl.selection.isCollapsed
              ? textCtrl.selection.end + startDelimiter.length
              : textCtrl.selection.end +
                  startDelimiter.length +
                  endDelimiter.length;
          textCtrl.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: offset),
          );
        },
      );
}

/// Controls whether a message will be created as private or public.
class _PrivateButton extends StatefulWidget {
  const _PrivateButton(this.composition);

  final PrivateComposition composition;

  @override
  State<_PrivateButton> createState() => __PrivateButtonState();
}

class __PrivateButtonState extends State<_PrivateButton> {
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: widget.composition.isPrivate ? 'Make Public' : 'Make Private',
        icon: widget.composition.isPrivate
            ? const Icon(Ionicons.eye_outline)
            : const Icon(Ionicons.eye_off_outline),
        onPressed: () {
          setState(
            () => widget.composition.isPrivate = !widget.composition.isPrivate,
          );

          SnackBarExtension.show(
            context,
            widget.composition.isPrivate
                ? 'Message is now private'
                : 'Message is now public',
          );
        },
      );
}
