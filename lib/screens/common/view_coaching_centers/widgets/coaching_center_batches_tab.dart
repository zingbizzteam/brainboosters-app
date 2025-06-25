// screens/common/coaching_centers/widgets/coaching_center_batches_tab.dart
import 'package:flutter/material.dart';
import '../models/coaching_center_model.dart';

class CoachingCenterBatchesTab extends StatelessWidget {
  final CoachingCenter center;
  final bool isMobile;

  const CoachingCenterBatchesTab({
    super.key,
    required this.center,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Batches',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          if (center.batches.isEmpty)
            const Center(
              child: Text(
                'No batches available at the moment.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...center.batches.map((batch) => _buildBatchCard(batch)),
        ],
      ),
    );
  }

  Widget _buildBatchCard(CoachingCenterBatch batch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  batch.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: batch.hasAvailableSeats ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  batch.hasAvailableSeats ? 'Available' : 'Full',
                  style: TextStyle(
                    fontSize: 12,
                    color: batch.hasAvailableSeats ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBatchDetail('Course', batch.course),
          _buildBatchDetail('Timing', batch.timing),
          _buildBatchDetail('Instructor', batch.instructor),
          _buildBatchDetail('Capacity', '${batch.currentStudents}/${batch.maxCapacity}'),
          _buildBatchDetail('Fees', '₹${batch.fees.toStringAsFixed(0)}'),
          _buildBatchDetail('Mode', batch.mode),
        ],
      ),
    );
  }

  Widget _buildBatchDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
