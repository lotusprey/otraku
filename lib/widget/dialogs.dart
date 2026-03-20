import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({required this.title, required this.initialValue, this.validator});

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
      insetPadding: const .symmetric(horizontal: 30, vertical: 50),
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
  }) => showDialog(
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
          TextButton(child: Text(secondaryAction!), onPressed: () => Navigator.pop(context, false)),
        TextButton(child: Text(primaryAction), onPressed: () => Navigator.pop(context, true)),
      ],
    );
  }
}

class ImageDialog extends StatefulWidget {
  const ImageDialog(this.url, {this.cacheManager});

  final String url;
  final BaseCacheManager? cacheManager;

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
    _animationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _curveWrapper = CurvedAnimation(parent: _animationCtrl, curve: Curves.easeOutExpo);
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
    _animation = Matrix4Tween(begin: _transformCtrl.value, end: goal).animate(_curveWrapper);
    _animation!.addListener(_updateState);
    _animationCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: .zero,
      // give darkening effect
      backgroundColor: ColorScheme.of(context).surface.withAlpha(125),
      surfaceTintColor: Colors.transparent,
      //to close the image if tapped outside the image
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        // to add blurred background
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              // to center the image
              Center(
                child: GestureDetector(
                  onTap: () {},
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
                    zoomed.translateByVector3(Vector3(-_lastOffset!.dx, -_lastOffset!.dy, 0));
                    zoomed.scaleByVector3(Vector3(2.0, 2.0, 1.0));
                    _animateMatrixTo(zoomed);
                  },
                  child: InteractiveViewer(
                    clipBehavior: Clip.none,
                    transformationController: _transformCtrl,
                    child: CachedImage(widget.url, fit: BoxFit.contain, height: null),
                    //removed width null to expand image upto screen width
                  ),
                ),
              ),

              //save & more buttons
              Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(Theming.offset * 2),
                  child: Row(
                    spacing: Theming.offset,
                    children: [
                      //close button
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).onSurface.withAlpha(125),
                          borderRadius: Theming.borderRadiusSmall,
                        ),
                        child: IconButton(
                          color: ColorScheme.of(context).onPrimary,
                          tooltip: 'Close',
                          icon: const Icon(Ionicons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Spacer(), // to push last 2 buttons to the right
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).onSurface.withAlpha(125),
                          borderRadius: Theming.borderRadiusSmall,
                        ),
                        child: IconButton(
                          color: ColorScheme.of(context).onPrimary,
                          tooltip: 'Download',
                          icon: const Icon(Icons.download_outlined),
                          onPressed: () => _saveImage(context),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).onSurface.withAlpha(125),
                          borderRadius: Theming.borderRadiusSmall,
                        ),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: Theming.borderRadiusSmall),
                          tooltip: 'More',
                          iconColor: ColorScheme.of(context).onPrimary,
                          color: ColorScheme.of(context).surface,
                          elevation: 3,
                          icon: const Icon(Ionicons.ellipsis_vertical),
                          // so the popup menu is above the more button so they don't overlap
                          offset: const Offset(0, -200),
                          onSelected: (result) async {
                            switch (result) {
                              case 'copy':
                                SnackBarExtension.copy(context, widget.url);
                                Navigator.pop(context);
                              case 'browser':
                                launchUrl(
                                  Uri.parse(widget.url),
                                  mode: LaunchMode.externalApplication,
                                );
                              case 'share':
                                final file = await (widget.cacheManager ?? DefaultCacheManager())
                                    .getSingleFile(widget.url);
                                final fileName = _getFileName(widget.url, file);
                                final temp = File(
                                  '${(await getTemporaryDirectory()).path}/$fileName',
                                );
                                await file.copy(temp.path);
                                await SharePlus.instance.share(
                                  ShareParams(files: [XFile(temp.path)]),
                                );
                                await temp.delete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'copy',
                              child: ListTile(
                                leading: Icon(Ionicons.clipboard_outline),
                                title: Text('Copy URL'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'browser',
                              child: ListTile(
                                leading: Icon(Ionicons.link_outline),
                                title: Text('Open in Browser'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: ListTile(
                                leading: Icon(Ionicons.share_outline),
                                title: Text('Share Image'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //save button logic
  Future<void> _saveImage(BuildContext context) async {
    try {
      final file = await (widget.cacheManager ?? DefaultCacheManager()).getSingleFile(widget.url);
      final fileName = _getFileName(widget.url, file);
      final Directory dir;
      //save in downloads for android
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) await dir.create(recursive: true);
      } else {
        //and save in doccuments in ios since downloads doesn't exist on ios
        dir = await getApplicationDocumentsDirectory();
      }

      //logic to handle duplicate files, for "file exists error"
      final dotIndex = fileName.lastIndexOf('.');
      final name = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
      final ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';

      int i = 0;
      while (true) {
        final destPath = i == 0 ? '${dir.path}/$fileName' : '${dir.path}/$name($i)$ext';
        try {
          await file.copy(destPath);
          break;
        } on FileSystemException catch (e) {
          if (e.osError?.errorCode == 17) {
            i++;
          } else {
            rethrow;
          }
        }
      }

      if (context.mounted) {
        if (Platform.isAndroid) {
          Navigator.pop(context);
          SnackBarExtension.show(context, 'Saved to Downloads');
        } else {
          Navigator.pop(context);
          SnackBarExtension.show(context, 'Saved to Documents');
        }
      }
    } catch (e) {
      // error handler to show the exact error
      final osError = e is FileSystemException ? e.osError : null;
      final message = osError != null
          ? '${osError.message}, errno = ${osError.errorCode}'
          : e.toString();
      if (context.mounted) {
        Navigator.pop(context);
        SnackBarExtension.show(context, 'Failed to save: $message');
      }
    }
  }

  //logic to handle proper file extension since some files don't have file extension when downloaded or use a non standard extension
  String _getFileName(String url, File file) {
    final name = Uri.parse(url).pathSegments.last;

    if (name.endsWith('.gifv')) {
      return name.replaceAll('.gifv', '.mp4');
    } //to make up for Imgur's video format

    if (name.contains('.')) return name;

    //logic to handle when cached image doesn't have file extension in it's name
    try {
      final bytes = file.readAsBytesSync();
      if (bytes.length >= 4) {
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return '$name.gif';
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
          return '$name.png';
        }
        if (bytes[0] == 0xFF && bytes[1] == 0xD8) return '$name.jpg';
        if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
          return '$name.webp';
        }
      }
    } catch (_) {}

    return '$name.jpg';
  }
}

class TextDialog extends StatelessWidget {
  const TextDialog({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _DialogColumn(title: title, child: SelectableText(text));
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
        padding: const .symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const .symmetric(vertical: Theming.offset),
              child: Text(title, style: TextTheme.of(context).bodyMedium),
            ),
            const Divider(height: 2, thickness: 2),
            Flexible(
              fit: FlexFit.loose,
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const .symmetric(vertical: Theming.offset),
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
