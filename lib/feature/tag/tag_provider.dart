import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/tag/tag_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';

final tagsProvider = FutureProvider(
  (ref) async => TagCollection(
    await ref.read(repositoryProvider).request(GqlQuery.genresAndTags),
  ),
);
