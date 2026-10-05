import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../character_level_assets.dart';

final characterLevelAssetsProvider =
    FutureProvider<CharacterLevelAssets>((ref) => CharacterLevelAssets.load());
