#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 理科キャラ Lv.2 表情差分 一括生成ツール（Leonardo.ai Phoenix 1.0版）
// 16体 × 3表情（大喜び/びっくり/やる気）= 48枚
//
// generate_leonardo.js（Lv.1版）と同じコスト最小設定・逐次生成・既存スキップを踏襲。
//
// 使い方（PowerShell）:
//   node generate_lv2.js --count 3        # 先頭1体分（3枚）だけサンプル生成
//   node generate_lv2.js --ids happakko
//   node generate_lv2.js --all            # 未生成分すべて（最大48枚）
//   node generate_lv2.js --all --force
//
// 出力先: H:\マイドライブ\images\小学コレ！\理科\キャラクター\lv2\
// ファイル名規則: [番号]_[キャラ名]_lv2_[1-3]_512.png
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { buildLv2Prompts, CHARACTERS } = require('./lv2_expressions');
const { NEGATIVE_PROMPT } = require('./characters_data');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3'; // Phoenix 1.0
const OUTPUT_DIR = 'H:\\マイドライブ\\images\\小学コレ！\\理科\\キャラクター\\lv2';
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

function outFileFor(v) {
  return path.join(OUTPUT_DIR, `${v.no}_${v.nameJp}_lv2_${v.variantIndex}_512.png`);
}

async function generateImage(prompt, negativePrompt) {
  const createRes = await fetch(`${API_BASE}/generations`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${LEONARDO_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      negative_prompt: negativePrompt,
      modelId: LEONARDO_MODEL_ID,
      width: 512,
      height: 512,
      num_images: 1,
      alchemy: false,
      photoReal: false,
    }),
  });
  if (!createRes.ok) {
    throw new Error(`Leonardo API error (create): ${createRes.status} ${await createRes.text()}`);
  }
  const created = await createRes.json();
  const genId = created?.sdGenerationJob?.generationId;
  if (!genId) throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);

  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') { images = gen.generated_images; break; }
    if (gen?.status === 'FAILED') throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    attempts++;
  }
  if (!images || !images[0]?.url) throw new Error('画像生成がタイムアウトしました');
  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filePath, buf);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { count: null, ids: null, all: false, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--count') opts.count = parseInt(args[++i], 10);
    else if (args[i] === '--ids') opts.ids = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--force') opts.force = true;
  }
  return opts;
}

async function main() {
  if (!LEONARDO_API_KEY) {
    console.error('❌ LEONARDO_API_KEY が設定されていません。');
    process.exit(1);
  }

  const opts = parseArgs();

  let chars;
  if (opts.ids) chars = CHARACTERS.filter((c) => opts.ids.includes(c.id));
  else chars = CHARACTERS;

  let allVariants = chars.flatMap((c) => buildLv2Prompts(c));

  let target;
  if (opts.all || opts.ids) {
    target = allVariants;
  } else {
    const n = opts.count || 3;
    target = allVariants.slice(0, n);
  }

  console.log(`📋 Lv.2対象: ${target.length} 枚（表情3種 × キャラ数）`);

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, 'manifest_lv2.json');
  const manifest = fs.existsSync(manifestPath)
    ? JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    : {};

  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((v) => {
        const exists = fs.existsSync(outFileFor(v));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) console.log(`⏭️  既存の${skipped}枚をスキップ`);
  console.log(`🎨 ${toGenerate.length} 枚を1枚ずつ逐次生成します（Phoenix1.0 / alchemy=off / 512x512）\n`);

  for (const v of toGenerate) {
    process.stdout.write(`  #${v.no} ${v.nameJp} - ${v.variantLabel}(${v.variantIndex}) ... `);
    try {
      const url = await generateImage(v.prompt, NEGATIVE_PROMPT);
      const outFile = outFileFor(v);
      await downloadTo(url, outFile);
      manifest[`${v.id}_lv2_${v.variantIndex}`] = {
        no: v.no,
        nameJp: v.nameJp,
        variant: v.variantLabel,
        file: path.basename(outFile),
        prompt: v.prompt,
        generatedAt: new Date().toISOString(),
      };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
      console.log('✅');
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了（生成${toGenerate.length}枚 / スキップ${skipped}枚）。出力先: ${OUTPUT_DIR}`);
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
