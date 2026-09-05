# 🔥 Firestore スキーマ設計: おうち実験キット

**設計日**: 2026-07-07  
**対象**: ⑪ おうち実験キット (親子連携)  
**用途**: 子の実験記録 → 親に共有 → 親からほめコメント  

---

## 📊 Collection 構成

```
Firestore
├── users/
│   ├── {userId}/
│   │   ├── profile (名前、avatar など)
│   │   ├── children/ (親のみ)
│   │   │   └── {childId} (紐付けられた子ユーザー)
│   │   └── parent_id (子のみ、親の ID)
│   │
│   └── {childId}/
│       └── experiments/
│           └── {recordId}
│
└── experiment_records/
    └── {recordId}
```

---

## 🗂️ Collection スキーマ詳細

### 1️⃣ **users/{userId}/profile** (既存、そのまま利用)

```json
{
  "nickname": "太郎",
  "avatarEmoji": "🐢",
  "grade": 3,
  "role": "child" | "parent",
  "createdAt": "2026-01-01T10:00:00Z"
}
```

### 2️⃣ **users/{parentId}/children** (親専用)

**説明**: 親が管理する子ユーザーのリスト

```json
{
  "childId": {
    "childUserId": "child_xyz",
    "childName": "太郎",
    "childAvatar": "🐢",
    "linkedAt": "2026-03-01T10:00:00Z",
    "permissions": ["view_experiments", "comment"]
  }
}
```

### 3️⃣ **users/{childId} - 新規フィールド追加**

```json
{
  // 既存フィールド
  "nickname": "太郎",
  "avatarEmoji": "🐢",
  "grade": 3,
  "role": "child",
  
  // 新規: 親連携用
  "parentId": "parent_xyz",  // ← 子を登録した親の ID
  "parentName": "花子",        // ← 親の名前 (UI 表示用)
  "linkedToParentAt": "2026-03-01T10:00:00Z"
}
```

### 4️⃣ **users/{childId}/experiments/{recordId}** (子の実験記録)

**説明**: ユーザーごとの実験実施記録

```json
{
  "experimentId": "exp_salt_001",      // 実験テンプレートの ID
  "experimentTitle": "塩の結晶実験",
  "grade": 3,
  
  // 実施情報
  "completedAt": "2026-07-08T14:30:00Z",
  "duration": 45,                       // 分
  
  // 記録内容
  "userNote": "きれいな結晶ができました！",
  "photoUrls": [
    "gs://bucket/experiments/{recordId}/photo_1.jpg",
    "gs://bucket/experiments/{recordId}/photo_2.jpg"
  ],
  "photoCount": 2,
  
  // 予想 vs 実際
  "prediction": "塩が粉のまま残ると思いました",
  "result": "大きな結晶ができました",
  "matches_prediction": false,
  
  // 親コメント連携
  "parentComments": [
    {
      "parentId": "parent_xyz",
      "parentName": "花子",
      "parentAvatar": "🐱",
      "comment": "すごい！よく観察できてるね。",
      "badge": "親子で実験成功！",        // バッジ付与
      "commentedAt": "2026-07-08T20:00:00Z"
    }
  ],
  "parentCommentCount": 1,
  
  // メタデータ
  "createdAt": "2026-07-08T14:30:00Z",
  "updatedAt": "2026-07-08T20:00:00Z",
  "isPublished": true                  // 親に見えるか
}
```

---

## 🔐 Firestore セキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ユーザープロフィール
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // 子リスト (親のみ)
      match /children/{childId} {
        allow read, write: if request.auth.uid == userId && 
                             get(/databases/$(database)/documents/users/$(userId)).data.role == 'parent';
      }
      
      // 実験記録 (本人のみ)
      match /experiments/{recordId} {
        allow read: if request.auth.uid == userId ||
                       // 親も読める
                       get(/databases/$(database)/documents/users/$(userId)).data.parentId == request.auth.uid;
        allow write: if request.auth.uid == userId;
        allow update: if request.auth.uid == userId ||
                         // 親はコメント追加のみ許可
                         (request.auth.uid == get(/databases/$(database)/documents/users/$(userId)).data.parentId &&
                          request.resource.data.diff(resource.data).affectedKeys().hasOnly(['parentComments']));
      }
    }
    
    // 集約用コレクション（今後の拡張用）
    match /experiment_records/{recordId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.childId;
    }
  }
}
```

---

## 💾 データフロー図

```
子の実験完了
  ↓ (子が記録・写真アップロード)
