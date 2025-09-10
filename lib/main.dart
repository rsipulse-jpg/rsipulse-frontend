import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'models.dart';

void main() {
  runApp(const RSIPulseApp());
}

class RSIPulseApp extends StatelessWidget {
  const RSIPulseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSI Pulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum AppMode { free, premium }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool demo = false;
  AppMode mode = AppMode.free;
  bool loading = false;
  String lastTime = '';
  List<Candidate> candidates = [];

  @override
  void initState() {
    super.initState();
    _restorePrefs();
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      demo = sp.getBool('demo') ?? false;
      mode = (sp.getString('mode') ?? 'free') == 'premium' ? AppMode.premium : AppMode.free;
    });
  }

  Future<void> _persistPrefs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('demo', demo);
    await sp.setString('mode', mode == AppMode.premium ? 'premium' : 'free');
  }

  Future<void> _scanNow() async {
    setState(() => loading = true);
    try {
      final res = await Api.scan(
        mode: mode == AppMode.premium ? 'premium' : 'free',
        test: demo ? 1 : 0,
      );
      setState(() {
        lastTime = res.time;
        candidates = res.candidates;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      setState(() => loading = false);
      _persistPrefs();
    }
  }

  Widget _modeSelector() {
    return SegmentedButton<AppMode>(
      segments: const <ButtonSegment<AppMode>>[
        ButtonSegment<AppMode>(value: AppMode.free, label: Text('Free')),
        ButtonSegment<AppMode>(value: AppMode.premium, label: Text('Premium')),
      ],
      selected: <AppMode>{mode},
      onSelectionChanged: (newSel) {
        setState(() => mode = newSel.first);
        _persistPrefs();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSI Pulse'),
        actions: [
          Row(
            children: [
              const Text('Demo'),
              Switch(
                value: demo,
                onChanged: (v) {
                  setState(() => demo = v);
                  _persistPrefs();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _modeSelector(),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: loading ? null : _scanNow,
                  label: const Text('Scan Now'),
                ),
                const SizedBox(width: 12),
                if (loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),
            if (lastTime.isNotEmpty)
              Text('Last scan: $lastTime', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Expanded(
              child: candidates.isEmpty
                  ? const Center(child: Text('No candidates yet. Tap "Scan Now".'))
                  : ListView.separated(
                      itemCount: candidates.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) => _candidateCard(candidates[idx]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _candidateCard(Candidate c) {
    final isPanic = c.note == 'panic_dump';
    final isBasic = c.note == 'rsi_basic';
    final isRVE = c.note == 'rsi_vol_ema';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(c.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (isPanic) _badge('panic'),
                if (isRVE) const SizedBox(width: 6),
                if (isRVE) _badge('rsi·vol·ema'),
                if (isBasic) const SizedBox(width: 6),
                if (isBasic) _badge('rsi'),
              ],
            ),
            const SizedBox(height: 6),
            Text('RSI: ${c.rsi.toStringAsFixed(2)}   Price: ${c.price.toStringAsFixed(6)}'),
            const SizedBox(height: 4),
            Text('Vol: ${c.volLast.toStringAsFixed(0)}  vs avg20: ${c.volAvg20.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}