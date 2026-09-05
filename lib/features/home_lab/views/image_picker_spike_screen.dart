import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// スパイク: image_picker 動作確認用最小スクリーン
/// 目的: Week 3 Day 3-4 の実装前に、プラグイン動作を先に検証
/// テスト項目:
/// - ✅ ギャラリーから1枚選べる
/// - ✅ ビルド成功 (権限設定確認)
/// - ✅ 実機で Android permission 表示される
class ImagePickerSpikeScreen extends StatefulWidget {
  const ImagePickerSpikeScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerSpikeScreen> createState() => _ImagePickerSpikeScreenState();
}

class _ImagePickerSpikeScreenState extends State<ImagePickerSpikeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 画像選択完了: ${image.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 画像選択がキャンセルされました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ エラー: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ カメラで撮影完了: ${image.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 撮影がキャンセルされました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ カメラエラー: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker スパイク検証'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステータス
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 スパイク検証項目',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(_selectedImage == null
                      ? '🔴 画像未選択'
                      : '✅ 画像選択済み'),
                  Text('🔴 ビルド状態: 確認中...'),
                  Text('🔴 権限設定: 実機確認待ち'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('ギャラリーから選ぶ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('カメラで撮影'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],

            // 選択画像表示
            if (_selectedImage != null) ...[
              const SizedBox(height: 20),
              const Text(
                '📸 選択済み画像:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    height: 300,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ファイルサイズ: ${(_selectedImage!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 30),

            // テスト結果テンプレート
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 検証結果（実機テスト完了後に記入）',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('- flutter build apk --release: ___________'),
                  Text('- ビルド成功: [ ] YES / [ ] NO'),
                  Text('- APK サイズ: __________ MB'),
                  Text('- 権限要求表示: [ ] YES / [ ] NO'),
                  Text('- ギャラリー選択動作: [ ] OK / [ ] NG'),
                  Text('- カメラ撮影動作: [ ] OK / [ ] NG'),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ このスクリーンは本実装では削除します（スパイク検証用）',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
