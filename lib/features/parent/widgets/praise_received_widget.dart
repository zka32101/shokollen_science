import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../providers/praise_provider.dart';

class PraiseReceivedWidget extends ConsumerWidget {
  const PraiseReceivedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final praiseAsync = ref.watch(praiseProvider);

    return praiseAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (praise) {
        final unread = praise.unread;
        if (unread.isEmpty) return const SizedBox.shrink();
        final latest = unread.last;
        return _PraiseBanner(
          message: latest,
          onTap: () => _showPraiseDialog(context, ref, unread),
        );
      },
    );
  }

  void _showPraiseDialog(
    BuildContext context,
    WidgetRef ref,
    List<PraiseMessage> messages,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _PraiseDialog(
        messages: messages,
        onRead: () => ref.read(praiseProvider.notifier).markAllRead(),
      ),
    );
  }
}

class _PraiseBanner extends StatefulWidget {
  final PraiseMessage message;
  final VoidCallback onTap;

  const _PraiseBanner({required this.message, required this.onTap});

  @override
  State<_PraiseBanner> createState() => _PraiseBannerState();
}

class _PraiseBannerState extends State<_PraiseBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E8C).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('💌', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.message.senderName}からメッセージ！',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'みる',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PraiseDialog extends StatefulWidget {
  final List<PraiseMessage> messages;
  final VoidCallback onRead;

  const _PraiseDialog({required this.messages, required this.onRead});

  @override
  State<_PraiseDialog> createState() => _PraiseDialogState();
}

class _PraiseDialogState extends State<_PraiseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    widget.onRead();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.messages[_page];
    final isLast = _page == widget.messages.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0)
            .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💌', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              if (widget.messages.length > 1)
                Text(
                  '${_page + 1} / ${widget.messages.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              const SizedBox(height: 8),
              Text(
                '${msg.senderName}からメッセージ',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE91E8C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              FuriganaText(
                msg.stageName.isNotEmpty
                    ? '「${msg.stageName}」全問正解おめでとう！'
                    : 'よくがんばったね！',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE91E8C).withOpacity(0.3)),
                ),
                child: Text(
                  msg.message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC2185B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _page++;
                        _ctrl.reset();
                        _ctrl.forward();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast ? 'ありがとう！🎉' : '次のメッセージ →',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
