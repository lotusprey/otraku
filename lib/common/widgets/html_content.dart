import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/utils/toast.dart';

class HtmlContent extends StatelessWidget {
  const HtmlContent(this.text, {this.renderMode = RenderMode.column});

  final String text;
  final RenderMode renderMode;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      renderMode: renderMode,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      onTapUrl: (url) {
        final name = _userUrl.firstMatch(url)?.group(1);
        if (name != null) {
          context.push(Routes.userByName(name));
          return true;
        }

        return Toast.launch(context, url);
      },
      onTapImage: (metadata) {
        final source = metadata.sources.firstOrNull?.url;
        if (source != null) showPopUp(context, ImageDialog(source));
      },
      factoryBuilder: () => _CustomWidgetFactory(),
      onLoadingBuilder: (_, __, ___) => const Center(child: Loader()),
      onErrorBuilder: (_, element, err) => IconButton(
        tooltip: 'Error',
        icon: const Icon(Icons.close_outlined),
        onPressed: () => showPopUp(
          context,
          ConfirmationDialog(
            title: 'Failed to load element ${element.localName}',
            content: err.toString(),
          ),
        ),
      ),
      customStylesBuilder: (element) {
        final styles = <String, String>{};

        if (element.localName == 'p') styles['white-space'] = 'pre';

        if (element.localName == 'h1' ||
            element.localName == 'h2' ||
            element.localName == 'h3') styles['font-size'] = '20px';

        if (element.localName == 'b' || element.localName == 'strong') {
          styles['font-weight'] = '500';
        }

        if (element.localName == 'i' || element.localName == 'em') {
          styles['font-style'] = 'italic';
        }

        return styles;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'hr') {
          return Container(
            height: 5,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: Consts.borderRadiusMin,
            ),
          );
        }

        return null;
      },
    );
  }
}

final _userUrl = RegExp(r'^https://anilist.co/user/([^/]*)/?$');

class _CustomWidgetFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildTree meta, ImageSource src) {
    if (!src.url.startsWith(RegExp('https?://'))) {
      return super.buildImageWidget(meta, src);
    }

    return CachedImage(
      src.url,
      fit: BoxFit.fill,
      width: src.width,
      height: src.height,
    );
  }
}
