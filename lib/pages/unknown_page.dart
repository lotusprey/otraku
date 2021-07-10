import 'package:flutter/material.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: Text('404', style: Theme.of(context).textTheme.headline2),
        ),
      );
}
