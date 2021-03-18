import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlContent extends StatelessWidget {
  final String? text;
  HtmlContent(this.text);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text!,
      textStyle: Theme.of(context).textTheme.bodyText1,
      hyperlinkColor: Theme.of(context).accentColor,
      onTapUrl: (url) async {
        try {
          await launch(url);
        } catch (err) {
          Toast.show(context, 'Couldn\'t open link: $err');
        }
      },
      customStylesBuilder: (element) {
        final styles = <String, String>{};
        if (element.localName == 'h1' ||
            element.localName == 'h2' ||
            element.localName == 'h3') styles['font-size'] = '20px';
        if (element.localName == 'b') styles['font-weight'] = '500';
        return styles.isEmpty ? null : styles;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'hr')
          return Container(
            height: 5,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: Config.BORDER_RADIUS,
            ),
          );

        if (element.localName == 'a') {
          final link = element.attributes['href'];
          if (link == null) return null;
        }

        return null;
      },
    );
  }
}
