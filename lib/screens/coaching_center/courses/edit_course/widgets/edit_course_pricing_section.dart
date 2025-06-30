import 'package:flutter/material.dart';

class EditCoursePricingSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController maxEnrollmentsController;
  final bool isFree;
  final Function(bool) onFreeChanged;
  final BoxConstraints constraints;

  const EditCoursePricingSection({
    super.key,
    required this.priceController,
    required this.originalPriceController,
    required this.maxEnrollmentsController,
    required this.isFree,
    required this.onFreeChanged,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.attach_money, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pricing & Enrollment',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: constraints.maxWidth > 600 ? 24 : 20),
            
            // Free Course Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFree ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFree ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: SwitchListTile(
                title: const Text('Free Course', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Make this course available for free'),
                value: isFree,
                onChanged: onFreeChanged,
                activeColor: const Color(0xFF00B894),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            if (!isFree) ...[
              SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
              
              if (constraints.maxWidth > 600)
                Row(
                  children: [
                    Expanded(child: _buildPriceField()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildOriginalPriceField()),
                  ],
                )
              else ...[
                _buildPriceField(),
                const SizedBox(height: 16),
                _buildOriginalPriceField(),
              ],
              
              // Discount Display
              if (priceController.text.isNotEmpty && originalPriceController.text.isNotEmpty)
                _buildDiscountDisplay(),
            ],
            
            SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
            _buildMaxEnrollmentsField(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Price (₹) *',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
          validator: (value) {
            if (!isFree && (value == null || value.trim().isEmpty)) {
              return 'Price is required for paid courses';
            }
            if (!isFree && double.tryParse(value!) == null) {
              return 'Enter a valid price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOriginalPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Original Price (₹)',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: originalPriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'For discount display',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final originalPrice = double.tryParse(value);
              final currentPrice = double.tryParse(priceController.text);
              
              if (originalPrice == null) {
                return 'Enter a valid original price';
              }
              
              if (currentPrice != null && originalPrice <= currentPrice) {
                return 'Original price should be higher than current price';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMaxEnrollmentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Enrollments',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: maxEnrollmentsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Leave empty for unlimited',
            suffixText: 'students',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B894), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 16 : 12,
              vertical: constraints.maxWidth > 600 ? 16 : 12,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final maxEnrollments = int.tryParse(value);
              if (maxEnrollments == null || maxEnrollments <= 0) {
                return 'Enter a valid number';
              }
              if (maxEnrollments > 10000) {
                return 'Maximum enrollments cannot exceed 10,000';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDiscountDisplay() {
    final currentPrice = double.tryParse(priceController.text);
    final originalPrice = double.tryParse(originalPriceController.text);
    
    if (currentPrice != null && originalPrice != null && originalPrice > currentPrice) {
      final discount = ((originalPrice - currentPrice) / originalPrice * 100).round();
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Discount: $discount% OFF',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Save ₹${(originalPrice - currentPrice).toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
