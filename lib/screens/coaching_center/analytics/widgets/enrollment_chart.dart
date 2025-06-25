// screens/coaching_center/analytics/widgets/enrollment_chart.dart
import 'package:flutter/material.dart';

class EnrollmentChart extends StatelessWidget {
  final Map<String, int> monthlyData;

  const EnrollmentChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final maxValue = monthlyData.values.isEmpty ? 1 : monthlyData.values.reduce((a, b) => a > b ? a : b);
    final entries = monthlyData.entries.toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF00B894)),
                const SizedBox(width: 8),
                const Text(
                  'Monthly Enrollments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Last 6 months',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF00B894),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (entries.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No enrollment data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: entries.map((entry) {
                    final percentage = entry.value / maxValue;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 150 * percentage,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B894),
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    const Color(0xFF00B894),
                                    const Color(0xFF00B894).withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Active', const Color(0xFF00B894)),
                _buildLegendItem('Completed', Colors.blue),
                _buildLegendItem('Dropped', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
