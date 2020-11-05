/*
Replaces _ with [blank_space] and makes each word
start with an upper case letter and continue with
lower case ones.
*/
import 'package:flutter/foundation.dart';
import 'package:otraku/enums/list_sort_enum.dart';

String clarifyEnum(String str) {
  return str.splitMapJoin(
    '_',
    onMatch: (_) => ' ',
    onNonMatch: (s) => s[0].toUpperCase() + s.substring(1).toLowerCase(),
  );
}

/*
Transforms a string into enum. The string must be
as if it was acquired through "describeEnum()" (from the
foundation package) and the values must be the enum
values ex. "MyEnum.values"
*/
T stringToEnum<T>(String str, List<T> values) {
  return values.firstWhere((v) => describeEnum(v) == str, orElse: () => null);
}

/*
The default list sort is limited to certain values
and the value returned from the API is not a standard
enum value. Thus, it requires the use of switch.
*/
ListSort defaultSortFromString(String defSort) {
  switch (defSort) {
    case 'title':
      return ListSort.TITLE;
    case 'score':
      return ListSort.SCORE_DESC;
    case 'updatedAt':
      return ListSort.UPDATED_AT_DESC;
    case 'createdAt':
      return ListSort.CREATED_AT_DESC;
    default:
      return ListSort.TITLE;
  }
}
