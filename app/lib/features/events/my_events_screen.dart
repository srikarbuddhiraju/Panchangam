import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../core/utils/app_strings.dart';
import '../../core/calculations/tithi.dart';
import '../../core/calculations/telugu_calendar.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import 'user_tithi_event.dart';
import 'user_event_provider.dart';
import 'user_todo.dart';
import 'user_todo_provider.dart';

/// Lists personal tithi events and To-Dos in two tabs.
/// [initialTab] selects which tab opens first: 0 = Events, 1 = To-Dos.
class MyEventsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const MyEventsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(() => setState(() {})); // update FAB on tab change
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isTelugu = S.isTelugu;

    final cs = Theme.of(context).colorScheme;

    // Not signed in — show prompt without tabs
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isTelugu ? 'నా సందర్భాలు' : 'My Events'),
        ),
        body: _SignInPrompt(isTelugu: isTelugu),
      );
    }

    final eventCount = ref.watch(userEventProvider).length;
    final todoCount = ref.watch(userTodoProvider
        .select((t) => t.where((x) => !x.isCompleted).length));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTelugu ? 'నా సందర్భాలు' : 'My Events',
              style: GoogleFonts.notoSansTelugu(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            Text(
              isTelugu
                  ? '$eventCount సందర్భాలు · $todoCount పెండింగ్'
                  : '$eventCount event${eventCount == 1 ? '' : 's'} · '
                    '$todoCount pending',
              style: GoogleFonts.notoSansTelugu(
                fontSize: 12,
                color: cs.onPrimaryContainer.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.kGold,
          indicatorWeight: 3,
          labelColor: cs.onPrimaryContainer,
          unselectedLabelColor: cs.onPrimaryContainer.withValues(alpha: 0.55),
          labelStyle: GoogleFonts.notoSansTelugu(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansTelugu(fontSize: 14),
          tabs: [
            Tab(text: isTelugu ? 'సందర్భాలు' : 'Events'),
            Tab(text: isTelugu ? 'టు-డూలు' : 'To-Dos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EventsTab(isTelugu: isTelugu),
          _TodosTab(isTelugu: isTelugu),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabController.index == 0
            ? context.push('/events/new')
            : context.push('/todos/new'),
        backgroundColor: AppTheme.kGold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0
            ? (isTelugu ? 'కొత్తది' : 'New Event')
            : (isTelugu ? 'కొత్త టు-డూ' : 'New To-Do')),
      ),
    );
  }
}

// ── Sign-in prompt ─────────────────────────────────────────────────────────────

class _SignInPrompt extends StatelessWidget {
  final bool isTelugu;
  const _SignInPrompt({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 88,
                height: 88,
                color: const Color(0xFF0B1437),
                child: Image.asset('assets/icon_fg.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 20),
            Text(isTelugu ? 'సైన్ ఇన్ అవసరం' : 'Sign in required',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              isTelugu
                  ? 'మీ వ్యక్తిగత సందర్భాలు మరియు రిమైండర్‌లను సేవ్ చేయడానికి సైన్ ఇన్ చేయండి.'
                  : 'Sign in to save your personal events and reminders.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: LoginScreen(
                        onSuccess: () => Navigator.of(context).pop()),
                  ),
                ),
              ),
              icon: const Icon(Icons.login),
              label: Text(isTelugu ? 'సైన్ ఇన్ చేయండి' : 'Sign in'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.kGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Events tab ────────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  final bool isTelugu;
  const _EventsTab({required this.isTelugu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(userEventProvider);
    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_add_outlined,
        message: isTelugu ? 'ఇంకా సందర్భాలు లేవు' : 'No events yet',
        hint: isTelugu
            ? 'గురువు పుట్టినరోజు, వర్ధంతి, కుటుంబ సందర్భాలను జోడించండి'
            : 'Add birthdays, anniversaries, and family occasions',
      );
    }
    final sorted = [
      ...events.where((e) => e.isActive),
      ...events.where((e) => !e.isActive),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: sorted.length,
      separatorBuilder: (_, idx) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _EventTile(event: sorted[i]),
    );
  }
}

class _EventTile extends ConsumerStatefulWidget {
  final UserTithiEvent event;
  const _EventTile({required this.event});

  @override
  ConsumerState<_EventTile> createState() => _EventTileState();
}

class _EventTileState extends ConsumerState<_EventTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTelugu = S.isTelugu;
    final notifier = ref.read(userEventProvider.notifier);
    final event = widget.event;

    final String name =
        isTelugu && event.nameTe != null ? event.nameTe! : event.nameEn;
    final bool hasNotes = event.notes != null && event.notes!.isNotEmpty;

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context, isTelugu),
      onDismissed: (_) => notifier.delete(event.id),
      child: GestureDetector(
        onTap: hasNotes ? () => setState(() => _expanded = !_expanded) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: event.isActive
                  ? AppTheme.kGold.withValues(alpha: 0.35)
                  : cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: event.isActive
                          ? AppTheme.kGold
                          : cs.onSurfaceVariant.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: event.isActive
                                      ? null
                                      : cs.onSurfaceVariant,
                                )),
                        const SizedBox(height: 2),
                        Text(
                          '${_tithiLabel(event.tithi, isTelugu)} · ${_monthLabel(event.teluguMonth, isTelugu)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        if (_reminderLabel(event, isTelugu).isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(_reminderLabel(event, isTelugu),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                  if (hasNotes)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  Switch(
                    value: event.isActive,
                    onChanged: (_) => notifier.toggleActive(event.id),
                    activeThumbColor: AppTheme.kGold,
                    activeTrackColor: AppTheme.kGold.withValues(alpha: 0.4),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => context.push('/events/${event.id}'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (hasNotes && _expanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(event.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant, height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, bool isTelugu) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isTelugu ? 'తొలగించాలా?' : 'Delete event?'),
          content: Text(isTelugu
              ? 'ఈ సందర్భాన్ని శాశ్వతంగా తొలగిస్తారు.'
              : 'This event will be permanently removed.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(isTelugu ? 'రద్దు' : 'Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style:
                    FilledButton.styleFrom(backgroundColor: Colors.red),
                child: Text(isTelugu ? 'తొలగించు' : 'Delete')),
          ],
        ),
      );

  String _tithiLabel(int tithi, bool isTelugu) {
    final name =
        isTelugu ? Tithi.namesTe[tithi - 1] : Tithi.namesEn[tithi - 1];
    final paksha = tithi <= 15
        ? (isTelugu ? 'శు.పక్ష' : 'Shukla')
        : (isTelugu ? 'కృ.పక్ష' : 'Krishna');
    return '$paksha $name';
  }

  String _monthLabel(int? month, bool isTelugu) {
    if (month == null) return isTelugu ? 'ప్రతి పక్షం' : 'Every paksha';
    return isTelugu
        ? TeluguCalendar.monthNamesTe[month - 1]
        : TeluguCalendar.monthNamesEn[month - 1];
  }

  String _reminderLabel(UserTithiEvent event, bool isTelugu) {
    if (event.reminderHour == null) return '';
    final h =
        event.reminderHour! % 12 == 0 ? 12 : event.reminderHour! % 12;
    final m = event.reminderMinute.toString().padLeft(2, '0');
    final period = event.reminderHour! < 12 ? 'AM' : 'PM';
    final when = switch (event.reminderDaysBefore) {
      0 => isTelugu ? 'అదే రోజు' : 'same day',
      1 => isTelugu ? '1 రోజు ముందు' : '1 day before',
      7 => isTelugu ? '1 వారం ముందు' : '1 week before',
      _ => isTelugu
          ? '${event.reminderDaysBefore} రోజులు ముందు'
          : '${event.reminderDaysBefore} days before',
    };
    final icon =
        event.reminderType == ReminderType.alarm ? '⏰' : '🔔';
    return '$icon $h:$m $period · $when';
  }
}

