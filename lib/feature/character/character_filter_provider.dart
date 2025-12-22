import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/character/character_filter_model.dart';

final characterFilterProvider = NotifierProvider.autoDispose
    .family<CharacterFilterNotifier, CharacterFilter, int>(CharacterFilterNotifier.new);

class CharacterFilterNotifier extends Notifier<CharacterFilter> {
  CharacterFilterNotifier(this.arg);

  final int arg;

  @override
  CharacterFilter build() => const CharacterFilter();

  @override
  set state(CharacterFilter newState) => super.state = newState;
}
