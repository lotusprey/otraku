import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/overlays/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlContent extends StatelessWidget {
  final String text;
  HtmlContent(this.text);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      text,
      textStyle: Theme.of(context).textTheme.bodyText1,
      hyperlinkColor: Theme.of(context).accentColor,
      onTapUrl: (url) async {
        if (await canLaunch(url))
          await launch(url);
        else
          Toast.show(context, 'Could not open link');
      },
      customStylesBuilder: (element) {
        if (element.localName == 'h1' ||
            element.localName == 'h2' ||
            element.localName == 'h3') return {'font-size': '20px'};
        return null;
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'hr')
          return Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: Config.BORDER_RADIUS,
            ),
          );
        return null;
      },
    );
  }
}
