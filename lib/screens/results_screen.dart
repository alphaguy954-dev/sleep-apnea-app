import 'package:flutter/material.dart';
import '../models/session_result.dart';
import '../theme/app_theme.dart';
import '../widgets/timeline_chart.dart';
import 'qa_screen.dart';
import 'pdf_screen.dart';

class ResultsScreen extends StatelessWidget {
  final SessionResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final riskColor = AppTheme.getRiskColor(result.riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PdfScreen(result: result)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Risk Banner ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [riskColor, riskColor.withOpacity(0.75)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(_riskIcon(result.riskLevel), color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    '${result.riskLevel} Risk',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'AHI: ${result.ahiEstimate} events/hr  ·  ${result.ahiCategory}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recording: ${result.totalDuration}',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Metric Cards ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Avg SpO2',
                    value: '${result.meanSpo2}%',
                    sub: 'Min: ${result.minSpo2}%',
                    color: result.minSpo2 < 90
                        ? AppTheme.riskHigh
                        : AppTheme.riskLow,
                    icon: Icons.water_drop_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Avg HR',
                    value: '${result.meanHr} bpm',
                    sub: 'Beats per minute',
                    color: AppTheme.primary,
                    icon: Icons.favorite_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'SpO2 < 90%',
                    value: '${result.minutesBelow90} min',
                    sub: 'Desaturation time',
                    color: result.minutesBelow90 > 5
                        ? AppTheme.riskHigh
                        : AppTheme.riskLow,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Apnea Events',
                    value: '${result.apneaWindows}',
                    sub: 'Flagged minutes',
                    color: AppTheme.riskModerate,
                    icon: Icons.air,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'RMSSD',
                    value: '${result.meanRmssd} ms',
                    sub: 'HRV metric',
                    color: const Color(0xFF6A1B9A),
                    icon: Icons.show_chart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Longest Apnea',
                    value: '${result.maxConsecutiveApnea} min',
                    sub: 'Consecutive events',
                    color: result.maxConsecutiveApnea > 5
                        ? AppTheme.riskHigh
                        : AppTheme.riskModerate,
                    icon: Icons.timer_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Night Timeline ─────────────────────────────
            _SectionCard(
              title: 'Night Overview',
              child: NightTimelineChart(result: result),
            ),

            const SizedBox(height: 16),

            // ── Recommendations ────────────────────────────
            _SectionCard(
              title: 'Recommendations',
              child: _RecommendationList(riskLevel: result.riskLevel),
            ),

            const SizedBox(height: 16),

            // ── Disclaimer ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                '⚕️ This is a screening tool, not a medical diagnosis. '
                'Please consult a certified sleep specialist for a formal evaluation.',
                style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Buttons ─────────────────────────────
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QAScreen(result: result)),
              ),
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('Ask AI Assistant'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PdfScreen(result: result)),
              ),
              icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
              label: const Text('Export PDF Report',
                  style: TextStyle(color: AppTheme.primary)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  IconData _riskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':      return Icons.check_circle_rounded;
      case 'moderate': return Icons.warning_amber_rounded;
      case 'high':     return Icons.dangerous_rounded;
      case 'severe':   return Icons.emergency_rounded;
      default:         return Icons.help_rounded;
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, sub;
  final Color  color;
  final IconData icon;
  const _MetricCard({
    required this.label, required this.value,
    required this.sub,   required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 11,
                        color: AppTheme.textSecond,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecond)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}

class _RecommendationList extends StatelessWidget {
  final String riskLevel;
  const _RecommendationList({required this.riskLevel});

  List<Map<String, dynamic>> get _items {
    final base = [
      {'icon': Icons.airline_seat_flat, 'text': 'Sleep on your side — back sleeping worsens apnea'},
      {'icon': Icons.no_drinks,          'text': 'Avoid alcohol and sedatives before bedtime'},
      {'icon': Icons.bedtime,            'text': 'Maintain a consistent sleep schedule'},
      {'icon': Icons.fitness_center,     'text': 'Regular exercise improves sleep quality'},
    ];
    if (riskLevel == 'Moderate' || riskLevel == 'High' || riskLevel == 'Severe') {
      base.add({'icon': Icons.local_hospital,
        'text': 'Consult a sleep specialist for a formal PSG test'});
    }
    if (riskLevel == 'High' || riskLevel == 'Severe') {
      base.add({'icon': Icons.emergency,
        'text': 'Seek prompt medical evaluation — severe apnea poses serious health risks'});
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item['icon'] as IconData, size: 18, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item['text'] as String,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
