// lib/models/candidate.dart
class Candidate {
  final String symbol;      // "SOLUSDT" or "SOL/USDT"
  final double rsi;         // required
  final double? price;      // optional
  final List<String> flags; // optional
  final DateTime? time;     // optional

  const Candidate({
    required this.symbol,
    required this.rsi,
    required this.price,
    required this.flags,
    required this.time,
  });

  factory Candidate.flex(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Candidate.fromJson(raw);
    }
    if (raw is List) {
      final sym = raw.isNotEmpty ? (raw[0]?.toString() ?? '') : '';
      final rsiVal = raw.length > 1 ? _toDouble(raw[1]) ?? 0.0 : 0.0;
      final priceVal = raw.length > 2 ? _toDouble(raw[2]) : null;

      List<String> flags = const [];
      if (raw.length > 3) {
        final f = raw[3];
        if (f is List) {
          flags = f.map((e) => e.toString()).toList();
        } else if (f is String) {
          flags = f.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }

      return Candidate(
        symbol: sym,
        rsi: rsiVal,
        price: priceVal,
        flags: flags,
        time: null,
      );
    }

    return const Candidate(symbol: '', rsi: 0.0, price: null, flags: [], time: null);
  }

  factory Candidate.fromJson(Map<String, dynamic> json) {
    final sym = (json['symbol'] ?? json['pair'] ?? json['ticker'] ?? '').toString();

    final rsiStr = (json['rsi'] ?? json['RSI'] ?? json['rsi6'] ?? json['rsi_6'] ?? json['rsi_value'] ?? 0).toString();
    final rsiVal = double.tryParse(rsiStr) ?? 0.0;

    final priceAny = json['price'] ?? json['last'] ?? json['close'] ?? json['lastPrice'];
    final priceNum = priceAny != null ? double.tryParse(priceAny.toString()) : null;

    List<String> flags = [];
    final f = json['flags'];
    if (f is List) {
      flags = f.map((e) => e.toString()).toList();
    } else if (f is String) {
      flags = f.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      for (final k in const ['panic_dump', 'turning_up', 'volume_spike']) {
        final v = json[k];
        if (v is bool && v) flags.add(k);
      }
    }

    DateTime? t;
    final rawT = json['time'] ?? json['updated_at'] ?? json['timestamp'];
    if (rawT != null) {
      try {
        t = DateTime.tryParse(rawT.toString())?.toLocal();
      } catch (_) {}
    }

    return Candidate(symbol: sym, rsi: rsiVal, price: priceNum, flags: flags, time: t);
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
