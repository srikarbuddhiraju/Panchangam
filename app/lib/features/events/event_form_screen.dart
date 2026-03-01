import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../core/utils/app_strings.dart';
import 'user_tithi_event.dart';
import 'user_event_provider.dart';
import '../../services/notification_service.dart';

/// Add or edit a personal tithi event.
///
/// [eventId] — if non-null, load the existing event for editing.
/// [prefillTithi] — if non-null, pre-select this tithi (set by "Mark this tithi" FAB).
class EventFormScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final int? prefillTithi;

  const EventFormScreen({super.key, this.eventId, this.prefillTithi});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnCtrl = TextEditingController();
  final _nameTeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late int _tithi;
  int? _teluguMonth;      // null = every paksha
  int? _reminderHour;     // null = no reminder
  int _reminderMinute = 0;
  int _reminderDaysBefore = 0;
  ReminderType _reminderType = ReminderType.reminder;

  bool _isEditing = false;
  bool _saving = false;
  UserTithiEvent? _original;

  static const _daysBeforeOptions = [0, 1, 2, 3, 7];

  @override
  void initState() {
    super.initState();
    _tithi = widget.prefillTithi ?? 1;

    if (widget.eventId != null) {
      _isEditing = true;
      final events = ref.read(userEventProvider);
      _original = events.where((e) => e.id == widget.eventId).firstOrNull;
      if (_original != null) {
        _nameEnCtrl.text = _original!.nameEn;
        _nameTeCtrl.text = _original!.nameTe ?? '';
        _notesCtrl.text = _original!.notes ?? '';
        _tithi = _original!.tithi;
        _teluguMonth = _original!.teluguMonth;
        _reminderHour = _original!.reminderHour;
        _reminderMinute = _original!.reminderMinute;
        _reminderDaysBefore = _original!.reminderDaysBefore;
        _reminderType = _original!.reminderType;
      }
    }
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameTeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;

    final String title = _isEditing
        ? (isTelugu ? 'సందర్భం మార్చు' : 'Edit Event')
        : (isTelugu ? 'కొత్త సందర్భం' : 'New Event');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            // ── Name (English) ─────────────────────────────────────────────
            _SectionLabel(
                label: isTelugu ? 'పేరు (ఆంగ్లంలో)' : 'Name (English)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameEnCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: isTelugu ? 'ఉదా. Guru Jayanti' : 'e.g. Guru Jayanti',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return isTelugu ? 'పేరు అవసరం' : 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Name (Telugu, optional) ────────────────────────────────────
            _SectionLabel(
                label: isTelugu
                    ? 'పేరు (తెలుగులో, ఐచ్ఛికం)'
                    : 'Name (Telugu, optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameTeCtrl,
              decoration: InputDecoration(
                hintText: isTelugu ? 'ఉదా. గురు జయంతి' : 'e.g. గురు జయంతి',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Tithi picker ───────────────────────────────────────────────
            _SectionLabel(label: isTelugu ? 'తిథి' : 'Tithi'),
            const SizedBox(height: 6),
            _TithiPicker(
              selected: _tithi,
              onChanged: (t) => setState(() => _tithi = t),
            ),
            const SizedBox(height: 20),

            // ── Month picker ───────────────────────────────────────────────
            _SectionLabel(
              label: isTelugu
                  ? 'నెల (ఖాళీ = ప్రతి పక్షం)'
                  : 'Month (empty = every paksha)',
            ),
            const SizedBox(height: 6),
            _MonthPicker(
              selected: _teluguMonth,
              onChanged: (m) => setState(() => _teluguMonth = m),
            ),
            const SizedBox(height: 20),

            // ── Reminder ───────────────────────────────────────────────────
            _SectionLabel(label: isTelugu ? 'రిమైండర్' : 'Reminder'),
            const SizedBox(height: 6),
            _ReminderRow(
              reminderHour: _reminderHour,
              reminderMinute: _reminderMinute,
              reminderDaysBefore: _reminderDaysBefore,
              reminderType: _reminderType,
              daysBeforeOptions: _daysBeforeOptions,
              isTelugu: isTelugu,
              cs: cs,
              onToggle: (enabled) {
                setState(() {
                  if (enabled) {
                    _reminderHour = 8;
                    _reminderMinute = 0;
                    _reminderDaysBefore = 0;
                  } else {
                    _reminderHour = null;
                  }
                });
              },
              onPickTime: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _reminderHour ?? 8,
                    minute: _reminderMinute,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _reminderHour = picked.hour;
                    _reminderMinute = picked.minute;
                  });
                }
              },
              onDaysChanged: (d) => setState(() => _reminderDaysBefore = d),
              onTypeChanged: (t) => setState(() => _reminderType = t),
            ),
            const SizedBox(height: 20),

            // ── Notes (optional) ───────────────────────────────────────────
            _SectionLabel(
                label: isTelugu ? 'గమనికలు (ఐచ్ఛికం)' : 'Notes (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: isTelugu
                    ? 'వ్యక్తిగత గమనికలు...'
                    : 'Any personal note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.kGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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

    final notifier = ref.read(userEventProvider.notifier);
    final nameEn = _nameEnCtrl.text.trim();
    final nameTe =
        _nameTeCtrl.text.trim().isEmpty ? null : _nameTeCtrl.text.trim();
    final notes =
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    try {
      if (_isEditing && _original != null) {
        await notifier.update(_original!.copyWith(
          nameEn: nameEn,
          nameTe: nameTe,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderHour: _reminderHour,
          reminderMinute: _reminderMinute,
          reminderDaysBefore: _reminderDaysBefore,
          reminderType: _reminderType,
          notes: notes,
        ));
      } else {
        await notifier.add(
          nameEn: nameEn,
          nameTe: nameTe,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderHour: _reminderHour,
          reminderMinute: _reminderMinute,
          reminderDaysBefore: _reminderDaysBefore,
          reminderType: _reminderType,
          notes: notes,
        );
      }

      // If alarm mode was chosen, verify exact-alarm permission is granted.
      // Do this after saving so the event is persisted regardless.
      if (_reminderHour != null &&
          _reminderType == ReminderType.alarm &&
          mounted) {
        final canExact =
            await NotificationService.instance.canScheduleExactNotifications();
        if (!canExact && mounted) {
          _showAlarmPermissionDialog();
          return; // don't pop — stay so user can see the dialog
        }
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showAlarmPermissionDialog() {
    final isTelugu = S.isTelugu;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTelugu ? 'అలారం అనుమతి కావాలి' : 'Alarm Permission Needed'),
        content: Text(
          isTelugu
              ? 'ఖచ్చితమైన అలారాల కోసం ప్రత్యేక అనుమతి అవసరం.\n'
                  'సెట్టింగ్స్ → అప్లికేషన్లు → ప్రత్యేక యాక్సెస్ → అలారాలు & రిమైండర్లు\n'
                  'లో Panchangam ని ఆన్ చేయండి.'
              : 'Exact alarms need a special permission.\n'
                  'Open Settings → Apps → Special app access →'
                  ' Alarms & reminders and enable Panchangam.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) context.pop();
            },
            child: Text(isTelugu ? 'తర్వాత' : 'Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              NotificationService.instance.openAlarmSettings();
              if (mounted) context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.kGold),
            child: Text(isTelugu ? 'సెట్టింగ్స్ తెరవు' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final isTelugu = S.isTelugu;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTelugu ? 'తొలగించాలా?' : 'Delete event?'),
        content: Text(
          isTelugu
              ? 'ఈ సందర్భాన్ని శాశ్వతంగా తొలగిస్తారు.'
              : 'This event will be permanently removed.',
        ),
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
      await ref.read(userEventProvider.notifier).delete(_original!.id);
      if (mounted) context.pop();
    }
  }
}

