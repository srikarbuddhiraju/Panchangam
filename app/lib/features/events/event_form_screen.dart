import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../core/utils/app_strings.dart';
import 'user_tithi_event.dart';
import 'user_event_provider.dart';

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

  late int _tithi;
  int? _teluguMonth;     // null = every paksha
  int? _reminderMinutes; // null = no reminder

  bool _isEditing = false;
  bool _saving = false;
  UserTithiEvent? _original;

  // Available reminder options: null = off, values in minutes.
  static const _reminderOptions = [null, 30, 60, 120, 360, 720, 1440];

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
        _tithi = _original!.tithi;
        _teluguMonth = _original!.teluguMonth;
        _reminderMinutes = _original!.reminderMinutes;
      }
    }
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameTeCtrl.dispose();
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
                hintText: isTelugu
                    ? 'ఉదా. Guru Jayanti'
                    : 'e.g. Guru Jayanti',
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

            // ── Reminder picker ────────────────────────────────────────────
            _SectionLabel(
              label: isTelugu ? 'రిమైండర్' : 'Reminder',
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: _reminderMinutes,
                  items: _reminderOptions.map((mins) {
                    return DropdownMenuItem<int?>(
                      value: mins,
                      child: Text(_reminderLabel(mins, isTelugu)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _reminderMinutes = v),
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

  String _reminderLabel(int? mins, bool isTelugu) {
    if (mins == null) return isTelugu ? 'రిమైండర్ లేదు' : 'No reminder';
    if (mins < 60) return isTelugu ? '$mins నిమిషాలు ముందు' : '$mins min before';
    final hours = mins ~/ 60;
    if (hours == 1) return isTelugu ? '1 గంట ముందు' : '1 hour before';
    if (hours == 24) return isTelugu ? '1 రోజు ముందు' : '1 day before';
    return isTelugu ? '$hours గంటలు ముందు' : '$hours hours before';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notifier = ref.read(userEventProvider.notifier);
    final nameEn = _nameEnCtrl.text.trim();
    final nameTe =
        _nameTeCtrl.text.trim().isEmpty ? null : _nameTeCtrl.text.trim();

    try {
      if (_isEditing && _original != null) {
        await notifier.update(_original!.copyWith(
          nameEn: nameEn,
          nameTe: nameTe,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderMinutes: _reminderMinutes,
        ));
      } else {
        await notifier.add(
          nameEn: nameEn,
          nameTe: nameTe,
          tithi: _tithi,
          teluguMonth: _teluguMonth,
          reminderMinutes: _reminderMinutes,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
