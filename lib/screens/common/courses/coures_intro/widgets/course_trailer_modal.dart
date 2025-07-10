import 'package:brainboosters_app/screens/common/widgets/common_video_player.dart';
import 'package:flutter/material.dart';

class CourseTrailerModal extends StatelessWidget {
  final String trailerUrl;
  final String courseTitle;
  final bool isEmbedded;
  final VoidCallback? onClose;

  const CourseTrailerModal({
    super.key,
    required this.trailerUrl,
    required this.courseTitle,
    this.isEmbedded = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmbedded) {
      return _buildEmbeddedPlayer();
    } else {
      return _buildDialogPlayer(context);
    }
  }

  Widget _buildEmbeddedPlayer() {
    return Stack(
      children: [
        // Use CommonVideoPlayer instead of custom implementation
        Positioned.fill(
          child: CommonVideoPlayer(
            videoUrl: trailerUrl,
            startPosition: Duration.zero,
            // No progress tracking needed for trailers
            onProgress: null,
            onCompleted: null,
            isLoading: false,
          ),
        ),

        // Close button for embedded mode
        if (onClose != null)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDialogPlayer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth <= 768;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        width: isMobile ? screenWidth : screenWidth * 0.8,
        height: isMobile ? screenHeight * 0.6 : screenHeight * 0.7,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trailer: $courseTitle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Video player using CommonVideoPlayer
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: CommonVideoPlayer(
                  videoUrl: trailerUrl,
                  startPosition: Duration.zero,
                  // No progress tracking needed for trailers
                  onProgress: null,
                  onCompleted: null,
                  isLoading: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
