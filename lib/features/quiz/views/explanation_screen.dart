import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/explanation_model.dart';
import '../models/question_model.dart';

/// 解説画面（リニューアル版）
/// ・タブ廃止 → 縦スクロール 1画面
/// ・YouTube 動画インライン再生
/// ・マークダウン解説
/// ・絵文字付きキーポイントカード
/// ・比較表ウィジェット
class ExplanationScreen extends StatefulWidget {
  final QuestionModel question;
  final ExplanationModel explanation;
  final bool isCorrect;
  final int selectedAnswerIndex;
  final int earnedPoints;

  const ExplanationScreen({
    super.key,
    required this.question,
    required this.explanation,
    required this.isCorrect,
    required this.selectedAnswerIndex,
    required this.earnedPoints,
  });

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bannerAnim;
  late Animation<double> _bannerScale;
  final List<YoutubePlayerController> _ytControllers = [];
  bool _isDetailExpanded = false;

  @override
  void initState() {
    super.initState();

    // バナーのスケールアニメーション
    _bannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerScale = CurvedAnimation(
      parent: _bannerAnim,
      curve: Curves.elasticOut,
    );
    _bannerAnim.forward();

    // YouTube プレーヤー初期化
    for (final v in widget.explanation.videos) {
      final ctrl = YoutubePlayerController.fromVideoId(
        videoId: v.youtubeId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
      _ytControllers.add(ctrl);
    }
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    for (final c in _ytControllers) {
      c.close();
    }
    super.dispose();
  }

  // ─── ユーティリティ ────────────────────────────────────
  Color get _bannerBg =>
      widget.isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC);

  Color get _bannerAccent =>
      widget.isCorrect ? AppColors.success : AppColors.error;

  String get _bannerEmoji => widget.isCorrect ? '🎉' : '😢';
  String get _bannerMessage => widget.isCorrect ? 'せいかい！' : 'ざんねん…';

