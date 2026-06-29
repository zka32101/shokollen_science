import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 1件のほめメッセージ
class PraiseMessage {
  final String id;
  final String message;
  final String senderName; // 「お父さん」「お母さん」etc
  final String stageId;
  final String stageName;
  final DateTime sentAt;
  final bool isRead;

  const PraiseMessage({
    required this.id,
    required this.message,
    required this.senderName,
    required this.stageId,
    required this.stageName,
    required this.sentAt,
    this.isRead = false,
  });

  PraiseMessage copyWith({bool? isRead}) => PraiseMessage(
        id: id,
        message: message,
        senderName: senderName,
        stageId: stageId,
        stageName: stageName,
        sentAt: sentAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'senderName': senderName,
        'stageId': stageId,
        'stageName': stageName,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
      };

  factory PraiseMessage.fromJson(Map<String, dynamic> j) => PraiseMessage(
        id: j['id'] as String,
        message: j['message'] as String,
        senderName: j['senderName'] as String? ?? 'おうちの人',
        stageId: j['stageId'] as String? ?? '',
        stageName: j['stageName'] as String? ?? '',
        sentAt: DateTime.parse(j['sentAt'] as String),
        isRead: j['isRead'] as bool? ?? false,
      );
}

class PraiseState {
  final List<PraiseMessage> messages;

  const PraiseState({this.messages = const []});

  int get unreadCount => messages.where((m) => !m.isRead).length;
  List<PraiseMessage> get unread => messages.where((m) => !m.isRead).toList();
  PraiseMessage? get latest =>
      messages.isEmpty ? null : messages.last;
}

class PraiseNotifier extends AsyncNotifier<PraiseState> {
  static const _key = 'praise_messages_v1';

  @override
  Future<PraiseState> build() => _load();

  Future<PraiseState> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const PraiseState();
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => PraiseMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      return PraiseState(messages: list);
    } catch (_) {
      return const PraiseState();
    }
  }

  Future<void> _save(List<PraiseMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(messages.map((m) => m.toJson()).toList()));
  }

  /// 親がほめメッセージを送信
  Future<void> sendPraise({
    required String message,
    required String senderName,
    required String stageId,
    required String stageName,
  }) async {
    final current = state.value ?? const PraiseState();
    final newMsg = PraiseMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      senderName: senderName,
      stageId: stageId,
      stageName: stageName,
      sentAt: DateTime.now(),
    );
    final updated = [...current.messages, newMsg];
    // 最大20件保持
    final trimmed = updated.length > 20
        ? updated.sublist(updated.length - 20)
        : updated;
    await _save(trimmed);
    state = AsyncData(PraiseState(messages: trimmed));
  }

  /// メッセージを既読にする
  Future<void> markAllRead() async {
    final current = state.value ?? const PraiseState();
    final updated = current.messages.map((m) => m.copyWith(isRead: true)).toList();
    await _save(updated);
    state = AsyncData(PraiseState(messages: updated));
  }

  /// 未クリア通知があるステージIDリストを返す（親ダッシュボード用）
  List<String> get pendingStageIds =>
      (state.value?.messages ?? [])
          .where((m) => !m.isRead)
          .map((m) => m.stageId)
          .toList();
}

final praiseProvider =
    AsyncNotifierProvider<PraiseNotifier, PraiseState>(PraiseNotifier.new);

/// 親ダッシュボード側: 子どもがクリアしたステージの未ほめ記録
class PendingPraiseNotifier extends AsyncNotifier<List<Map<String, String>>> {
  static const _key = 'pending_praise_stages_v1';

  @override
  Future<List<Map<String, String>>> build() => _load();

  Future<List<Map<String, String>>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<Map<String, String>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  /// 子どもがステージをクリアしたとき（quiz_result_screenから呼ぶ）
  Future<void> addClearedStage(String stageId, String stageName) async {
    final current = await future;
    final already = current.any((e) => e['stageId'] == stageId);
    if (already) return;
    final updated = [...current, {'stageId': stageId, 'stageName': stageName}];
    await _save(updated);
    state = AsyncData(updated);
  }

  /// 親がほめたあとに削除
  Future<void> removePraised(String stageId) async {
    final current = await future;
    final updated = current.where((e) => e['stageId'] != stageId).toList();
    await _save(updated);
    state = AsyncData(updated);
  }
}

final pendingPraiseProvider =
    AsyncNotifierProvider<PendingPraiseNotifier, List<Map<String, String>>>(
        PendingPraiseNotifier.new);