// ── To-Dos tab ────────────────────────────────────────────────────────────────

class _TodosTab extends ConsumerWidget {
  final bool isTelugu;
  const _TodosTab({required this.isTelugu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userTodoProvider.notifier);
    final pending = ref.watch(userTodoProvider.select(
      (todos) => todos.where((t) => t.isActive && !t.isCompleted).toList(),
    ));
    final archived = ref.watch(userTodoProvider.select(
      (todos) => todos.where((t) => t.isActive && t.isCompleted).toList(),
    ));

    if (pending.isEmpty && archived.isEmpty) {
      return _EmptyState(
        icon: Icons.check_box_outline_blank,
        message: isTelugu ? 'ఇంకా టు-డూలు లేవు' : 'No To-Dos yet',
        hint: isTelugu
            ? 'ఏకాదశిన దానం చేయాలి, పండుగ రోజు దేవాలయానికి వెళ్ళాలి — ఏదైనా పని జోడించండి'
            : 'Donate on Ekadashi, visit temple on Panchami — add any one-time task',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (pending.isNotEmpty) ...[
          ...pending.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TodoTile(
                    todo: t, notifier: notifier, isTelugu: isTelugu),
              )),
        ],
        if (archived.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            isTelugu ? 'పూర్తయినవి' : 'Completed',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          ...archived.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TodoTile(
                    todo: t, notifier: notifier, isTelugu: isTelugu),
              )),
        ],
      ],
    );
  }
}

