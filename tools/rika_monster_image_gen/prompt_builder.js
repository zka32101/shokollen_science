// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑬まちがい図鑑モンスター画像 プロンプト組み立てモジュール
// card_crown/tools/seed_card_image_gen/prompt_builder.js の設計を継承。
// 対象は「学年(3-6) × 進化段階(baby/juvenile/adult/sage)」の固定16種のみのため、
// card_crownと違いDartファイルからのパース処理は無く、定義を直接持つ。
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 学年ごとのテーマ（rika_characters.dart のTier1-4テーマに準拠した、
// 特定キャラクターに紐付かない汎用的な「小さな精霊生物」のモチーフ）
const GRADE_THEME = {
  3: {
    creature: 'small friendly bug-and-sprout spirit creature, tiny insectoid body with a budding leaf on its back, soft rounded antennae, faint spark of static electricity around its feet',
    palette: 'warm spring green and soft yellow color palette, gentle sunny tones',
    bg: 'solid soft green gradient background, simple and clean',
  },
  4: {
    creature: 'small cloud-and-droplet spirit creature, fluffy cloud-like body with a single water droplet marking on its chest, tiny crescent moon charm floating nearby',
    palette: 'sky blue and soft silver color palette, airy cool tones',
    bg: 'solid soft sky-blue gradient background, simple and clean',
  },
  5: {
    creature: 'small crystal-and-ember spirit creature, faceted gem-like body with a warm glowing core, tiny wisps of steam curling from its shoulders',
    palette: 'amethyst purple and warm amber color palette, mystical tones',
    bg: 'solid soft violet gradient background, simple and clean',
  },
  6: {
    creature: 'small mountain-and-star spirit creature, smooth stone-like body dotted with tiny glowing star freckles, faint aura like a distant galaxy',
    palette: 'deep indigo and warm gold color palette, cosmic tones',
    bg: 'solid soft indigo gradient background, simple and clean',
  },
};

// 進化段階ごとの表情・ポーズ（EvolutionState: baby/juvenile/adult/sage に対応）
const EVOLUTION_STAGE = {
  baby: {
    label: 'たまご',
    descriptor: 'newly hatched baby form, small and huddled, teary crying eyes, tiny trembling pose, egg-shell fragments nearby',
  },
  juvenile: {
    label: '幼生',
    descriptor: 'young juvenile form, slightly bigger, worried confused expression, unsure wobbly stance, one eyebrow raised',
  },
  adult: {
    label: '成体',
    descriptor: 'grown adult form, calm neutral confident expression, balanced standing pose, steady and composed',
  },
  sage: {
    label: '博士',
    descriptor: 'wise sage form, joyful proud expression with sparkling eyes, wearing a tiny graduation cap, radiant gentle glow, confident welcoming pose',
  },
};

const GRADES = [3, 4, 5, 6];
const STAGES = ['baby', 'juvenile', 'adult', 'sage'];

/// 16件の固定モンスター定義を生成
function getAllMonsterDefs() {
  const defs = [];
  for (const grade of GRADES) {
    for (const stage of STAGES) {
      defs.push({ id: `grade${grade}_${stage}`, grade, stage });
    }
  }
  return defs;
}

function buildPrompt(def) {
  const theme = GRADE_THEME[def.grade];
  const stage = EVOLUTION_STAGE[def.stage];

  const prompt = [
    theme.creature,
    stage.descriptor,
    theme.palette,
    theme.bg,
    'cute mascot character design, kawaii chibi proportions, kid-friendly and non-scary, centered character illustration',
    'digital illustration, clean vector-like shading, vibrant colors, professional mascot artwork',
    'no text no watermark no border',
  ]
    .filter(Boolean)
    .join(', ');

  const negativePrompt = [
    'text, words, letters, numbers, watermark, signature',
    'scary, frightening, grotesque, realistic human, photorealistic',
    'card frame, border, UI, HUD',
    'ugly, blurry, low quality, deformed, mutated, malformed',
    'extra limbs, bad anatomy, extra fingers',
    'duplicate, oversaturated, washed out',
  ].join(', ');

  return { prompt, negativePrompt };
}

module.exports = { getAllMonsterDefs, buildPrompt, GRADE_THEME, EVOLUTION_STAGE };
