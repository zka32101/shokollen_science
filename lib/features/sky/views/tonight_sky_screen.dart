import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/sky_events_data.dart';

// ④ 今夜の空: 月相 + 天体イベントカレンダー
class TonightSkyScreen extends StatelessWidget {
  const TonightSkyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final phase = getMoonPhase(now);
    final phaseName = getMoonPhaseName(phase);
    final phaseDesc = getMoonPhaseDescription(phase);
    final mainEvent = getMainEventForMonth(now.month);
    final allEvents = getMonthEvents(now.month);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: const Text('今夜の空 🌌'),
        backgroundColor: const Color(0xFF0D1B4B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoonCard(phaseName, phaseDesc, phase, now),
            const SizedBox(height: 16),
            _buildMainEventCard(context, mainEvent),
            const SizedBox(height: 16),
            if (allEvents.length > 1) ...[
              _buildSectionTitle('今月の天体イベント'),
              const SizedBox(height: 10),
              ...allEvents.map((e) => _buildEventTile(context, e)),
              const SizedBox(height: 16),
            ],
            _buildObservationTips(),
            const SizedBox(height: 16),
            _buildMonthCalendar(context, now),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonCard(
      String phaseName, String phaseDesc, double phase, DateTime now) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade900, width: 1),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                phaseName.split(' ').first,
                style: const TextStyle(fontSize: 56),
              ),
              Text(
                '月齢 ${(phase * 29.5).toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.blue.shade200,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${now.month}月${now.day}日の月',
                  style: TextStyle(
                    color: Colors.blue.shade200,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phaseDesc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainEventCard(BuildContext context, SkyEvent event) {
    return GestureDetector(
      onTap: event.relatedStageId != null
          ? () => context.push('/quiz/${event.relatedStageId}')
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade700),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(event.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Text(
                          '⭐ 今月のイチオシ',
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔭',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.observationTip,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (event.relatedStageId != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '関連ステージで学ぶ →',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, SkyEvent event) {
    return GestureDetector(
      onTap: event.relatedStageId != null
          ? () => context.push('/quiz/${event.relatedStageId}')
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B4B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade900),
        ),
        child: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.observationTip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (event.relatedStageId != null)
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationTips() {
    const tips = [
      ('🌃', '暗い場所へ', '街灯から離れるほど星がよく見える'),
      ('⏰', '目を慣らして', '暗闇に15分いると目が慣れる'),
      ('🌡️', '防寒対策を', '夜は思ったより寒い'),
      ('📱', 'アプリ活用', '星座アプリで星の名前を調べよう'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '観察のコツ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(t.$1, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          t.$3,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context, DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('年間の主要天体イベント'),
        const SizedBox(height: 10),
        ...List.generate(12, (i) {
          final month = i + 1;
          final events = getMonthEvents(month);
          if (events.isEmpty) return const SizedBox.shrink();
          final top = events.reduce(
              (a, b) => a.rarity > b.rarity ? a : b);
          final isCurrentMonth = month == now.month;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentMonth
                  ? Colors.indigo.withOpacity(0.3)
                  : const Color(0xFF0D1B4B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCurrentMonth
                    ? Colors.indigo.shade400
                    : Colors.blue.shade900,
                width: isCurrentMonth ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$month月',
                    style: TextStyle(
                      color: isCurrentMonth
                          ? Colors.amber.shade300
                          : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(top.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    top.title,
                    style: TextStyle(
                      color: isCurrentMonth
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrentMonth)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '今月',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
