import 'package:otraku/constants/explorable.dart';

class ConnectionModel {
  final int id;
  final Explorable type;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final List<ConnectionModel> other;

  ConnectionModel({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.other = const [],
  });
}
