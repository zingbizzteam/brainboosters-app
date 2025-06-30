import 'package:flutter/material.dart';
import '../create_course_page.dart';

class CoursePricingSection extends StatefulWidget {
  final CourseFormData formData;

  const CoursePricingSection({super.key, required this.formData});

  @override
  State<CoursePricingSection> createState() => _CoursePricingSectionState();
}

class _CoursePricingSectionState extends State<CoursePricingSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing & Enrollment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Free Course Toggle
            SwitchListTile(
              title: const Text('Free Course'),
              subtitle: const Text('Make this course free for all students'),
              value: widget.formData.isFree,
              onChanged: (value) {
                setState(() {
                  widget.formData.isFree = value;
                  if (value) {
                    widget.formData.priceController.clear();
                    widget.formData.originalPriceController.clear();
                  }
                });
              },
              activeColor: const Color(0xFF00B894),
            ),
            
            if (!widget.formData.isFree) ...[
              const SizedBox(height: 16),
              
              // Course Price
              TextFormField(
                controller: widget.formData.priceController,
                decoration: const InputDecoration(
                  labelText: 'Course Price *',
                  hintText: 'Enter course price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                  suffixText: 'INR',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!widget.formData.isFree) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required for paid courses';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    if (price > 100000) {
                      return 'Price cannot exceed ₹1,00,000';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Original Price (for discounts)
              TextFormField(
                controller: widget.formData.originalPriceController,
                decoration: const InputDecoration(
                  labelText: 'Original Price (Optional)',
                  hintText: 'Enter original price for discount display',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                  suffixText: 'INR',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final originalPrice = double.tryParse(value);
                    final currentPrice = double.tryParse(widget.formData.priceController.text);
                    
                    if (originalPrice == null || originalPrice <= 0) {
                      return 'Enter a valid original price';
                    }
                    
                    if (currentPrice != null && originalPrice <= currentPrice) {
                      return 'Original price should be higher than current price';
                    }
                  }
                  return null;
                },
              ),
              
              // Discount Percentage Display
              if (widget.formData.priceController.text.isNotEmpty &&
                  widget.formData.originalPriceController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDiscountDisplay(),
              ],
            ],
            
            const SizedBox(height: 16),
            
            // Max Enrollments
            TextFormField(
              controller: widget.formData.maxEnrollmentsController,
              decoration: const InputDecoration(
                labelText: 'Maximum Enrollments (Optional)',
                hintText: 'Leave empty for unlimited enrollments',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
                suffixText: 'students',
              ),
              keyboardType: TextInputType.number,
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
        ),
      ),
    );
  }

  Widget _buildDiscountDisplay() {
    final currentPrice = double.tryParse(widget.formData.priceController.text);
    final originalPrice = double.tryParse(widget.formData.originalPriceController.text);
    
    if (currentPrice != null && originalPrice != null && originalPrice > currentPrice) {
      final discount = ((originalPrice - currentPrice) / originalPrice * 100).round();
      return Container(
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
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
