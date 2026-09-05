#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑬まちがい図鑑モンスター画像 一括生成ツール（Replicate版）
// 固定16種（学年3-6 × baby/juvenile/adult/sage）を生成し、
// assets/images/monsters/ に直接保存する（Flutterのpubspec.yamlで登録済み）。
//
// 使い方:
//   $env:REPLICATE_API_TOKEN="r8_xxxx"; node generate.js --count 2
//   $env:REPLICATE_API_TOKEN="r8_xxxx"; node generate.js --ids grade3_baby,grade3_sage
//   $env:REPLICATE_API_TOKEN="r8_xxxx"; node generate.js --all
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { getAllMonsterDefs, buildPrompt } = require('./prompt_builder');

const REPLICATE_API_TOKEN = process.env.REPLICATE_API_TOKEN;
const FLUX_VERSION = '5f24084160c9089501c1b3545d9be3c27883ae2239b6f412990e82d4a6210f8f';
const OUTPUT_DIR = path.join(__dirname, '..', '..', 'assets', 'images', 'monsters');

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Replicate 呼び出し（標準品質: Flux Schnell, 4 steps, 512x512）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
async function generateImage(prompt, negativePrompt) {
  const createRes = await fetch('https://api.replicate.com/v1/predictions', {
    method: 'POST',
    headers: {
      Authorization: `Token ${REPLICATE_API_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      version: FLUX_VERSION,
      input: {
        prompt,
        negative_prompt: negativePrompt,
        width: 512,
        height: 512,
        num_outputs: 1,
        num_inference_steps: 4,
      },
    }),
  });

  if (!createRes.ok) {
    throw new Error(`Replicate API error: ${createRes.status} ${await createRes.text()}`);
  }

  let result = await createRes.json();
  let attempts = 0;
  while (result.status !== 'succeeded' && result.status !== 'failed' && attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`https://api.replicate.com/v1/predictions/${result.id}`, {
      headers: { Authorization: `Token ${REPLICATE_API_TOKEN}` },
    });
    result = await poll.json();
    attempts++;
  }

  if (result.status !== 'succeeded' || !result.output || !result.output[0]) {
    throw new Error(`generation failed: ${JSON.stringify(result)}`);
  }

  return result.output[0];
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
  if (!REPLICATE_API_TOKEN) {
    console.error('❌ REPLICATE_API_TOKEN が設定されていません。');
    console.error('   例: $env:REPLICATE_API_TOKEN="r8_xxxx"; node generate.js --count 2');
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
  const manifestPath = path.join(__dirname, 'manifest.json');
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
  console.log(`🎨 ${toGenerate.length} 枚を生成します（標準品質: Flux Schnell, 512x512, 4 steps）\n`);

  for (const def of toGenerate) {
    const { prompt, negativePrompt } = buildPrompt(def);
    process.stdout.write(`  ${def.id} (grade${def.grade} / ${def.stage}) ... `);
    try {
      const replicateUrl = await generateImage(prompt, negativePrompt);
      const outFile = path.join(OUTPUT_DIR, `${def.id}.png`);
      await downloadTo(replicateUrl, outFile);
      manifest[def.id] = {
        grade: def.grade,
        stage: def.stage,
        file: `${def.id}.png`,
        prompt,
        provider: 'replicate-flux-schnell',
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
