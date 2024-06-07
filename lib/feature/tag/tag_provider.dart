import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/tag/tag_models.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';

final tagsProvider = FutureProvider(
  (ref) async => TagGroup(
    await ref.read(repositoryProvider).request(GqlQuery.genresAndTags),
  ),
);
