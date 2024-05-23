import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/tag/tag_models.dart';
import 'package:otraku/feature/viewer/api.dart';

final tagsProvider = FutureProvider(
  (ref) async => TagGroup(await Api.get(GqlQuery.genresAndTags)),
);