users/{childId}/experiments/{recordId}
  ↓ (Firestore トリガー)
parent_dashboard_screen.dart が親の view 更新
  ↓ (親が「ほめる」コメント追加)
parentComments[] に追加
  ↓ (Cloud Messaging)
子に通知: 「お母さんがほめてくれました」
  ↓ (バッジシステム統合)
badge_earned_dialog.dart
```

---

## 🔗 既存システムとの統合

### shared_core の Badge システム

```dart
// badge_system.dart に新規バッジ追加
{
  "parent_praise_experiment": {
    "title": "親子で実験成功！",
    "description": "親からほめられた実験記録が5個",
    "icon": "👨‍👩‍👧",
    "unlockCondition": "parentComments.length >= 5",
    "points": 100
  }
}
```

### parent_dashboard_screen.dart への組み込み

現在の親ダッシュボード画面に実験記録タブを追加:

```
┌─ 親ダッシュボード ─────────────┐
│                               │
│ [クイズ進捗]  [実験記録] ← 新規 │
│                               │
│ ▼ 実験記録一覧                 │
│ 🧂 塩の結晶実験                │
│   📸 2枚 | 👍 ほめコメント 1件 │
│                               │
│ 💡 トマトの光合成実験          │
│   📸 3枚 | 👍 ほめコメント 0件 │
│                               │
└──────────────────────────────┘
```

---

## 📱 クライアント側の実装

### Child Side (子ユーザー)

```dart
// 実験記録の保存
await FirebaseFirestore.instance
  .collection('users')
  .doc(childUserId)
  .collection('experiments')
  .add(ExperimentRecord(
    experimentId: 'exp_salt_001',
    photoUrls: ['gs://...photo_1.jpg'],
    userNote: 'きれいな結晶ができた',
    // ...
  ).toJson());
```

### Parent Side (親ユーザー)

```dart
// 子の実験記録を表示
final experiments = await FirebaseFirestore.instance
  .collection('users')
  .doc(childUserId)
  .collection('experiments')
  .orderBy('completedAt', descending: true)
  .get();

// コメント追加
await FirebaseFirestore.instance
  .collection('users')
  .doc(childUserId)
  .collection('experiments')
  .doc(recordId)
  .update({
    'parentComments': FieldValue.arrayUnion([
      {
        'parentId': parentUserId,
        'parentName': '花子',
        'comment': 'すごい！',
        'commentedAt': DateTime.now().toIso8601String(),
      }
    ]),
  });
```

---

## 🧪 検証チェック

### データ整合性テスト

```dart
test('parentId が設定されている子は、親が実験記録を見られる', () async {
  // 1. 子を作成 (parentId = parent_xyz)
  // 2. 子が実験記録を追加
  // 3. 親が同じレコードを読めるか確認
  expect(parentCanRead, true);
});

test('parentId が異なる親は実験記録を見られない', () async {
  // 親A → 子 で紐付け
  // 親B が子の実験を読み込み試行
  expect(parentBCanRead, false);
});

test('コメント追加時に parentCommentCount が正しく更新される', () async {
  // 初期状態: count = 0
  // コメント1個追加 → count = 1
  expect(count, 1);
});
```

### パフォーマンステスト

```
- 子ユーザーの実験記録一覧取得: < 500ms
- 親が見る子の実験詳細: < 500ms (セキュリティルール評価含む)
- コメント追加: < 1000ms (ストレージアップロード含む)
```

---

## 📝 マイグレーション計画 (既存ユーザー)

現在のユーザーで既に親-子関係が成立している場合:

```sql
-- 既存の親子関係から migration
UPDATE users SET parentId = {親のID} WHERE role = 'child'
UPDATE users SET children = {紐付けられた子のリスト} WHERE role = 'parent'
```

**実装時期**: Week 3 Day 5-6 (統合テスト時)

---

## 🎯 Week 3 開始前の確認項目

- [ ] Firestore project で collections 手動作成済み
- [ ] セキュリティルール デプロイ済み
- [ ] Child 側の実験記録保存テスト (Dart): PASS
- [ ] Parent 側の読み込みテスト (Dart): PASS
- [ ] Cloud Storage バケット設定確認 (photoUrls)

---

**準備完了ゲート**: このスキーマで Week 3 Day 4 (統合) に入ります。
