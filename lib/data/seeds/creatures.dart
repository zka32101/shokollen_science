/// 生き物図鑑データ（学習指導要領に準拠）

final creaturesData = [
  // ========== 昆虫 ==========
  {
    'id': 'creature_001',
    'name': 'モンシロチョウ',
    'scientificName': 'Pieris rapae',
    'category': 'insect',
    'description': '白い羽を持つ、身近なチョウです。春から秋にかけて見られます。',
    'relatedStageIds': ['stage_3_003'], // チョウの育ち
    'difficultyLevel': 1,
    'habitat': '野原、庭、菜園',
    'characteristics': '白い羽、黒い斑点',
    'diet': '蜜、新芽',
    'funFact': 'サナギの色が周囲に合わせて変わることがあります。',
  },
  {
    'id': 'creature_002',
    'name': 'オニヤンマ',
    'scientificName': 'Anax parthenope',
    'category': 'insect',
    'description': '大きいトンボです。川や池の周りで見られます。素早く飛びます。',
    'relatedStageIds': ['stage_3_001', 'stage_4_001'], // 昆虫と植物、季節と生き物
    'difficultyLevel': 2,
    'habitat': '河川、池、湿地',
    'characteristics': '大きな体、素早い飛行',
    'diet': '小さな昆虫',
    'funFact': 'トンボは360度視野があり、獲物を捕らえるのが得意です。',
  },
  {
    'id': 'creature_003',
    'name': 'アリ',
    'scientificName': 'Formica japonica',
    'category': 'insect',
    'description': '集団で生活する昆虫です。多くの場所で見られます。',
    'relatedStageIds': ['stage_3_001'], // 昆虫と植物
    'difficultyLevel': 1,
    'habitat': '地中、樹木の根元',
    'characteristics': '小さな体、6本の脚、集団生活',
    'diet': '甘い物、小さな昆虫',
    'funFact': 'アリは仲間同士でにおい（フェロモン）を使ってコミュニケーションを取ります。',
  },
  {
    'id': 'creature_004',
    'name': 'クワガタムシ',
    'scientificName': 'Dorcus hopei binodulosus',
    'category': 'insect',
    'description': '大きなあごを持つ甲虫です。夜行性で、クヌギなどの樹液が出ている樹に集まります。',
    'relatedStageIds': ['stage_4_002'], // 季節と生き物（夏）
    'difficultyLevel': 3,
    'habitat': '雑木林、樹液が出ている樹',
    'characteristics': '大きなあご、黒色',
    'diet': '樹液',
    'funFact': 'オスはあごで敵と戦います。あごが大きいほど強いということを示しています。',
  },

  // ========== 鳥 ==========
  {
    'id': 'creature_005',
    'name': 'スズメ',
    'scientificName': 'Passer montanus',
    'category': 'bird',
    'description': '茶色い小さな鳥です。人間の生活の近くでよく見かけます。',
    'relatedStageIds': ['stage_3_001', 'stage_4_001'], // 昆虫と植物、季節と生き物
    'difficultyLevel': 1,
    'habitat': '人家周辺、庭',
    'characteristics': '茶色の羽、小さな体',
    'diet': '種子、昆虫',
    'funFact': 'スズメは群れで行動することが多く、群れが大きいほど安全だと考えられています。',
  },
  {
    'id': 'creature_006',
    'name': 'カラス',
    'scientificName': 'Corvus corone orientalis',
    'category': 'bird',
    'description': '黒い大きな鳥です。とても頭が良く、様々な道具を使うことで知られています。',
    'relatedStageIds': ['stage_4_001'], // 季節と生き物
    'difficultyLevel': 2,
    'habitat': '街中、公園、野原',
    'characteristics': '黒色、大きな体、知性的',
    'diet': 'なんでも（雑食）',
    'funFact': 'カラスは人間の顔を識別し、記憶することができます。',
  },
  {
    'id': 'creature_007',
    'name': 'ツバメ',
    'scientificName': 'Hirundo rustica gutturalis',
    'category': 'bird',
    'description': '春から夏に見られる渡り鳥です。空を素早く飛んで、昆虫を食べます。',
    'relatedStageIds': ['stage_4_001', 'stage_4_003'], // 季節と生き物
    'difficultyLevel': 2,
    'habitat': '空中、人家の軒下',
    'characteristics': '黒い背、白い腹、素早い飛行',
    'diet': '昆虫',
    'funFact': 'ツバメは人間の家に巣を作ることが多く、古い日本ではおめでたい鳥とされていました。',
  },

  // ========== 哺乳類 ==========
  {
    'id': 'creature_008',
    'name': 'ウサギ',
    'scientificName': 'Lepus timidus',
    'category': 'mammal',
    'description': '長い耳と短い尾を持つ哺乳類です。草食動物です。',
    'relatedStageIds': ['stage_5_002'], // 動物の誕生
    'difficultyLevel': 1,
    'habitat': '草地、野原、林',
    'characteristics': '長い耳、短い尾、速い走り',
    'diet': '草、野菜',
    'funFact': 'ウサギは夜行性で、視覚は薄暗い環境に適しています。',
  },
  {
    'id': 'creature_009',
    'name': 'リス',
    'scientificName': 'Sciurus lis',
    'category': 'mammal',
    'description': '木の上で生活する小型の哺乳類です。ふさふさの尾を持っています。',
    'relatedStageIds': ['stage_4_001', 'stage_5_002'], // 季節と生き物、動物の誕生
    'difficultyLevel': 2,
    'habitat': '樹林、公園',
    'characteristics': 'ふさふさの尾、小型の体',
    'diet': '木の実、種子、昆虫',
    'funFact': 'リスは冬に備えて木の実を埋めて隠しますが、時々埋めた場所を忘れ、それが新しい樹の成長につながります。',
  },
  {
    'id': 'creature_010',
    'name': 'ネズミ',
    'scientificName': 'Mus musculus',
    'category': 'mammal',
    'description': '小型の齧歯類です。夜行性で、様々な環境に適応しています。',
    'relatedStageIds': ['stage_5_002'], // 動物の誕生
    'difficultyLevel': 2,
    'habitat': '人家、穀倉、野地',
    'characteristics': '小型、長い尾、鋭い臭覚',
    'diet': '穀物、種子、昆虫',
    'funFact': 'ネズミは年に6〜8回出産できる繁殖力の強い動物です。',
  },

  // ========== 植物 ==========
  {
    'id': 'creature_011',
    'name': 'トマト',
    'scientificName': 'Solanum lycopersicum',
    'category': 'plant',
    'description': '赤い果実がなる野菜です。学校の家庭菜園でよく育てられています。',
    'relatedStageIds': ['stage_3_002', 'stage_5_001'], // 花を育てよう、植物の発芽・成長
    'difficultyLevel': 1,
    'habitat': '畑、庭、プランター',
    'characteristics': '赤い実、つる性、複葉',
    'diet': '（植物なので食べません）',
    'funFact': 'トマトはもともと南米原産の植物で、日本に持ち込まれたのは江戸時代です。',
  },
  {
    'id': 'creature_012',
    'name': 'ヒマワリ',
    'scientificName': 'Helianthus annuus',
    'category': 'plant',
    'description': '大きな黄色い花が咲く植物です。太陽の方向に花を向けます（向日性）。',
    'relatedStageIds': ['stage_3_002', 'stage_5_001'], // 花を育てよう、植物の発芽・成長
    'difficultyLevel': 1,
    'habitat': '畑、庭、空き地',
    'characteristics': '大きな黄色い花、高い背丈',
    'diet': '（植物なので食べません）',
    'funFact': 'ヒマワリは光合成を効率よく行うために、朝は東を向き、夜は西を向きます。',
  },
  {
    'id': 'creature_013',
    'name': 'アサガオ',
    'scientificName': 'Ipomoea nil',
    'category': 'plant',
    'description': '朝に花が咲く植物です。つるが伸びてよく成長するため、観察に適しています。',
    'relatedStageIds': ['stage_3_002', 'stage_5_001'], // 花を育てよう、植物の発芽・成長
    'difficultyLevel': 1,
    'habitat': '庭、プランター',
    'characteristics': 'つる性、朝咲く花',
    'diet': '（植物なので食べません）',
    'funFact': 'アサガオはつると葉のつき方が特徴的で、数学の学習に使われることもあります。',
  },
  {
    'id': 'creature_014',
    'name': 'トウモロコシ',
    'scientificName': 'Zea mays',
    'category': 'plant',
    'description': '背が高い穀物です。黄色い粒がついた穂が特徴です。',
    'relatedStageIds': ['stage_5_001'], // 植物の発芽・成長
    'difficultyLevel': 2,
    'habitat': '畑',
    'characteristics': '背が高い、黄色い穂',
    'diet': '（植物なので食べません）',
    'funFact': 'トウモロコシの粒の一つ一つは、受粉によってできた種子です。',
  },

  // ========== その他の生き物 ==========
  {
    'id': 'creature_015',
    'name': 'エビ',
    'scientificName': 'Penaeus',
    'category': 'other',
    'description': '水中に住む甲殻類です。長い触覚と湾曲した体が特徴です。',
    'relatedStageIds': ['stage_3_001', 'stage_4_001'], // 昆虫と植物、季節と生き物
    'difficultyLevel': 2,
    'habitat': '川、池、海',
    'characteristics': '長い触覚、湾曲した体',
    'diet': '植物、小さな生き物',
    'funFact': 'エビは脱皮して成長します。脱皮の回数で成長段階がわかります。',
  },
  {
    'id': 'creature_016',
    'name': 'カタツムリ',
    'scientificName': 'Achatina fulica',
    'category': 'other',
    'description': '巻き貝です。雨の日に見かけることが多いです。',
    'relatedStageIds': ['stage_3_001', 'stage_4_001'], // 昆虫と植物、季節と生き物
    'difficultyLevel': 1,
    'habitat': '湿った場所、植物',
    'characteristics': '螺旋状の殻、触覚',
    'diet': '植物、落ち葉',
    'funFact': 'カタツムリの殻の渦巻きは、すべて右巻きです（ほぼすべての種で）。',
  },
];
