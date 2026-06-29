import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../data/seeds/stages.dart';
import '../../../data/seeds/learn_content_data.dart';
import '../../progress/providers/user_progress_provider.dart';

/// まなぶモード - ステージの学習ページ
class LearnScreen extends ConsumerWidget {
  final String stageId;
  const LearnScreen({super.key, required this.stageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageData = stagesData.firstWhere(
      (s) => s['id'] == stageId,
      orElse: () => stagesData.first,
    );
    final sections = learnContentData[stageId] ?? _defaultSections(stageData);
    final progressAsync = ref.watch(userProgressProvider);
    final bestScore = progressAsync.value?.clearedStages[stageId];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, stageData, bestScore),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...sections.asMap().entries.map((e) =>
                        _SectionCard(
                          section: e.value,
                          index: e.key,
                          total: sections.length,
                        )),
                    const SizedBox(height: 8),
                    // 動画で調べるボタン（YouTube検索）
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              final stageName = stageData['stageName'] as String;
                              final query = Uri.encodeComponent('$stageName 理科 小学校 実験');
                              _launchUrl('https://www.youtube.com/results?search_query=$query');
                            },
                            icon: const Text('▶️', style: TextStyle(fontSize: 16)),
                            label: const Text('YouTubeで動画を探す'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF0000),
                              side: const BorderSide(color: Color(0xFFFF0000)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () {
                              final stageName = stageData['stageName'] as String;
                              final query = Uri.encodeComponent('$stageName 理科');
                              _launchUrl('https://www2.nhk.or.jp/school/movie/bangumi.cgi?das_id=&keyword=${Uri.encodeComponent(stageName)}');
                            },
                            icon: const Text('📺', style: TextStyle(fontSize: 16)),
                            label: const Text('NHK for School で調べる'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(color: Colors.blue.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildQuizButton(context),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context,
      Map<String, dynamic> stageData, int? bestScore) {
    final cat = stageData['category'] as String;
    final catEmoji = _categoryEmoji[cat] ?? '🔬';
    final catColor = _categoryColor[cat] ?? AppColors.sciencePrimary;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
      Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [catColor, catColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 戻るボタン
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('もどる',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // カテゴリ＋学年バッジ
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$catEmoji ${_categoryLabel[cat] ?? "理科"}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stageData['gradeLevel']}年生',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (bestScore != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✅ $bestScore%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // ステージ名（ふりがな付き）
          FuriganaText(
            stageData['stageName'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stageData['description'] as String,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
    Positioned(
      right: 16,
      bottom: 20,
      child: Opacity(
        opacity: 0.12,
        child: Text(catEmoji, style: const TextStyle(fontSize: 80)),
      ),
    ),
    ],);
  }

  Widget _buildQuizButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/quiz/$stageId'),
        icon: const Icon(Icons.quiz_rounded),
        label: const Text(
          'クイズにちょうせん！',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sciencePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.sciencePrimary.withOpacity(0.5),
        ),
      ),
    );
  }

  List<Map<String, String>> _defaultSections(
      Map<String, dynamic> s) {
    final guide = s['learningGuide'] as String? ?? '';
    // learningGuide からキーワードを抽出
    final keywordMatch =
        RegExp(r'キーワード\n(.+)', dotAll: true).firstMatch(guide);
    final keywords = keywordMatch?.group(1)?.trim() ?? '';

    return [
      {
        'emoji': '📖',
        'title': 'この${s['stageName']}で${s['gradeLevel']}年生が学ぶこと',
        'body': s['description'] as String,
      },
      {
        'emoji': '🔑',
        'title': 'キーワード',
        'body': keywords.isNotEmpty ? keywords : '教科書でかくにんしよう',
      },
      {
        'emoji': '💡',
        'title': 'クイズのポイント',
        'body': 'このステージのクイズで大事なことを教科書でよく読んでから\nクイズにちょうせんしよう！',
      },
    ];
  }

  static const _categoryEmoji = {
    'biology': '🌱',
    'physics': '⚡',
    'chemistry': '🧪',
    'earth': '🌍',
  };

  static const _categoryColor = {
    'biology': Color(0xFF43A047),
    'physics': Color(0xFF1E88E5),
    'chemistry': Color(0xFF8E24AA),
    'earth': Color(0xFF6D4C41),
  };

  static const _categoryLabel = {
    'biology': '生き物',
    'physics': '物理',
    'chemistry': '化学',
    'earth': '地球・宇宙',
  };

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}

// ── セクションカード ─────────────────────────────────────────
class _SectionCard extends StatefulWidget {
  final Map<String, dynamic> section;
  final int index;
  final int total;

