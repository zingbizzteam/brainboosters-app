import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CommonVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final Duration startPosition;
  final Function(Duration position, Duration duration)? onProgress;
  final VoidCallback? onCompleted;
  final bool isLoading;

  const CommonVideoPlayer({
    super.key,
    this.videoUrl,
    this.startPosition = Duration.zero,
    this.onProgress,
    this.onCompleted,
    this.isLoading = false,
  });

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayerState();
}

class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(CommonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _disposeControllers();
      if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _initializeVideo();
      } else {
        setState(() {
          _isInitialized = false;
          _error = null;
        });
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isInitialized = false;
        _error = null;
      });

      debugPrint('Initializing video: ${widget.videoUrl}');

      // Convert HTTP to HTTPS for better compatibility
      String secureUrl = widget.videoUrl!;
      if (secureUrl.startsWith('http://')) {
        secureUrl = secureUrl.replaceFirst('http://', 'https://');
        debugPrint('Converted to HTTPS: $secureUrl');
      }

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(secureUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoController!.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        startAt: widget.startPosition,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.blue[300]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
      );

      // Add progress listener for lesson tracking
      _videoController!.addListener(_onVideoProgress);

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Video initialization error: $e');
      setState(() {
        _error = e.toString();
        _isInitialized = false;
      });
    }
  }

  void _onVideoProgress() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    // Call progress callback for lesson tracking
    widget.onProgress?.call(position, duration);

    // Check if video completed
    if (position >= duration && duration > Duration.zero) {
      widget.onCompleted?.call();
    }
  }

  void _disposeControllers() {
    _videoController?.removeListener(_onVideoProgress);
    _chewieController?.dispose();
    _videoController?.dispose();
    _videoController = null;
    _chewieController = null;
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Video Error',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initializeVideo(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading state
    if (widget.isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading lesson...',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Handle no video URL
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_outlined, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text(
                'No video available',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'This lesson does not have a video',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Handle error state
    if (_error != null) {
      return _buildErrorWidget(_error!);
    }

    // Handle not initialized yet
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Please Wait...',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show video player
    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}
