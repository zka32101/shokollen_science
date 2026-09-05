# -*- coding: utf-8 -*-
"""
理科キャラ16体: 白背景 → 透過PNG 変換スクリプト
rembg(onnxruntime)がこのPCでDLLエラーのため動かなかったための代替。
単色に近い白背景を対象に、色距離ベースでアルファ値を計算する簡易クロマキー方式。
（境界はソフトにフェザーしてギザギザを抑える）

使い方:
    python remove_white_bg.py
"""
import os
import glob
from PIL import Image
import numpy as np

TARGET_DIR = r"H:\マイドライブ\images\小学コレ！\理科\キャラクター"
BACKUP_DIR = os.path.join(TARGET_DIR, "_white_bg_backup")

WHITE = np.array([255, 255, 255], dtype=np.float32)
# この距離以下は完全透明、この距離以上は完全不透明。間はグラデーション（フェザー）
THRESHOLD_FULL_TRANSPARENT = 12
THRESHOLD_FULL_OPAQUE = 60


def remove_white_background(path: str) -> None:
    img = Image.open(path).convert("RGBA")
    arr = np.array(img).astype(np.float32)
    rgb = arr[:, :, :3]
    dist = np.linalg.norm(rgb - WHITE, axis=2)

    alpha = np.clip(
        (dist - THRESHOLD_FULL_TRANSPARENT)
        / (THRESHOLD_FULL_OPAQUE - THRESHOLD_FULL_TRANSPARENT),
        0,
        1,
    ) * 255

    arr[:, :, 3] = alpha
    out = Image.fromarray(arr.astype(np.uint8), mode="RGBA")
    out.save(path)


def main():
    os.makedirs(BACKUP_DIR, exist_ok=True)
    files = sorted(glob.glob(os.path.join(TARGET_DIR, "*_512.png")))
    print(f"対象: {len(files)} 枚")

    for f in files:
        name = os.path.basename(f)
        backup_path = os.path.join(BACKUP_DIR, name)
        if not os.path.exists(backup_path):
            Image.open(f).convert("RGBA").save(backup_path)  # 元の白背景版を退避

        remove_white_background(f)
        print(f"  ✅ {name}")

    print(f"\n完了。透過版で上書き保存しました。元の白背景版は {BACKUP_DIR} に退避済み。")


if __name__ == "__main__":
    main()
