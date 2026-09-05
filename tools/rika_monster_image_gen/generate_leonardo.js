#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑬まちがい図鑑モンスター画像 一括生成ツール（Leonardo.ai版）
// card_crown/tools/seed_card_image_gen/generate_leonardo.js の構成を継承。
// 固定16種（学年3-6 × baby/juvenile/adult/sage）を生成し、
// assets/images/monsters/ に直接保存する（Flutterのpubspec.yamlで登録済み）。
//
// コスト最小化のため:
//   - alchemy: false, photoReal: false
//   - num_images: 1
//   - 512x512
//   - 既存ファイルは自動スキップ（--allを何度実行しても未生成分だけ課金される）
//
// 使い方:
//   （PowerShellでは事前に $env:LEONARDO_API_KEY="xxxx" を実行しておく）
//   node generate_leonardo.js --count 2               # 先頭2枚だけ（サンプル確認用）
//   node generate_leonardo.js --ids grade3_baby,grade3_sage
//   node generate_leonardo.js --all                   # 残り全16枚をまとめて生成（推奨）
//   node generate_leonardo.js --all --force            # 既存分も含めて全部作り直す
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { getAllMonsterDefs, buildPrompt } = require('./prompt_builder');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
// デフォルト: Leonardo Phoenix 1.0（要検証・エラー時は環境変数で上書き）
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3';
const OUTPUT_DIR = path.join(__dirname, '..', '..', 'assets', 'images', 'monsters');
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Leonardo.ai 呼び出し（コスト最小設定）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
  if (!genId) {
    throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);
  }

  // ポーリング（最大60秒）
  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) {
      throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    }
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') {
      images = gen.generated_images;
      break;
    }
    if (gen?.status === 'FAILED') {
      throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    }
    attempts++;
  }

  if (!images || !images[0]?.url) {
    throw new Error('画像生成がタイムアウトしました');
  }

  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filePath, buf);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLI
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
    console.error('   例: $env:LEONARDO_API_KEY="xxxx"; node generate_leonardo.js --count 2');
    process.exit(1);
  }

  const opts = parseArgs();
  const allDefs = getAllMonsterDefs();
  console.log(`📋 モンスター定義 ${allDefs.length} 種（学年3-6 × baby/juvenile/adult/sage）`);

  let target;
  if (opts.ids) {
    target = allDefs.filter((d) => opts.ids.includes(d.id));
  } else if (opts.all) {
    target = allDefs;
  } else {
    const n = opts.count || 2;
    target = allDefs.slice(0, n);
  }

  if (target.length === 0) {
    console.error('❌ 対象モンスターが見つかりません');
    process.exit(1);
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, '..', '..', '..', 'tools', 'rika_monster_image_gen', 'manifest.json');
  const manifest = fs.existsSync(manifestPath)
    ? JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    : {};

  // API課金の節約: 既に画像ファイルが存在するものはデフォルトでスキップする
  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((def) => {
        const exists = fs.existsSync(path.join(OUTPUT_DIR, `${def.id}.png`));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}枚をスキップ（再生成するには --force を付けてください）`);
  }
  console.log(`🎨 ${toGenerate.length} 枚を生成します（Leonardo.ai / modelId=${LEONARDO_MODEL_ID} / alchemy=off / 512x512）\n`);

  for (const def of toGenerate) {
    const { prompt, negativePrompt } = buildPrompt(def);
    process.stdout.write(`  ${def.id} (grade${def.grade} / ${def.stage}) ... `);
    try {
      const imageUrl = await generateImage(prompt, negativePrompt);
      const outFile = path.join(OUTPUT_DIR, `${def.id}.png`);
      await downloadTo(imageUrl, outFile);
      manifest[def.id] = {
        grade: def.grade,
        stage: def.stage,
        file: `${def.id}.png`,
        prompt,
        provider: 'leonardo',
        modelId: LEONARDO_MODEL_ID,
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