class _TodoTile extends StatefulWidget {
  final UserTodo todo;
  final UserTodoNotifier notifier;
  final bool isTelugu;
  const _TodoTile(
      {required this.todo,
      required this.notifier,
      required this.isTelugu});

  @override
  State<_TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<_TodoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final todo = widget.todo;
    final isTelugu = widget.isTelugu;
    final hasNotes = todo.notes != null && todo.notes!.isNotEmpty;

    final dateStr = isTelugu
        ? '${todo.targetDate.day}/${todo.targetDate.month}/${todo.targetDate.year}'
        : DateFormat('d MMM y').format(todo.targetDate);

    final reminderStr = _reminderLabel(todo, isTelugu);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context, isTelugu),
      onDismissed: (_) => widget.notifier.delete(todo.id),
      child: GestureDetector(
        onTap: hasNotes ? () => setState(() => _expanded = !_expanded) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: todo.isCompleted
                  ? cs.outlineVariant.withValues(alpha: 0.4)
                  : AppTheme.kGold.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Completion checkbox
                  Checkbox(
                    value: todo.isCompleted,
                    activeColor: AppTheme.kGold,
                    onChanged: (_) => widget.notifier
                        .complete(todo.id, done: !todo.isCompleted),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: todo.isCompleted
                                    ? cs.onSurfaceVariant
                                    : null,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        if (reminderStr.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            reminderStr,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasNotes)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  // Edit
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => context.push('/todos/${todo.id}'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (hasNotes && _expanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(
                  todo.notes!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: cs.onSurfaceVariant, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, bool isTelugu) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isTelugu ? 'తొలగించాలా?' : 'Delete To-Do?'),
          content: Text(isTelugu
              ? 'ఈ టు-డూని శాశ్వతంగా తొలగిస్తారు.'
              : 'This To-Do will be permanently removed.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(isTelugu ? 'రద్దు' : 'Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style:
                    FilledButton.styleFrom(backgroundColor: Colors.red),
                child: Text(isTelugu ? 'తొలగించు' : 'Delete')),
          ],
        ),
      );

  String _reminderLabel(UserTodo todo, bool isTelugu) {
    if (todo.reminderHour == null) return '';
    final h =
        todo.reminderHour! % 12 == 0 ? 12 : todo.reminderHour! % 12;
    final m = todo.reminderMinute.toString().padLeft(2, '0');
    final period = todo.reminderHour! < 12 ? 'AM' : 'PM';
    final icon =
        todo.reminderType == ReminderType.alarm ? '⏰' : '🔔';
    return '$icon $h:$m $period';
  }
}

// ── Shared empty state ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;
  const _EmptyState(
      {required this.icon, required this.message, required this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(message,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(hint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
