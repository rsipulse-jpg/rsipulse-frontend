// lib/widgets/candidate_card.dart
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback? onCopy;

  const CandidateCard({super.key, required this.candidate, this.onCopy});

  Color _rsiColor(BuildContext ctx, double rsi) {
    final cs = Theme.of(ctx).colorScheme;
    if (rsi < 25) return successColor(ctx);
    if (rsi < 30) return cs.primary;
    if (rsi < 40) return cs.tertiary;
    return cs.secondary;
  }

  String _shortSymbol(String s) {
    if (!s.contains('/')) {
      final up = s.toUpperCase();
      if (up.endsWith('USDT')) return '${s.substring(0, s.length - 4)}/USDT';
      if (up.endsWith('USDC')) return '${s.substring(0, s.length - 4)}/USDC';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = _shortSymbol(candidate.symbol);
    final price = candidate.price != null ? candidate.price!.toStringAsFixed(4) : '—';
    final rsiStr = candidate.rsi.toStringAsFixed(1);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onLongPress: onCopy,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(sym, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              _RsiBadge(value: rsiStr, color: _rsiColor(context, candidate.rsi)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('Price', style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(width: 8),
              Text(price, style: theme.textTheme.bodyMedium),
              const Spacer(),
              if (candidate.time != null)
                Text(_fmtTime(candidate.time!), style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
            ]),
            const SizedBox(height: 10),
            if (candidate.flags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.flags.map((f) => _FlagChip(text: _humanizeFlag(f))).toList(),
              ),
          ]),
        ),
      ),
    );
  }

  String _humanizeFlag(String f) {
    switch (f) {
      case 'panic_dump':
        return 'Panic dump';
      case 'turning_up':
        return 'RSI turning up';
      case 'volume_spike':
        return 'Vol↑ spike';
      default:
        return f.replaceAll('_', ' ');
    }
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _RsiBadge extends StatelessWidget {
  final String value;
  final Color color;
  const _RsiBadge({required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.speed, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text('RSI $value', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
      ]),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String text;
  const _FlagChip({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceVariant.withOpacity(0.9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.local_fire_department, size: 14),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.labelLarge),
      ]),
    );
  }
}
