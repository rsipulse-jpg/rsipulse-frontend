// lib/free_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'models/candidate.dart';
import 'widgets/candidate_card.dart';

class FreeTab extends StatefulWidget {
  const FreeTab({super.key});
  @override
  State<FreeTab> createState() => _FreeTabState();
}

class _FreeTabState extends State<FreeTab> {
  final ApiClient _api = ApiClient();
  bool _isDemo = true;
  bool _restored = false;
  bool _loading = false;
  String? _error;
  DateTime? _lastScanAt;
  List<Candidate> _items = [];

  @override
  void initState() {
    super.initState();
    _restorePrefs().then((_) => _scan(initial: true));
  }

  Future<void> _restorePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDemo = prefs.getBool('demo_mode') ?? true;
    } catch (_) {}
    if (mounted) setState(() => _restored = true);
  }

  Future<void> _saveDemo(bool v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('demo_mode', v);
    } catch (_) {}
  }

  Future<void> _scan({bool initial = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.scan(demo: _isDemo);
      setState(() {
        _items = data;
        _lastScanAt = DateTime.now();
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() => _scan();

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSI Pulse — Free'),
        actions: [
          Row(children: [
            Text(_isDemo ? 'Demo' : 'Live'),
            Switch(
              value: _isDemo,
              onChanged: (v) async {
                setState(() => _isDemo = v);
                await _saveDemo(v);
                unawaited(_scan());
              },
            ),
          ]),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading
            ? null
            : () async {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Scanning…'),
                        duration: Duration(milliseconds: 800)),
                  );
                }
                await _scan();
              },
        icon: Icon(_loading ? Icons.hourglass_top : Icons.refresh),
        label: Text(_loading ? 'Scanning…' : 'Scan Now'),
      ),
      body: !_restored
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _onRefresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final last = _lastScanAt != null ? _fmt(_lastScanAt!) : '—';

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _pill(context, 'Last scan', last, Icons.access_time),
        ],
      ),
    );

    if (_loading && _items.isEmpty && _error == null) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          header,
          ...List.generate(6, (i) => const _SkeletonCard())
              .map((w) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: w,
                  )),
          const SizedBox(height: 120),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          header,
          _ErrorBox(message: 'Something went wrong.\n$_error', onRetry: _scan),
          const SizedBox(height: 120),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 8),
          _EmptyBox(title: 'No candidates', subtitle: 'Try “Scan Now” again in a bit.'),
          SizedBox(height: 120),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: _items.length + 1,
      separatorBuilder: (_, i) =>
          i == 0 ? const SizedBox.shrink() : const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i == 0) return header;
        final idx = i - 1;
        return CandidateCard(
          candidate: _items[idx],
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: _items[idx].symbol));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Copied'), duration: Duration(seconds: 1)));
          },
        );
      },
    );
  }
}

// Small pill helper (single full-width row, overflow-safe)
Widget _pill(BuildContext context, String label, String value, IconData icon) {
  final theme = Theme.of(context);
  final bg = theme.colorScheme.surfaceVariant.withOpacity(0.8);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.labelMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

// ===== helper widgets (top-level) =====

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceVariant.withOpacity(0.7);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            Container(
                width: 110,
                height: 16,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(4))),
            const Spacer(),
            Container(
                width: 60,
                height: 22,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(11))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 8),
            Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(4))),
            const Spacer(),
            Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(4))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(11))),
            const SizedBox(width: 8),
            Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(11))),
            const SizedBox(width: 8),
            Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                    color: base, borderRadius: BorderRadius.circular(11))),
          ]),
        ]),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorBox({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Error',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onErrorContainer)),
        const SizedBox(height: 8),
        Text(message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onErrorContainer)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
      ]),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyBox({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_outlined, size: 28, color: theme.hintColor),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.hintColor)),
        ]),
      ),
    );
  }
}
