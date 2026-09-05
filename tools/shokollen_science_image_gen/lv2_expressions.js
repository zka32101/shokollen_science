// Lv.2 表情差分プロンプト定義（3種 × 16体 = 48枚）
// ベースキャラ（characters_data.js）の色・形状・シルエットはそのまま維持し、
// 顔の表情（目・口・眉）とポーズのニュアンスだけを差し替える。
// 国語コレの character_levels/*_lv2_1〜3.jpg と同じ「表情バリエーション」設計。

const { CHARACTERS } = require('./characters_data');

// 全キャラ共通の3表情アーキタイプ（喜び / 驚き / 決意）
const EXPRESSION_VARIANTS = [
  {
    key: 'joy',
    label: '大喜び',
    clause:
      'Expression variant: bursting with joy, eyes scrunched into happy crescents, wide open laughing mouth showing teeth, extra rosy glowing cheeks, both arms thrown up even higher in celebration, small sparkle and confetti-like motes bursting around it.',
  },
  {
    key: 'surprise',
    label: 'びっくり',
    clause:
      'Expression variant: surprised and amazed, eyes opened extra wide and round, small open "o" shaped mouth, eyebrows raised high, slight jump-back pose with hands near cheeks, small exclamation-mark and sparkle motifs floating around it.',
  },
  {
    key: 'determined',
    label: 'やる気',
    clause:
      'Expression variant: confident and determined, eyes narrowed slightly with a bright sparkle, small confident smirk, one fist raised or hand on hip in a determined pose, small motivational spark and glow lines around it.',
  },
];

function buildLv2Prompts(char) {
  return EXPRESSION_VARIANTS.map((variant, idx) => ({
    no: char.no,
    id: char.id,
    nameJp: char.nameJp,
    field: char.field,
    variantIndex: idx + 1,
    variantKey: variant.key,
    variantLabel: variant.label,
    prompt: `${char.prompt} ${variant.clause}`,
  }));
}

module.exports = { EXPRESSION_VARIANTS, buildLv2Prompts, CHARACTERS };
