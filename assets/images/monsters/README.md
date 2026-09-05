# まちがい図鑑モンスター画像（16枚）

生成方法: `tools/rika_monster_image_gen/README.md` を参照。

## 命名規則

`grade{学年}_{進化段階}.png`

| 学年 | 進化段階 (baby/juvenile/adult/sage) |
|---|---|
| 3 | grade3_baby.png / grade3_juvenile.png / grade3_adult.png / grade3_sage.png |
| 4 | grade4_baby.png / grade4_juvenile.png / grade4_adult.png / grade4_sage.png |
| 5 | grade5_baby.png / grade5_juvenile.png / grade5_adult.png / grade5_sage.png |
| 6 | grade6_baby.png / grade6_juvenile.png / grade6_adult.png / grade6_sage.png |

未生成の間は `MonsterImage` ウィジェットが自動的に絵文字表示にフォールバックするため、
このフォルダが空でもアプリは正常動作する。
