class Candidate {
  final String time;
  final String symbol;
  final double rsi;
  final double price;
  final double volLast;
  final double volAvg20;
  final String note;

  Candidate({
    required this.time,
    required this.symbol,
    required this.rsi,
    required this.price,
    required this.volLast,
    required this.volAvg20,
    required this.note,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      time: json['time'] ?? '',
      symbol: json['symbol'] ?? '',
      rsi: (json['rsi'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      volLast: (json['vol_last'] as num).toDouble(),
      volAvg20: (json['vol_avg20'] as num).toDouble(),
      note: json['note'] ?? '',
    );
  }
}

class ScanResponse {
  final String time;
  final List<Candidate> candidates;

  ScanResponse({required this.time, required this.candidates});

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    final cands = (json['candidates'] as List<dynamic>)
        .map((e) => Candidate.fromJson(e as Map<String, dynamic>))
        .toList();
    return ScanResponse(time: json['time'] ?? '', candidates: cands);
  }
}