  // ─── メイン build ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: _bannerAccent,
        foregroundColor: Colors.white,
        title: Text(
          widget.isCorrect ? '✅ 正解！' : '❌ 不正解',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultBanner(),
            _buildAnswerReview(),
            _buildBasicExplanation(),
            if (widget.explanation.videos.isNotEmpty) _buildVideoSection(),
            _buildKeyPointsSection(),
            _buildDetailedExplanation(),
            if (widget.explanation.comparisonTable != null)
              _buildComparisonTable(),
            if (widget.explanation.realWorldExample != null)
              _buildInfoCard(
                emoji: '🌍',
                title: '実生活での応用',
                body: widget.explanation.realWorldExample!,
                bgColor: const Color(0xFFE3F2FD),
                borderColor: AppColors.sciencePrimary,
              ),
            if (widget.explanation.commonMistake != null)
              _buildInfoCard(
                emoji: '⚠️',
                title: 'よくある間違い',
                body: widget.explanation.commonMistake!,
                bgColor: const Color(0xFFFFF3E0),
                borderColor: Colors.orange,
              ),
            _buildInfoCard(
              emoji: '💡',
              title: '学習のコツ',
              body: widget.explanation.learningTip,
              bgColor: const Color(0xFFFFFDE7),
              borderColor: Colors.amber,
            ),
            if (widget.explanation.funFact != null)
              _buildInfoCard(
                emoji: '🎯',
                title: '豆知識',
                body: widget.explanation.funFact!,
                bgColor: const Color(0xFFE8F5E9),
                borderColor: AppColors.success,
              ),
            _buildNextLearningSection(),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── 結果バナー ────────────────────────────────────────
  Widget _buildResultBanner() {
    return ScaleTransition(
      scale: _bannerScale,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: _bannerBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _bannerAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: _bannerAccent.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(_bannerEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bannerMessage,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _bannerAccent,
                    ),
                  ),
                  if (widget.isCorrect) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '＋${widget.earnedPoints} ポイント',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 選択肢レビュー（○×付き） ────────────────────────
  Widget _buildAnswerReview() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '📝', title: '問題の確認'),
          const SizedBox(height: 12),
          // 問題文
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.question.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 全選択肢を表示
          ...List.generate(widget.question.answers.length, (i) {
            final isSelected = i == widget.selectedAnswerIndex;
            final isCorrect = i == widget.question.correctAnswerIndex;
            return _AnswerTile(
              label: ['A', 'B', 'C', 'D'][i],
              text: widget.question.answers[i],
              isSelected: isSelected,
              isCorrect: isCorrect,
            );
          }),
        ],
      ),
    );
  }

  // ─── ワンポイント解説 ──────────────────────────────────
  Widget _buildBasicExplanation() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '✨', title: 'かんたん解説'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sciencePrimary.withOpacity(0.08),
                  AppColors.sciencePrimary.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.sciencePrimary.withOpacity(0.3)),
            ),
            child: Text(
              widget.explanation.basicExplanation,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                height: 1.7,
              ),
            ),
          ),
          // 解説画像
          if (widget.explanation.explanationImageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.explanation.explanationImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _ImageShimmer(),
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── YouTube 動画セクション ────────────────────────────
  Widget _buildVideoSection() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '🎬', title: '動画で学ぼう'),
          const SizedBox(height: 4),
          const Text(
            '動画を見るとさらによくわかるよ！',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.explanation.videos.length, (i) {
            final video = widget.explanation.videos[i];
            return _VideoCard(
              video: video,
              controller: _ytControllers[i],
            );
          }),
        ],
      ),
    );
  }

  // ─── キーポイントカード ────────────────────────────────
  Widget _buildKeyPointsSection() {
    if (widget.explanation.keyPoints.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '📌', title: 'おぼえよう！'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.explanation.keyPoints.map((kp) {
              return _KeyPointChip(keyPoint: kp);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 詳細解説（折りたたみ）────────────────────────────
  Widget _buildDetailedExplanation() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isDetailExpanded = !_isDetailExpanded),
            child: Row(
              children: [
                const Text('🔬', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'くわしい解説',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isDetailExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more,
                      color: AppColors.textGray),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: MarkdownBody(
                data: widget.explanation.detailedExplanation,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textDark,
                    height: 1.8,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.scienceSecondary,
                  ),
                  h3: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  listBullet: const TextStyle(color: AppColors.sciencePrimary),
                  blockquoteDecoration: BoxDecoration(
                    color: AppColors.scienceLight,
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(
                      left: BorderSide(
                          color: AppColors.sciencePrimary, width: 4),
                    ),
                  ),
                ),
              ),
            ),
            crossFadeState: _isDetailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  // ─── 比較表 ────────────────────────────────────────────
  Widget _buildComparisonTable() {
    final table = widget.explanation.comparisonTable!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '📊', title: 'くらべてみよう'),
          const SizedBox(height: 12),
          _ComparisonTableWidget(table: table),
        ],
      ),
    );
  }

  // ─── 汎用インフォカード ────────────────────────────────
  Widget _buildInfoCard({
    required String emoji,
    required String title,
    required String body,
    required Color bgColor,
    required Color borderColor,
  }) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: emoji, title: title),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withOpacity(0.4)),
            ),
            child: MarkdownBody(
              data: body,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textDark,
                    height: 1.7),
                strong: TextStyle(
                    fontWeight: FontWeight.bold, color: borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 次のステップ ──────────────────────────────────────
  Widget _buildNextLearningSection() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(emoji: '🚀', title: '次は何を学ぶ？'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.scienceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.sciencePrimary.withOpacity(0.4)),
            ),
            child: Text(
              widget.explanation.nextLearning,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textDark,
                  height: 1.7),
            ),
          ),
          if (widget.explanation.relatedStageIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '関連する単元',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGray),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.explanation.relatedStageIds.map((id) {
                return ActionChip(
                  avatar: const Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.sciencePrimary),
                  label: Text(id,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sciencePrimary)),
                  backgroundColor: AppColors.scienceLight,
                  side: const BorderSide(
                      color: AppColors.sciencePrimary, width: 1),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$id へ移動します'),
                          duration: const Duration(seconds: 1)),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ─── アクションボタン ──────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                '次の問題へ',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sciencePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('ホームに戻る',
                  style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sciencePrimary,
                side: const BorderSide(
                    color: AppColors.sciencePrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// サブウィジェット群
// ══════════════════════════════════════════════════════════

/// カードコンテナ
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// セクションヘッダー（絵文字＋タイトル）
class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

/// 選択肢タイル（○×色付き）
class _AnswerTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;

  const _AnswerTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (isCorrect) {
      bg = const Color(0xFFE8F5E9);
      border = AppColors.success;
      icon = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (isSelected && !isCorrect) {
      bg = const Color(0xFFFCE4EC);
      border = AppColors.error;
      icon = Icons.cancel;
      iconColor = AppColors.error;
    } else {
      bg = const Color(0xFFF5F5F5);
      border = AppColors.borderGray;
      icon = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          // ラベル丸
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: border.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: border,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textDark,
                fontWeight:
                    isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (icon != null)
            Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}

/// キーポイントチップ（絵文字＋テキスト）
class _KeyPointChip extends StatelessWidget {
  final KeyPoint keyPoint;
  const _KeyPointChip({required this.keyPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scienceLight,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.sciencePrimary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(keyPoint.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            keyPoint.text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.scienceSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// YouTube 動画カード
class _VideoCard extends StatefulWidget {
  final VideoResource video;
  final YoutubePlayerController controller;

  const _VideoCard({required this.video, required this.controller});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // プレーヤー or サムネイル
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: _isPlaying
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(controller: widget.controller),
                  )
                : _VideoThumbnail(
                    videoId: widget.video.youtubeId,
                    onPlay: () {
                      setState(() => _isPlaying = true);
                      widget.controller.playVideo();
                    },
                  ),
          ),
          // 動画情報バー
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_circle_filled,
                    color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.video.source} ・ ${widget.video.durationLabel}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
                // YouTube で開くボタン
                IconButton(
                  icon: const Icon(Icons.open_in_new,
                      size: 18, color: AppColors.textGray),
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://www.youtube.com/watch?v=${widget.video.youtubeId}');
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await launchUrl(url, mode: LaunchMode.platformDefault);
                    }
                  },
                  tooltip: 'YouTubeで開く',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// サムネイル（再生ボタン付き）
class _VideoThumbnail extends StatelessWidget {
  final String videoId;
  final VoidCallback onPlay;

  const _VideoThumbnail(
      {required this.videoId, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // サムネイル画像
          Image.network(
            'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.movie,
                  color: Colors.white54, size: 48),
            ),
          ),
          // 暗めオーバーレイ
          Container(color: Colors.black.withOpacity(0.25)),
          // 再生ボタン
          Center(
            child: GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 比較表ウィジェット
class _ComparisonTableWidget extends StatelessWidget {
  final ComparisonTable table;
  const _ComparisonTableWidget({required this.table});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: AppColors.borderGray, borderRadius: BorderRadius.circular(8)),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        // ヘッダー行
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.sciencePrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          children: [
            _tableCell('比較項目', isHeader: true),
            _tableCell(table.headerA, isHeader: true),
            _tableCell(table.headerB, isHeader: true),
          ],
        ),
        // データ行
        ...table.rows.asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          final row = entry.value;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? Colors.white : AppColors.scienceLight,
            ),
            children: [
              _tableCell(row.label, isBold: true),
              _tableCell(row.valueA),
              _tableCell(row.valueB),
            ],
          );
        }),
      ],
    );
  }

  Widget _tableCell(String text,
      {bool isHeader = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 13 : 12.5,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}

/// 画像シマーローダー
class _ImageShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
