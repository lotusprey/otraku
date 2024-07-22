extension FutureExtension on Future {
  Future<Object?> getErrorOrNull() =>
      then<Object?>((_) => null, onError: (e) => e);
}
