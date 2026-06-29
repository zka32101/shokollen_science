import 'package:cloud_firestore/cloud_firestore.dart';

/// 生き物図鑑モデル
class CreatureModel {
  final String id;
  final String name;
  final String scientificName;
  final String category; // insect, bird, mammal, amphibian, reptile, fish, plant, other
  final String description;
  final String imageUrl;
  final List<String> relatedStageIds; // 関連する学習単元
  final int difficultyLevel; // 1-5（高いほど珍しい）
  final String habitat;
  final String characteristics;
  final String diet; // 食性
  final String? funFact; // 豆知識

  CreatureModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.relatedStageIds,
    required this.difficultyLevel,
    required this.habitat,
    required this.characteristics,
    required this.diet,
    this.funFact,
  });

  /// Firestore から復元
  factory CreatureModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CreatureModel(
      id: doc.id,
      name: data['name'] ?? '',
      scientificName: data['scientificName'] ?? '',
      category: data['category'] ?? 'other',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      relatedStageIds: List<String>.from(data['relatedStageIds'] ?? []),
      difficultyLevel: data['difficultyLevel'] ?? 1,
      habitat: data['habitat'] ?? '',
      characteristics: data['characteristics'] ?? '',
      diet: data['diet'] ?? '',
      funFact: data['funFact'],
    );
  }

  /// Firestore へ保存
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'scientificName': scientificName,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'relatedStageIds': relatedStageIds,
      'difficultyLevel': difficultyLevel,
      'habitat': habitat,
      'characteristics': characteristics,
      'diet': diet,
      'funFact': funFact,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
