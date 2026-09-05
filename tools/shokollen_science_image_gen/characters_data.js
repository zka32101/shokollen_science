// 理科キャラ16体 定義データ
// 原本: H:\マイドライブ\images\小学コレ！\理科\理科キャラ_キャラクター作成ガイド.docx
// プロンプトは同ガイドの仕様（形状・色・顔パーツ・ポーズ・エフェクト）を
// Leonardo.ai (Phoenix 1.0) 向けに英語の1段落プロンプトへ翻案したもの。

const NEGATIVE_PROMPT =
  'text, watermark, logo, signature, low quality, blurry, extra limbs, ' +
  'realistic human, scary, dark, adult, photorealistic, cropped';

const STYLE_SUFFIX =
  'Kawaii Japanese children educational mascot character sticker style, ' +
  'simple flat vector illustration, thick clean outline, big sparkling round eyes, ' +
  'cheerful friendly expression, centered, white background, square format, no text, no watermark.';

const CHARACTERS = [
  {
    no: 1,
    id: 'happakko',
    nameJp: 'ハッパっこ',
    field: '生物',
    color: '#4CAF50',
    prompt:
      'Cute mascot character shaped like a round smiling leaf, vivid green (#4CAF50) body with darker green outline and visible leaf-vein lines on its body, big round sparkling green eyes, rosy cheeks, both arms stretched up toward sunlight in a joyful photosynthesis pose, surrounded by small sun rays and tiny oxygen bubbles, glowing green sparkle effects. ' +
      STYLE_SUFFIX,
  },
  {
    no: 2,
    id: 'mushimushi',
    nameJp: 'ムシムシ',
    field: '生物',
    color: '#8BC34A',
    prompt:
      'Cute mascot character based on a butterfly/insect, yellow-green (#8BC34A) body with darker green outline, two cute simplified wings and six tiny simplified legs, big round compound-eye-style sparkling eyes, rosy cheeks, pose mid-hop with wings spread as if fluttering joyfully, small flower petals and sparkle motes around it, tiny egg-larva-adult lifecycle icons floating nearby. ' +
      STYLE_SUFFIX,
  },
  {
    no: 3,
    id: 'mizukko',
    nameJp: 'ミズっこ魚',
    field: '生物',
    color: '#2196F3',
    prompt:
      'Cute round mascot character shaped like a friendly fish, blue (#2196F3) body with deep blue outline, cute simplified fins and tail, big round sparkling blue eyes like water shimmer, gentle smile, rosy cheeks, pose swimming or jumping out of water, surrounded by water bubbles, ripple motifs and blue sparkle, tiny water plants nearby. ' +
      STYLE_SUFFIX,
  },
  {
    no: 4,
    id: 'hitohito',
    nameJp: 'ヒトヒト',
    field: '生物',
    color: '#F48FB1',
    prompt:
      'Cute mascot character shaped like a friendly human body silhouette, pink (#F48FB1) body with deep pink outline, faint translucent view showing tiny cute heart, lungs and stomach icons inside the body, big round sparkling pink eyes, healthy warm smile, rosy cheeks, pose with arms spread wide showing itself proudly or hand on chest feeling heartbeat, small heartbeat line and warm glow around it. ' +
      STYLE_SUFFIX,
  },
  {
    no: 5,
    id: 'mizubunshi',
    nameJp: 'ミズ水分子',
    field: '物質',
    color: '#00BCD4',
    prompt:
      'Cute mascot character shaped like a soft rounded water droplet, cyan (#00BCD4) body with deep cyan outline, translucent flowing gooey silhouette, big round sparkling cyan eyes with water shimmer, gentle flowing smile, rosy cheeks, pose bouncing playfully like splashing water, small H2O molecule icon and ripple motifs around it, cyan sparkle light. ' +
      STYLE_SUFFIX,
  },
  {
    no: 6,
    id: 'koori',
    nameJp: 'コオリ',
    field: '物質',
    color: '#90CAF9',
    prompt:
      'Cute mascot character shaped like an angular ice crystal, white and light blue (#E3F2FD / #90CAF9) body with deep blue outline, hexagonal snowflake-like geometric silhouette, big round sparkling light blue eyes glittering like ice, calm cool smile, faint blue blush, pose standing firm and stable or spreading arms like a growing crystal, tiny snowflakes and cold-air sparkle around it, small "0°C" icon nearby. ' +
      STYLE_SUFFIX,
  },
  {
    no: 7,
    id: 'jouki',
    nameJp: 'ジョウキ',
    field: '物質',
    color: '#BBDEFB',
    prompt:
      'Cute mascot character shaped like a fluffy soft cloud of steam, white and pale blue (#FAFAFA / #BBDEFB) body with very soft light outline, formless floating fuzzy silhouette, big round sparkling pale blue eyes, soft airy smile, faint pink blush, pose floating weightlessly upward as if evaporating, tiny water vapor particles and cloud motifs around it, small "100°C" icon nearby, soft white glow. ' +
      STYLE_SUFFIX,
  },
  {
    no: 8,
    id: 'dorodoro',
    nameJp: 'ドロドロ',
    field: '物質',
    color: '#795548',
    prompt:
      'Cute mascot character shaped like a round laboratory beaker filled with colorful bubbling liquid, brown and yellow (#795548 / #FFC107) body with multicolor accents, big round sparkling brown eyes full of curiosity, playful excited smile, yellow blush, pose holding a tiny beaker or with liquid bubbling and splashing joyfully, colorful bubbles, chemical reaction sparkles and light experiment smoke around it. ' +
      STYLE_SUFFIX,
  },
  {
    no: 9,
    id: 'hikari',
    nameJp: 'ヒカリ光',
    field: 'エネルギー',
    color: '#FFD700',
    prompt:
      'Cute mascot character radiating light, golden yellow (#FFD700 / #FF8F00) body with rainbow prism accents, silhouette with light beams radiating outward, big round sparkling golden eyes with maximum sparkle, biggest brightest smile, orange blush, pose with arms spread wide radiating light rays or forming a small rainbow prism, dynamic radiant golden light beams and dispersed 7-color rainbow light around it. ' +
      STYLE_SUFFIX,
  },
  {
    no: 10,
    id: 'onpa',
    nameJp: 'オンパ音波',
    field: 'エネルギー',
    color: '#9C27B0',
    prompt:
      'Cute mascot character shaped like a playful sound wave, purple (#9C27B0) body with deep purple outline, wavy sound-wave-form silhouette, big round sparkling purple eyes, joyful singing smile, pink blush, pose as if singing or dancing to rhythm with arms forming a circular wave motion, musical notes and concentric ripple circles radiating around it, purple wave-light glow. ' +
      STYLE_SUFFIX,
  },
  {
    no: 11,
    id: 'denki',
    nameJp: 'デンキ電気',
    field: 'エネルギー',
    color: '#FFEB3B',
    prompt:
      'Cute mascot character shaped like a lightning bolt, yellow and blue (#FFEB3B / #1976D2) body with bold geometric circuit-like patterns, sharp energetic silhouette, big round sparkling yellow eyes crackling with electricity, powerful energetic grin, yellow blush, pose in a sharp dynamic lightning-strike stance or forming a small circuit shape, sparking lightning bolts and yellow-blue electric light bursts around it, tiny lightbulb icon nearby. ' +
      STYLE_SUFFIX,
  },
  {
    no: 12,
    id: 'jishaku',
    nameJp: 'ジシャク磁石',
    field: 'エネルギー',
    color: '#E74C3C',
    prompt:
      'Cute mascot character shaped like a U-shaped horseshoe magnet, one side red (#E74C3C) and one side blue (#1976D2) each with matching darker outline, one red eye and one blue eye both big and round and sparkling, quirky fun smile, one cheek red one cheek blue, pose with arms open as if attracting something or forming magnetic field lines, red and blue magnetic field line motifs glowing around it, small N and S letters nearby. ' +
      STYLE_SUFFIX,
  },
  {
    no: 13,
    id: 'taiyou',
    nameJp: 'タイヨウ',
    field: '地球・宇宙',
    color: '#FF9800',
    prompt:
      'Cute mascot character shaped like a round radiant sun, orange and gold (#FF9800 / #FFD700) body with deep orange outline, radiating sun rays extending in eight directions, big round sparkling golden eyes with maximum brightness, warmest biggest smile, orange blush, pose with arms spread wide shining light over everything, powerful golden-orange corona glow, tiny stars and planets in the background suggesting deep space. ' +
      STYLE_SUFFIX,
  },
  {
    no: 14,
    id: 'tsukichan',
    nameJp: 'ツキちゃん',
    field: '地球・宇宙',
    color: '#C0C0C0',
    prompt:
      'Cute mascot character shaped like a gentle crescent or full moon, silver and white (#C0C0C0 / #ECEFF1) body with soft grey outline, small cute craters visible on its surface, big round sparkling silver eyes with soft gentle glow, calm mysterious smile, faint light blue blush, pose quietly watching over the night sky or gently curved showing phases, tiny stars and soft silver moonlight sparkle around it, soft shadow gradient suggesting moon phases. ' +
      STYLE_SUFFIX,
  },
  {
    no: 15,
    id: 'tenki',
    nameJp: 'テンキ天気',
    field: '地球・宇宙',
    color: '#87CEEB',
    prompt:
      'Cute mascot character shaped like a fluffy cloud representing changing weather, sky blue and white (#87CEEB / #FFFFFF) body with soft light blue outline, big round sparkling sky blue eyes, bright ever-changing smile, faint pink blush, pose holding a tiny sun in one hand and a tiny raindrop in the other, small floating sun, raindrops, snowflake and lightning bolt weather icons around it, light blue glow and a small rainbow accent. ' +
      STYLE_SUFFIX,
  },
  {
    no: 16,
    id: 'kaseki',
    nameJp: 'カセキ化石',
    field: '地球・宇宙',
    color: '#8D6E63',
    prompt:
      'Cute mascot character shaped like an ancient fossil with layered rock strata patterns on its body, brown and gold (#8D6E63 / #FFD54F) body with deep brown outline, small dinosaur bone fossil embedded as part of its design, big round sparkling golden eyes full of ancient wisdom, mysterious knowing smile, soft orange blush, pose proudly holding a small excavation brush or a tiny fossil, layered strata stripes, golden excavation sparkle and drifting sand-of-time effect around it. ' +
      STYLE_SUFFIX,
  },
];

module.exports = { CHARACTERS, NEGATIVE_PROMPT };
