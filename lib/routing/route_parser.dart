import 'package:flutter/material.dart';
import 'package:otraku/routing/navigation.dart';

class RouteParser extends RouteInformationParser<String> {
  const RouteParser();

  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    if (routeInformation.location == null) return Navigation.authRoute;

    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) return Navigation.authRoute;

    return uri.pathSegments[0];
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(location: configuration);
}
