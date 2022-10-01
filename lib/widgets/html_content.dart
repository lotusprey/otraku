import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class HtmlContent extends StatelessWidget {
  const HtmlContent(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      textStyle: Theme.of(context).textTheme.bodyText2,
      onTapUrl: (url) => Toast.launch(context, url),
      onLoadingBuilder: (_, __, ___) => const Center(child: Loader()),
      onErrorBuilder: (_, element, err) => IconButton(
        icon: const Icon(Icons.close),
        color: Theme.of(context).colorScheme.error,
        onPressed: () => showPopUp(
          context,
          ConfirmationDialog(
            title: 'Couldn\'t load element ${element.localName}',
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
