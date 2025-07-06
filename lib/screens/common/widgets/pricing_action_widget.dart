// screens/widgets/common/pricing_action_widget.dart
import 'package:flutter/material.dart';

class PricingActionWidget extends StatelessWidget {
  final String price;
  final String? originalPrice;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onPressed; // Made nullable for loading state
  final bool isMobile;
  final bool isLoading; // Added missing parameter
  final Widget? loadingWidget; // Custom loading widget
  final String? discountPercentage; // Added discount percentage
  
  const PricingActionWidget({
    super.key,
    required this.price,
    this.originalPrice,
    required this.buttonText,
    required this.buttonColor,
    this.onPressed,
    required this.isMobile,
    this.isLoading = false, // Default to false
    this.loadingWidget,
    this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileActions();
    } else {
      return _buildDesktopActions();
    }
  }

  Widget _buildMobileActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price with discount badge
        _buildPriceSection(isMobile: true),
        const SizedBox(height: 16),
        
        // Button with loading state
        _buildActionButton(isMobile: true),
      ],
    );
  }

  Widget _buildDesktopActions() {
    return Row(
      children: [
        // Button with loading state
        _buildActionButton(isMobile: false),
        const SizedBox(width: 20),
        
        // Price with discount badge
        _buildPriceSection(isMobile: false),
      ],
    );
  }

  Widget _buildPriceSection({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (originalPrice != null) ...[
              const SizedBox(width: 8),
              Text(
                originalPrice!,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            if (discountPercentage != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (originalPrice != null) ...[
          const SizedBox(height: 4),
          Text(
            'Save ${_calculateSavings()}',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({required bool isMobile}) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey[400] : buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : 24,
            vertical: isMobile ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isLoading ? 0 : 2,
        ),
        child: isLoading
            ? _buildLoadingContent(isMobile)
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingContent(bool isMobile) {
    return loadingWidget ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isMobile ? 16 : 14,
              height: isMobile ? 16 : 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: isMobile ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
  }

  String _calculateSavings() {
    if (originalPrice == null) return '';
    
    try {
      // Extract numeric values from price strings
      final currentPrice = double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
      final originalPriceValue = double.parse(originalPrice!.replaceAll(RegExp(r'[^\d.]'), ''));
      final savings = originalPriceValue - currentPrice;
      
      return '₹${savings.toStringAsFixed(0)}';
    } catch (e) {
      return '';
    }
  }
}
