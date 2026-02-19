import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/session_result.dart';
import '../theme/app_theme.dart';

class NightTimelineChart extends StatefulWidget {
  final SessionResult result;
  const NightTimelineChart({super.key, required this.result});

  @override
  State<NightTimelineChart> createState() => _NightTimelineChartState();
}

class _NightTimelineChartState extends State<NightTimelineChart> {
  // 0 = SpO2,  1 = HR
  int _selectedChart = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle
        Row(
          children: [
            _ChartToggle(
              label: 'SpO2 %',
              selected: _selectedChart == 0,
              color: AppTheme.chartSpo2,
              onTap: () => setState(() => _selectedChart = 0),
            ),
            const SizedBox(width: 10),
            _ChartToggle(
              label: 'Heart Rate',
              selected: _selectedChart == 1,
              color: AppTheme.chartNormal,
              onTap: () => setState(() => _selectedChart = 1),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Chart
        SizedBox(
          height: 200,
          child: _selectedChart == 0
              ? _buildSpO2Chart()
              : _buildHRChart(),
        ),

        const SizedBox(height: 16),

        // Apnea event bar (minute-by-minute)
        const Text('Apnea Events Timeline',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        _ApneaTimeline(predictions: widget.result.minutePredictions),
        const SizedBox(height: 6),
        Row(
          children: [
            _LegendDot(color: AppTheme.chartNormal, label: 'Normal'),
            const SizedBox(width: 16),
            _LegendDot(color: AppTheme.chartApnea, label: 'Apnea Event'),
          ],
        ),
      ],
    );
  }

  Widget _buildSpO2Chart() {
    final values = widget.result.spo2Values;
    final preds  = widget.result.minutePredictions;

    final spots = values.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        minY: (values.reduce((a, b) => a < b ? a : b) - 2).clamp(70, 100),
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}%', style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (values.length / 4).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final hrs = v.toInt() ~/ 60;
                final min = v.toInt() % 60;
                return Text('${hrs}h${min.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 9));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.chartSpo2,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.chartSpo2.withOpacity(0.1),
            ),
          ),
        ],
        // Red threshold line at 90%
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 90,
              color: Colors.red.withOpacity(0.5),
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'SpO2 90%',
                style: const TextStyle(fontSize: 10, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHRChart() {
    final values = widget.result.hrValues;

    final spots = values.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        minY: (values.reduce((a, b) => a < b ? a : b) - 5).clamp(40, 200),
        maxY: values.reduce((a, b) => a > b ? a : b) + 5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (values.length / 4).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final hrs = v.toInt() ~/ 60;
                final min = v.toInt() % 60;
                return Text('${hrs}h${min.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 9));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.chartNormal,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.chartNormal.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// Minute-by-minute apnea event bar
class _ApneaTimeline extends StatelessWidget {
  final List<int> predictions;
  const _ApneaTimeline({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total  = predictions.length;
        final width  = constraints.maxWidth;
        final pixPer = width / total;

        return SizedBox(
          height: 28,
          child: CustomPaint(
            size: Size(width, 28),
            painter: _TimelinePainter(predictions, pixPer),
          ),
        );
      },
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final List<int> predictions;
  final double pixPerMinute;

  _TimelinePainter(this.predictions, this.pixPerMinute);

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()..color = AppTheme.chartNormal.withOpacity(0.4);
    final apneaPaint  = Paint()..color = AppTheme.chartApnea;
    final bgPaint     = Paint()..color = Colors.grey.shade200;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ),
      bgPaint,
    );

    for (int i = 0; i < predictions.length; i++) {
      final x = i * pixPerMinute;
      final paint = predictions[i] == 1 ? apneaPaint : normalPaint;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, pixPerMinute.clamp(1, 8), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ChartToggle extends StatelessWidget {
  final String label;
  final bool   selected;
  final Color  color;
  final VoidCallback onTap;
  const _ChartToggle({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecond,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecond)),
      ],
    );
  }
}
