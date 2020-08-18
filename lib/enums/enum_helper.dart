String clarifyEnum(String str) {
  return str.splitMapJoin(
    '_',
    onMatch: (_) => ' ',
    onNonMatch: (s) => s[0] + s.substring(1).toLowerCase(),
  );
}

Object stringToEnum(String str, Map<String, Object> enumMap) {
  for (final key in enumMap.keys) {
    if (str == key) {
      return enumMap[key];
    }
  }

  return null;
}
