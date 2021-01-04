import 'package:flutter/foundation.dart';

enum ListStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
}

//An enum clarification function
String listStatusSpecification(ListStatus status, bool isAnime) {
  if (status == ListStatus.CURRENT) {
    if (isAnime) {
      return 'Watching';
    }
    return 'Reading';
  }

  if (status == ListStatus.REPEATING) {
    if (isAnime) {
      return 'Rewatching';
    }
    return 'Rereading';
  }

  String str = describeEnum(status);
  return str[0] + str.substring(1).toLowerCase();
}
