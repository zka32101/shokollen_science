import 'package:flutter/material.dart';
import 'package:shokollen_science/widgets/parental_gate.dart';

import '../../../services/study_reminder_service.dart';

/// 学習リマインダー（ローカル通知）の ON/OFF。
/// ON にする操作は通知の許可を求めるため、保護者ゲートを通す。
class ReminderSwitchTile extends StatefulWidget {
  const ReminderSwitchTile({super.key});

  @override
  State<ReminderSwitchTile> createState() => _ReminderSwitchTileState();
}

class _ReminderSwitchTileState extends State<ReminderSwitchTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    StudyReminderService.instance.isEnabled().then((v) {
      if (mounted) setState(() => _enabled = v);
    });
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final passed = await requireParentalGate(context);
      if (!passed || !mounted) return;
    }
    await StudyReminderService.instance.setEnabled(value);
    if (mounted) setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_active_outlined,
          color: Colors.orange),
      title: const Text('学習のおしらせ'),
      subtitle: const Text('いつも学習している時間に、1日1回までお知らせします（夜9時〜朝7時は送りません）'),
      value: _enabled ?? true,
      onChanged: _enabled == null ? null : _toggle,
    );
  }
}
