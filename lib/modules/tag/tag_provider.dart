import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/modules/tag/tag_models.dart';
import 'package:otraku/modules/viewer/api.dart';

final tagsProvider = FutureProvider(
  (ref) async => TagGroup(await Api.get(GqlQuery.genresAndTags)),
);
