/*
Replaces _ with [blank_space] and makes each word
start with an upper case letter and continue with
lower case ones.
*/
String clarifyEnum(String str) {
  return str.splitMapJoin(
    '_',
    onMatch: (_) => ' ',
    onNonMatch: (s) => s[0] + s.substring(1).toLowerCase(),
  );
}

/*
Recieves a string that represents the text version of
an enum value (what describeEnum in "foundation"
would normally return) and a map of enum values. The map
can be aquired this way:
Map.fromIterable(
  [ENUM].values,
  key: (element) => describeEnum(element),
  value: (element) => element,
),
*/
Object stringToEnum(String str, Map<String, Object> enumMap) {
  for (final key in enumMap.keys) {
    if (str == key) {
      return enumMap[key];
    }
  }

  return null;
}