// ── Reminder row ───────────────────────────────────────────────────────────────

class _ReminderRow extends StatelessWidget {
  final int? reminderHour;
  final int reminderMinute;
  final int reminderDaysBefore;
  final ReminderType reminderType;
  final List<int> daysBeforeOptions;
  final bool isTelugu;
  final ColorScheme cs;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<ReminderType> onTypeChanged;

  const _ReminderRow({
    required this.reminderHour,
    required this.reminderMinute,
    required this.reminderDaysBefore,
    required this.reminderType,
    required this.daysBeforeOptions,
    required this.isTelugu,
    required this.cs,
    required this.onToggle,
    required this.onPickTime,
    required this.onDaysChanged,
    required this.onTypeChanged,
  });

  String _formatTime() {
    final period = reminderHour! < 12
        ? (isTelugu ? 'AM' : 'AM')
        : (isTelugu ? 'PM' : 'PM');
    final h = reminderHour! % 12 == 0 ? 12 : reminderHour! % 12;
    final m = reminderMinute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String _daysLabel(int days) {
    if (days == 0) return isTelugu ? 'అదే రోజు' : 'Same day';
    if (days == 1) return isTelugu ? '1 రోజు ముందు' : '1 day before';
    if (days == 7) return isTelugu ? '1 వారం ముందు' : '1 week before';
    return isTelugu ? '$days రోజులు ముందు' : '$days days before';
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
          // Toggle row
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(isTelugu ? 'రిమైండర్ సెట్ చేయి' : 'Set reminder'),
            value: enabled,
            activeColor: AppTheme.kGold,
            onChanged: onToggle,
          ),

          if (enabled) ...[
            const Divider(height: 1),
            // Reminder vs Alarm selector
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
                  selectedBackgroundColor: AppTheme.kGold.withValues(alpha: 0.15),
                  selectedForegroundColor: AppTheme.kGold,
                ),
              ),
            ),
            const Divider(height: 1),
            // Time + days before row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Time picker button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_formatTime()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Days before dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: reminderDaysBefore,
                      borderRadius: BorderRadius.circular(10),
                      items: daysBeforeOptions
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(_daysLabel(d)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onDaysChanged(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Tithi picker ───────────────────────────────────────────────────────────────

class _TithiPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TithiPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTelugu = S.isTelugu;

    return DropdownButtonFormField<int>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: List.generate(30, (i) {
        final tithi = i + 1;
        final paksha = tithi <= 15
            ? (isTelugu ? 'శు' : 'S')
            : (isTelugu ? 'కృ' : 'K');
        final name = isTelugu ? Tithi.namesTe[i] : Tithi.namesEn[i];
        return DropdownMenuItem(
          value: tithi,
          child: Text('$tithi · $paksha · $name',
              overflow: TextOverflow.ellipsis),
        );
      }),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ── Month picker ───────────────────────────────────────────────────────────────

class _MonthPicker extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;

  const _MonthPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTelugu = S.isTelugu;

    return DropdownButtonFormField<int?>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(isTelugu
              ? 'ప్రతి పక్షం (నెల లేదు)'
              : 'Every paksha (no month)'),
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

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
