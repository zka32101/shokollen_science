import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../providers/praise_provider.dart';

const _presetMessages = [
  'すごいね！よくがんばったね！🎉',
  '次のステージも楽しみだね⭐',
  'パパも嬉しいよ！大好き😊',
  'ママとても誇りに思うよ！💖',
];

class PraiseSendScreen extends ConsumerStatefulWidget {
  final String stageId;
  final String stageName;

  const PraiseSendScreen({
    super.key,
    required this.stageId,
    required this.stageName,
  });

  @override
  ConsumerState<PraiseSendScreen> createState() => _PraiseSendScreenState();
}

class _PraiseSendScreenState extends ConsumerState<PraiseSendScreen> {
  String? _selectedPreset;
  final _customController = TextEditingController();
  final _senderController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _customController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  String get _message =>
      _customController.text.trim().isNotEmpty
          ? _customController.text.trim()
          : (_selectedPreset ?? '');

  bool get _canSend =>
      _message.isNotEmpty && _senderController.text.trim().isNotEmpty;

  Future<void> _send() async {
    if (!_canSend || _sending) return;
    setState(() => _sending = true);

    final sender = _senderController.text.trim();
    await ref.read(praiseProvider.notifier).sendPraise(
          message: _message,
          senderName: sender,
          stageId: widget.stageId,
          stageName: widget.stageName,
        );

    // 未ほめリストから削除
    await ref
        .read(pendingPraiseProvider.notifier)
        .removePraised(widget.stageId);

    if (mounted) {
      await _showSuccessDialog();
      if (mounted) context.pop();
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SentDialog(
        senderName: _senderController.text.trim(),
        message: _message,
        stageName: widget.stageName,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('ほめメッセージを送る'),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステージ情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '全問正解！',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        FuriganaText(
                          widget.stageName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 送り主名
            _sectionLabel('送り主（だれから？）'),
            const SizedBox(height: 6),
            TextField(
              controller: _senderController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '例）パパ、ママ、おじいちゃん',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // プリセット選択
            _sectionLabel('メッセージを選ぶ'),
            const SizedBox(height: 8),
            ..._presetMessages.map((msg) => _PresetTile(
                  message: msg,
                  isSelected: _selectedPreset == msg,
                  onTap: () => setState(() {
                    _selectedPreset = msg;
                    _customController.clear();
                  }),
                )),
            const SizedBox(height: 16),

            // カスタムメッセージ
            _sectionLabel('または自分で書く'),
            const SizedBox(height: 6),
            TextField(
              controller: _customController,
              maxLines: 3,
              maxLength: 100,
              onChanged: (_) => setState(() {
                if (_customController.text.isNotEmpty) _selectedPreset = null;
              }),
              decoration: InputDecoration(
                hintText: 'お子様へのひとことメッセージ…',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // 送信ボタン
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _canSend ? _send : null,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('💌', style: TextStyle(fontSize: 22)),
                label: Text(
                  _sending ? '送信中…' : 'ほめメッセージを送る',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textGray,
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final String message;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetTile({
    required this.message,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E8C) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFE91E8C) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFFC2185B) : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentDialog extends StatefulWidget {
  final String senderName;
  final String message;
  final String stageName;
  final VoidCallback onClose;

  const _SentDialog({
    required this.senderName,
    required this.message,
    required this.stageName,
    required this.onClose,
  });

  @override
  State<_SentDialog> createState() => _SentDialogState();
}

class _SentDialogState extends State<_SentDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0)
            .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💌', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                'メッセージを送りました！',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E8C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FuriganaText(
                'お子様のホーム画面に\n表示されます',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '「${widget.message}」\n― ${widget.senderName}より',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC2185B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  final shareText =
                      '🎉 子どもが「${widget.stageName}」を全問正解しました！\n'
                      '「${widget.message}」\n'
                      '― ${widget.senderName}より\n'
                      '#小学コレ理科 #小学生 #理科好き';
                  Share.share(shareText);
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('SNSでシェアする'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E8C),
                  side: const BorderSide(color: Color(0xFFE91E8C)),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
