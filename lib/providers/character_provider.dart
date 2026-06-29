import 'package:shared_core/shared_core.dart';
import '../data/rika_characters.dart';

/// 理科コレ固有のキャラクターノティファイア。
/// main.dart で characterStateProvider をこれで上書きする:
/// ```dart
/// characterStateProvider.overrideWith(CharacterNotifier.new)
/// ```
class CharacterNotifier extends BaseCharacterNotifier {
  @override
  List<BaseCharacter> get characterList => kRikaCharacters;

  @override
  String get storageKey => 'rika_char_states';
}
