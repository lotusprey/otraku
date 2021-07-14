import 'package:flutter/material.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';

class SplashView extends StatelessWidget {
  const SplashView();

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: const SafeArea(child: Center(child: Loader())));
}