  const _SectionCard({
    required this.section,
    required this.index,
    required this.total,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  static const _colors = [
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFF3E5F5),
  ];
  static const _accentColors = [
    AppColors.sciencePrimary,
    AppColors.success,
    Color(0xFFFF8F00),
    Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    Future.delayed(
        Duration(milliseconds: 80 * widget.index), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isNewStructure {
    return widget.section.containsKey('sections') &&
        widget.section['sections'] is List;
  }

  bool get _isSummary {
    final emoji = widget.section['emoji'] ?? '';
    final title = widget.section['title'] ?? '';
    return emoji == '💡' ||
        emoji == '📝' ||
        title.contains('ポイント') ||
        title.contains('まとめ');
  }

  @override
  Widget build(BuildContext context) {
    final colorIndex = widget.index % _colors.length;
    final bgColor = _isSummary ? const Color(0xFFFFF8E1) : _colors[colorIndex];
    final accentColor =
        _isSummary ? const Color(0xFFFF8F00) : _accentColors[colorIndex];
    final borderColor = _isSummary
        ? const Color(0xFFFFB300)
        : accentColor.withOpacity(0.2);
    final emoji = widget.section['emoji'] ?? '📖';
    final title = widget.section['title'] ?? '';

    if (_isNewStructure) {
      return _buildNewStructure(context, colorIndex, bgColor, accentColor, borderColor, emoji, title);
    }

    final body = widget.section['body'] ?? '';
    final imagePath = widget.section['imagePath'];

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isSummary
                      ? const Color(0xFFFFB300).withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isSummary ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: borderColor, width: _isSummary ? 2 : 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 画像表示（あれば）
                if (imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  ),
                // ヘッダー（ステップバッジ + タイトル）
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 絵文字
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // STEP バッジ or テストに出る！バッジ
                            if (_isSummary)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '⭐ テストに出る！',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'STEP ${widget.index + 1}/${widget.total}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // 進捗ドット
                                  ...List.generate(widget.total, (i) =>
                                    Container(
                                      margin: const EdgeInsets.only(right: 3),
                                      width: i == widget.index ? 14 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: i <= widget.index
                                            ? accentColor
                                            : accentColor.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 5),
                            FuriganaText(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 本文
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: _buildBody(body, accentColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewStructure(BuildContext context, int colorIndex, Color bgColor,
      Color accentColor, Color borderColor, String emoji, String title) {
    final introduction = widget.section['introduction'] ?? '';
    final sections = (widget.section['sections'] as List?) ?? [];
    final summary = widget.section['summary'] ?? '';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
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
              border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'SECTION ${widget.index + 1}/${widget.total}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            FuriganaText(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 本文
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 導入文
                      if (introduction.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FuriganaText(
                            introduction,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              height: 1.9,
                            ),
                          ),
                        ),
                      // セクション本論
                      ...sections.asMap().entries.map((e) {
                        final section = e.value as Map<String, dynamic>;
                        return _buildContentSection(section, accentColor);
                      }),
                      // まとめ
                      if (summary.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFFB300),
                                  width: 1.5),
                            ),
                            child: FuriganaText(
                              summary,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(
      Map<String, dynamic> section, Color accentColor) {
    final type = section['type'] as String?;
    final level = section['level'] as String? ?? 'basic';
    final text = section['text'] as String?;
    final imagePath = section['imagePath'] as String?;
    final caption = section['caption'] as String?;

    // レベルバッジ
    final levelLabel = switch (level) {
      'basic' => '基本',
      'standard' => '応用',
      'advanced' => '発展',
      _ => level,
    };
    final levelColor = switch (level) {
      'basic' => const Color(0xFF81C784),
      'standard' => const Color(0xFF64B5F6),
      'advanced' => const Color(0xFFBA68C8),
      _ => Colors.grey,
    };

    if (type == 'image' && imagePath != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 160,
              ),
            ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: levelColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        levelLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FuriganaText(
                        caption,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    if (type == 'text' && text != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                levelLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FuriganaText(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                height: 1.9,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBody(String body, Color accentColor) {
    final lines = body.split('\n').where((l) => l.isNotEmpty).toList();
    final hasBullets = lines.any((l) => l.startsWith('・'));

    if (!hasBullets) {
      return FuriganaText(
        body,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textDark,
          height: 2.0,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('・')) {
          final text = line.substring(1).trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 9),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FuriganaText(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                      height: 1.9,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FuriganaText(
            line,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              height: 2.0,
            ),
          ),
        );
      }).toList(),
    );
  }
}
