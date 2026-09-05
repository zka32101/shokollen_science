#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 理科キャラ16体 一括生成ツール（Leonardo.ai Phoenix 1.0版）
// 原本テンプレート: leonardo-ai-image-gen スキル / templates/generate_leonardo.template.js
//
// コスト最小設定:
//   - alchemy: false, photoReal: false（高品質モードは数倍課金なのでOFF固定）
//   - num_images: 1（1回のリクエストで1枚のみ）
//   - 512x512
//   - 1体ずつ逐次生成（for await ループ。並列実行しない）
//   - 既存ファイルは自動スキップ（--force で上書き再生成）
//
// 使い方（PowerShell）:
//   node generate_leonardo.js --count 2        # 先頭2体だけサンプル生成（推奨: まずこれで確認）
//   node generate_leonardo.js --ids happakko,mushimushi
//   node generate_leonardo.js --all            # 未生成分すべて（16体）
//   node generate_leonardo.js --all --force    # 既存分も含め全部作り直す
//
// 出力先: H:\マイドライブ\images\小学コレ！\理科\キャラクター\
// ファイル名規則: [番号]_[キャラ名]_512.png （理科キャラ作成ガイドの規則に準拠）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');
const { CHARACTERS, NEGATIVE_PROMPT } = require('./characters_data');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3'; // Phoenix 1.0
const OUTPUT_DIR = 'H:\\マイドライブ\\images\\小学コレ！\\理科\\キャラクター';
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

function outFileFor(char) {
  return path.join(OUTPUT_DIR, `${char.no}_${char.nameJp}_512.png`);
}

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

  return { url: images[0].url, generatedImageId: images[0].id };
}

// 背景透過（Leonardo nobg variation）。失敗しても致命的にはせず、白背景のまま使う
// （最終的に rembg 等で後処理してもよい。ガイドの「背景：完全透過」要件を満たすための試行）
async function tryRemoveBackground(generatedImageId) {
  try {
    const createRes = await fetch(`${API_BASE}/variations/nobg`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${LEONARDO_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ id: generatedImageId, isVariation: true }),
    });
    if (!createRes.ok) return null;
    const created = await createRes.json();
    const varId = created?.sdNobgJob?.id || created?.sdGenerationJob?.generationId;
    if (!varId) return null;

    let attempts = 0;
    while (attempts < 15) {
      await new Promise((r) => setTimeout(r, 2000));
      const poll = await fetch(`${API_BASE}/variations/${varId}`, {
        headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
      });
      if (!poll.ok) return null;
      const data = await poll.json();
      const v = data.generated_image_variation_generic?.[0];
      if (v?.status === 'COMPLETE' && v?.url) return v.url;
      if (v?.status === 'FAILED') return null;
      attempts++;
    }
    return null;
  } catch (e) {
    return null;
  }
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
    console.error('   $env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY","User")');
    process.exit(1);
  }

  const opts = parseArgs();
  console.log(`📋 キャラ定義 ${CHARACTERS.length} 体を読み込みました`);

  let target;
  if (opts.ids) {
    target = CHARACTERS.filter((c) => opts.ids.includes(c.id));
  } else if (opts.all) {
    target = CHARACTERS;
  } else {
    const n = opts.count || 2;
    target = CHARACTERS.slice(0, n);
  }

  if (target.length === 0) {
    console.error('❌ 対象キャラが見つかりません');
    process.exit(1);
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  const manifest = fs.existsSync(manifestPath)
    ? JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    : {};

  // 既存ファイルは自動スキップ（課金の重複防止。--force で再生成）
  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((char) => {
        const exists = fs.existsSync(outFileFor(char));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}体をスキップ（再生成するには --force を付けてください）`);
  }
  console.log(
    `🎨 ${toGenerate.length} 体を1枚ずつ逐次生成します（Leonardo.ai / Phoenix1.0 / modelId=${LEONARDO_MODEL_ID} / alchemy=off / 512x512）\n`
  );

  for (const char of toGenerate) {
    process.stdout.write(`  #${char.no} ${char.nameJp}（${char.field}） ... `);
    try {
      const { url, generatedImageId } = await generateImage(char.prompt, NEGATIVE_PROMPT);

      let finalUrl = url;
      let bgRemoved = false;
      const nobgUrl = await tryRemoveBackground(generatedImageId);
      if (nobgUrl) {
        finalUrl = nobgUrl;
        bgRemoved = true;
      }

      const outFile = outFileFor(char);
      await downloadTo(finalUrl, outFile);

      manifest[char.id] = {
        no: char.no,
        nameJp: char.nameJp,
        field: char.field,
        color: char.color,
        file: path.basename(outFile),
        prompt: char.prompt,
        provider: 'leonardo',
        modelId: LEONARDO_MODEL_ID,
        backgroundRemoved: bgRemoved,
        generatedAt: new Date().toISOString(),
      };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
      console.log(bgRemoved ? '✅（透過済み）' : '✅（白背景・要手動透過処理）');
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了（生成${toGenerate.length}体 / スキップ${skipped}体）。出力先: ${OUTPUT_DIR}`);
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
