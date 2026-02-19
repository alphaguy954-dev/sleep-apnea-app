import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.background],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────
              const SizedBox(height: 40),
              const Icon(Icons.bedtime, size: 72, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Sleep Apnea Screener',
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload overnight sleep data for AI-powered screening',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 48),

              // ── Cards ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _InfoCard(
                        icon: Icons.upload_file,
                        color: AppTheme.primary,
                        title: 'CSV Upload',
                        subtitle: 'Upload your overnight HR, SpO2 & HRV data',
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.timeline,
                        color: const Color(0xFF2E7D32),
                        title: 'Night Timeline',
                        subtitle: 'View minute-by-minute apnea event detection',
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.smart_toy_outlined,
                        color: const Color(0xFF6A1B9A),
                        title: 'AI Q&A Assistant',
                        subtitle: 'Ask questions about your results instantly',
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.picture_as_pdf,
                        color: const Color(0xFFD32F2F),
                        title: 'PDF Report',
                        subtitle: 'Export a doctor-ready report of your session',
                      ),
                      const SizedBox(height: 12),

                      // Disclaimer
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'This app is a screening tool only — not a medical diagnosis. '
                                'Always consult a certified sleep specialist.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Start button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UploadScreen()),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start Screening'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecond)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
