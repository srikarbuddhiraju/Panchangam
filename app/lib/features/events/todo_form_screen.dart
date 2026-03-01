import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../core/utils/app_strings.dart';
import 'user_tithi_event.dart' show ReminderType;
import 'user_todo.dart';
import 'user_todo_provider.dart';

/// Add or edit a personal To-Do item.
///
/// [todoId] — if non-null, load the existing To-Do for editing.
/// [prefillTithi] — if non-null, pre-select this tithi.
class TodoFormScreen extends ConsumerStatefulWidget {
  final String? todoId;
  final int? prefillTithi;

  const TodoFormScreen({super.key, this.todoId, this.prefillTithi});

  @override
  ConsumerState<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends ConsumerState<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late int _tithi;
  int? _teluguMonth;
  int? _reminderHour;
  int _reminderMinute = 0;
  ReminderType _reminderType = ReminderType.reminder;

  bool _isEditing = false;
  bool _saving = false;
  UserTodo? _original;

  static const _daysBeforeOptions = [0, 1, 2, 3, 7];

  @override
  void initState() {
    super.initState();
    _tithi = widget.prefillTithi ?? 1;

    if (widget.todoId != null) {
      _isEditing = true;
      final todos = ref.read(userTodoProvider);
      _original = todos.where((t) => t.id == widget.todoId).firstOrNull;
      if (_original != null) {
        _titleCtrl.text = _original!.title;
        _notesCtrl.text = _original!.notes ?? '';
        _tithi = _original!.tithi;
        _teluguMonth = _original!.teluguMonth;
        _reminderHour = _original!.reminderHour;
        _reminderMinute = _original!.reminderMinute;
        _reminderType = _original!.reminderType;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;

    final String screenTitle = _isEditing
        ? (isTelugu ? 'టు-డూ మార్చు' : 'Edit To-Do')
        : (isTelugu ? 'కొత్త టు-డూ' : 'New To-Do');

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: isTelugu ? 'తొలగించు' : 'Delete',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Title ──────────────────────────────────────────────────────
            _Label(label: isTelugu ? 'పని (టైటిల్)' : 'Task title'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: isTelugu
                    ? 'ఉదా. దేవాలయానికి వెళ్ళాలి'
                    : 'e.g. Visit temple on Ekadashi',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return isTelugu ? 'టైటిల్ అవసరం' : 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Tithi picker ───────────────────────────────────────────────
            _Label(label: isTelugu ? 'తిథి' : 'Tithi'),
            const SizedBox(height: 6),
            _TithiDropdown(
              selected: _tithi,
              onChanged: (t) => setState(() => _tithi = t),
            ),
            const SizedBox(height: 20),

            // ── Month picker ───────────────────────────────────────────────
            _Label(
              label: isTelugu
                  ? 'నెల (ఖాళీ = తదుపరి అందుబాటు పక్షం)'
                  : 'Month (empty = next available paksha)',
            ),
            const SizedBox(height: 6),
            _MonthDropdown(
              selected: _teluguMonth,
              onChanged: (m) => setState(() => _teluguMonth = m),
            ),
            const SizedBox(height: 8),

            // Target date info (edit mode)
            if (_isEditing && _original != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  isTelugu
                      ? 'లక్ష్య తేదీ: ${DateFormat('d/M/y').format(_original!.targetDate)}'
                      : 'Pinned to: ${DateFormat('d MMM y').format(_original!.targetDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),

            const SizedBox(height: 12),

            // ── Reminder ───────────────────────────────────────────────────
            _Label(label: isTelugu ? 'రిమైండర్' : 'Reminder'),
            const SizedBox(height: 6),
            _ReminderSection(
              reminderHour: _reminderHour,
              reminderMinute: _reminderMinute,
              reminderType: _reminderType,
              daysBeforeOptions: _daysBeforeOptions,
              isTelugu: isTelugu,
              cs: cs,
              onToggle: (enabled) {
                setState(() {
                  _reminderHour = enabled ? 8 : null;
                  _reminderMinute = 0;
                });
              },
              onPickTime: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay(hour: _reminderHour ?? 8, minute: _reminderMinute),
                );
                if (picked != null) {
                  setState(() {
                    _reminderHour = picked.hour;
                    _reminderMinute = picked.minute;
                  });
                }
              },
              onTypeChanged: (t) => setState(() => _reminderType = t),
            ),
            const SizedBox(height: 20),

            // ── Notes ──────────────────────────────────────────────────────
            _Label(
                label:
                    isTelugu ? 'గమనికలు (ఐచ్ఛికం)' : 'Notes (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: isTelugu ? 'వ్యక్తిగత గమనికలు...' : 'Any note...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save ───────────────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.kGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isTelugu ? 'సేవ్ చేయి' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(userTodoProvider.notifier);
    final title = _titleCtrl.text.trim();
    final notes =
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    try {
      if (_isEditing && _original != null) {
        await notifier.update(_original!.copyWith(
          title: title,
          notes: notes,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderHour: _reminderHour,
          reminderMinute: _reminderMinute,
          reminderType: _reminderType,
        ));
        if (mounted) context.pop();
      } else {
        final created = await notifier.add(
          title: title,
          notes: notes,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderHour: _reminderHour,
          reminderMinute: _reminderMinute,
          reminderType: _reminderType,
        );
        if (created == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.isTelugu
                ? 'తిథి 400 రోజులలో దొరకలేదు — తిథి తనిఖీ చేయండి'
                : 'No occurrence found in 400 days — check tithi selection'),
            backgroundColor: Colors.red.shade700,
          ));
        } else if (mounted) {
          _showTargetDateSnackBar(created!);
          context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showTargetDateSnackBar(UserTodo todo) {
    final isTelugu = S.isTelugu;
    final d = todo.targetDate;
    final dateStr = isTelugu
        ? '${d.day}/${d.month}/${d.year}'
        : DateFormat('d MMM y').format(d);
    final msg = isTelugu
        ? 'టు-డూ $dateStr కి సెట్ చేయబడింది'
        : 'To-Do pinned to $dateStr';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _confirmDelete() async {
    final isTelugu = S.isTelugu;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTelugu ? 'తొలగించాలా?' : 'Delete To-Do?'),
        content: Text(isTelugu
            ? 'ఈ టు-డూని శాశ్వతంగా తొలగిస్తారు.'
            : 'This To-Do will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isTelugu ? 'రద్దు' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isTelugu ? 'తొలగించు' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(userTodoProvider.notifier).delete(_original!.id);
      if (mounted) context.pop();
    }
  }
}

// ── Reminder section ──────────────────────────────────────────────────────────

class _ReminderSection extends StatelessWidget {
  final int? reminderHour;
  final int reminderMinute;
  final ReminderType reminderType;
  final List<int> daysBeforeOptions;
  final bool isTelugu;
  final ColorScheme cs;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;
  final ValueChanged<ReminderType> onTypeChanged;

  const _ReminderSection({
    required this.reminderHour,
    required this.reminderMinute,
    required this.reminderType,
    required this.daysBeforeOptions,
    required this.isTelugu,
    required this.cs,
    required this.onToggle,
    required this.onPickTime,
    required this.onTypeChanged,
  });

  String _formatTime() {
    final h = reminderHour! % 12 == 0 ? 12 : reminderHour! % 12;
    final m = reminderMinute.toString().padLeft(2, '0');
    final period = reminderHour! < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = reminderHour != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(isTelugu ? 'రిమైండర్ సెట్ చేయి' : 'Set reminder'),
            value: enabled,
            activeColor: AppTheme.kGold,
            onChanged: onToggle,
          ),
          if (enabled) ...[
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: SegmentedButton<ReminderType>(
                segments: [
                  ButtonSegment(
                    value: ReminderType.reminder,
                    icon: const Icon(Icons.notifications_outlined, size: 18),
                    label: Text(isTelugu ? 'రిమైండర్' : 'Reminder'),
                  ),
                  ButtonSegment(
                    value: ReminderType.alarm,
                    icon: const Icon(Icons.alarm, size: 18),
                    label: Text(isTelugu ? 'అలారం' : 'Alarm'),
                  ),
                ],
                selected: {reminderType},
                onSelectionChanged: (s) => onTypeChanged(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      AppTheme.kGold.withValues(alpha: 0.15),
                  selectedForegroundColor: AppTheme.kGold,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: OutlinedButton.icon(
                onPressed: onPickTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(_formatTime()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String label;
  const _Label({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}

class _TithiDropdown extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _TithiDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTelugu = S.isTelugu;
    return DropdownButtonFormField<int>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: List.generate(30, (i) {
        final tithi = i + 1;
        final paksha =
            tithi <= 15 ? (isTelugu ? 'శు' : 'S') : (isTelugu ? 'కృ' : 'K');
        final name = isTelugu ? Tithi.namesTe[i] : Tithi.namesEn[i];
        return DropdownMenuItem(
          value: tithi,
          child: Text('$tithi · $paksha · $name',
              overflow: TextOverflow.ellipsis),
        );
      }),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;
  const _MonthDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTelugu = S.isTelugu;
    return DropdownButtonFormField<int?>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(
              isTelugu ? 'తదుపరి పక్షం (నెల లేదు)' : 'Next paksha (any month)'),
        ),
        ...List.generate(12, (i) {
          final month = i + 1;
          final name = isTelugu
              ? TeluguCalendar.monthNamesTe[i]
              : TeluguCalendar.monthNamesEn[i];
          return DropdownMenuItem<int?>(
            value: month,
            child: Text('$month · $name'),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
