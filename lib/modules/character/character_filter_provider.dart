import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/character/character_models.dart';

final characterFilterProvider = NotifierProvider.autoDispose
    .family<CharacterFilterNotifier, CharacterFilter, int>(
  CharacterFilterNotifier.new,
);

class CharacterFilterNotifier
    extends AutoDisposeFamilyNotifier<CharacterFilter, int> {
  @override
  CharacterFilter build(arg) => CharacterFilter();

  @override
  set state(CharacterFilter newState) => super.state = newState;
}
