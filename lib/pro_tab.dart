// lib/pro_tab.dart
import 'package:flutter/material.dart';

class ProTabLocked extends StatelessWidget {
  const ProTabLocked({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 36, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Premium Features', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('Unlock advanced signals and more frequent scans.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _benefit('More scans per day'),
          _benefit('Extra signal types: panic dump, volume spikes'),
          _benefit('Early alerts & notifications'),
          _benefit('Priority backend window'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unlock flow coming soon')),
              );
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Unlock Pro'),
          ),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x08000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
