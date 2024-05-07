import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/utils/toast.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

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
        for (final matcher in _routeMatchers.entries) {
          final match = matcher.key.firstMatch(url)?.group(1);
          if (match != null) {
            context.push(matcher.value(match));
            return true;
          }
        }

        return Toast.launch(context, url);
      },
      onTapImage: (metadata) {
        final source = metadata.sources.firstOrNull?.url;
        if (source != null) showPopUp(context, ImageDialog(source));
      },
      factoryBuilder: () => _CustomWidgetFactory(),
      onLoadingBuilder: (_, __, ___) => const Center(child: Loader()),
      onErrorBuilder: (_, element, err) => Center(
        child: IconButton(
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
      ),
      customStylesBuilder: (element) {
        return switch (element.localName) {
          'br' => const {'line-height': '15px'},
          'i' || 'em' => const {'font-style': 'italic'},
          'b' || 'strong' => const {'font-weight': '500'},
          'h1' => const {'font-size': '20px', 'font-weight': '400'},
          'h2' => const {'font-size': '18px', 'font-weight': '400'},
          'h3' => const {'font-size': '17px', 'font-weight': '400'},
          'h5' => const {'font-size': '13px', 'font-weight': '400'},
          'h4' || 'h6' => const {'font-weight': '400'},
          'a' => const {'text-decoration': 'none'},
          'img' => element.attributes['width'] != null
              ? {'width': element.attributes['width']!}
              : null,
          _ => const {},
        };
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

        if (element.localName == 'youtube') {
          return GestureDetector(
            onTap: () => Toast.launch(
              context,
              'https://youtube.com/watch?v=${element.text}',
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 240,
                    maxHeight: 135,
                  ),
                  child: CachedImage(
                    'https://img.youtube.com/vi/${element.text}/0.jpg',
                  ),
                ),
                const Icon(
                  Ionicons.logo_youtube,
                  color: Color(0xFFFF0000),
                  size: 40,
                ),
              ],
            ),
          );
        }

        if (element.localName == 'video') {
          final source = element.children.firstWhere(
            (e) => e.localName == 'source',
          );
          final url = source.attributes['src'] ?? '';
          return SizedBox(
            width: double.infinity,
            child: Center(
              child: IconButton(
                tooltip: 'WebM Video',
                icon: const Icon(Ionicons.videocam, size: 50),
                onPressed: () => showSheet(
                  context,
                  GradientSheet.link(context, url),
                ),
              ),
            ),
          );
        }

        return null;
      },
    );
  }
}

final _routeMatchers = {
  RegExp(r'anilist.co\/(?:anime|manga)\/(\d+)'): (String id) =>
      Routes.media(int.parse(id)),
  RegExp(r'anilist.co\/user\/([A-Za-z0-9]+)'): (String name) =>
      Routes.userByName(name),
  RegExp(r'anilist.co\/character\/(\d+)'): (String id) =>
      Routes.character(int.parse(id)),
  RegExp(r'anilist.co\/staff\/(\d+)'): (String id) =>
      Routes.staff(int.parse(id)),
  RegExp(r'anilist.co\/studio\/(\d+)'): (String id) =>
      Routes.studio(int.parse(id)),
  RegExp(r'anilist.co\/review\/(\d+)'): (String id) =>
      Routes.review(int.parse(id)),
  RegExp(r'anilist.co\/activity\/(\d+)'): (String id) =>
      Routes.activity(int.parse(id)),
};

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
