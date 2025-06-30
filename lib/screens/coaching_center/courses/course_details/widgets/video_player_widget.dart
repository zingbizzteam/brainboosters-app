import 'package:flutter/material.dart';
import 'package:awesome_video_player/awesome_video_player.dart';

class AwesomeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final List<AwesomeVideoPlayerSubtitlesSource>? subtitles;
  final Map<String, String>? httpHeaders;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double? aspectRatio;
  final BoxFit? fit;
  final Color? controlsColor;
  final Duration? startAt;
  final Function(AwesomeVideoPlayerController)? onControllerCreated;
  final Function()? onVideoReady;
  final Function()? onVideoCompleted;

  const AwesomeVideoWidget({
    Key? key,
    required this.videoUrl,
    this.title,
    this.subtitles,
    this.httpHeaders,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.aspectRatio,
    this.fit,
    this.controlsColor,
    this.startAt,
    this.onControllerCreated,
    this.onVideoReady,
    this.onVideoCompleted,
  }) : super(key: key);

  @override
  State<AwesomeVideoWidget> createState() => _AwesomeVideoWidgetState();
}

class _AwesomeVideoWidgetState extends State<AwesomeVideoWidget> {
  AwesomeVideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Create data source configuration
    AwesomeVideoPlayerDataSource dataSource;
    
    if (widget.videoUrl.startsWith('http')) {
      dataSource = AwesomeVideoPlayerDataSource(
        AwesomeVideoPlayerDataSourceType.network,
        widget.videoUrl,
        videoFormat: _getVideoFormat(widget.videoUrl),
        headers: widget.httpHeaders,
      );
    } else if (widget.videoUrl.startsWith('assets/')) {
      dataSource = AwesomeVideoPlayerDataSource(
        AwesomeVideoPlayerDataSourceType.asset,
        widget.videoUrl,
      );
    } else {
      dataSource = AwesomeVideoPlayerDataSource(
        AwesomeVideoPlayerDataSourceType.file,
        widget.videoUrl,
      );
    }

    // Create configuration
    final configuration = AwesomeVideoPlayerConfiguration(
      // Playback settings
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      startAt: widget.startAt,
      
      // UI Configuration
      controlsConfiguration: AwesomeVideoPlayerControlsConfiguration(
        showControls: widget.showControls,
        showPlayButton: true,
        showMuteButton: true,
        showFullscreenButton: true,
        showProgressBar: true,
        showBufferingProgress: true,
        enableProgressBarDrag: true,
        enableMute: true,
        enableFullscreen: true,
        enablePip: true,
        enablePlaybackSpeed: true,
        enableSkips: true,
        enableSubtitles: widget.subtitles != null,
        enableAudioTracks: true,
        controlsTimeoutTime: const Duration(seconds: 3),
        progressBarPlayedColor: widget.controlsColor ?? Colors.red,
        progressBarHandleColor: widget.controlsColor ?? Colors.red,
      ),
      
      // Subtitle configuration
      subtitlesConfiguration: AwesomeVideoPlayerSubtitlesConfiguration(
        fontSize: 16,
        fontColor: Colors.white,
        outlineColor: Colors.black,
        backgroundColor: Colors.black54,
        fontWeight: FontWeight.normal,
      ),
      
      // Video fit and aspect ratio
      fit: widget.fit ?? BoxFit.contain,
      aspectRatio: widget.aspectRatio,
      
      // Advanced features
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      
      // Error handling
      errorBuilder: (context, errorMessage) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Video Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Failed to load video',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      
      // Event callbacks
      eventListener: (AwesomeVideoPlayerEvent event) {
        switch (event.awesomeVideoPlayerEventType) {
          case AwesomeVideoPlayerEventType.initialized:
            setState(() {
              _isInitialized = true;
            });
            widget.onVideoReady?.call();
            break;
          case AwesomeVideoPlayerEventType.finished:
            widget.onVideoCompleted?.call();
            break;
          default:
            break;
        }
      },
    );

    // Initialize controller
    _controller = AwesomeVideoPlayerController(configuration);
    
    // Add subtitles if provided
    if (widget.subtitles != null) {
      await _controller!.setupDataSource(dataSource);
      for (var subtitle in widget.subtitles!) {
        _controller!.setupSubtitleSource(subtitle);
      }
    } else {
      await _controller!.setupDataSource(dataSource);
    }

    // Notify parent about controller creation
    widget.onControllerCreated?.call(_controller!);
  }

  AwesomeVideoPlayerVideoFormat? _getVideoFormat(String url) {
    if (url.contains('.m3u8')) {
      return AwesomeVideoPlayerVideoFormat.hls;
    } else if (url.contains('.mpd')) {
      return AwesomeVideoPlayerVideoFormat.dash;
    } else {
      return AwesomeVideoPlayerVideoFormat.other;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.controlsColor ?? Colors.red,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Title bar (optional)
              if (widget.title != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              // Video player
              Expanded(
                child: AwesomeVideoPlayer(
                  controller: _controller!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage widget
class VideoPlayerExample extends StatefulWidget {
  @override
  _VideoPlayerExampleState createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample> {
  AwesomeVideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awesome Video Player Demo'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic video player
            Text(
              'Basic Video Player',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 12),
            AwesomeVideoWidget(
              videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
              title: 'Sample Video',
              autoPlay: false,
              showControls: true,
              aspectRatio: 16 / 9,
              controlsColor: Colors.blue,
              onControllerCreated: (controller) {
                _videoController = controller;
              },
              onVideoReady: () {
                print('Video is ready to play');
              },
              onVideoCompleted: () {
                print('Video playback completed');
              },
            ),
            
            SizedBox(height: 24),
            
            // Control buttons
            Text(
              'Player Controls',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _videoController?.play(),
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _videoController?.pause(),
                  icon: Icon(Icons.pause),
                  label: Text('Pause'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _videoController?.seekTo(Duration.zero),
                  icon: Icon(Icons.replay),
                  label: Text('Restart'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _videoController?.setVolume(0.5),
                  icon: Icon(Icons.volume_down),
                  label: Text('50% Volume'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _videoController?.enterFullScreen(),
                  icon: Icon(Icons.fullscreen),
                  label: Text('Fullscreen'),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // HLS Example
            Text(
              'HLS Streaming Example',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 12),
            AwesomeVideoWidget(
              videoUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8',
              title: 'HLS Stream',
              autoPlay: false,
              showControls: true,
              aspectRatio: 4 / 3,
              controlsColor: Colors.green,
            ),
            
            SizedBox(height: 24),
            
            // Features list
            Text(
              'Available Features',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 12),
            _buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      '📝 Playlist support',
      '💬 Subtitles (SRT, WEBVTT, HLS)',
      '🔒 DRM support (Widevine, FairPlay)',
      '📡 HTTP Headers support',
      '🖼️ BoxFit configuration',
      '⚡ Playback speed control',
      '🔄 Resolution switching',
      '🎥 HLS & DASH streaming',
      '💾 Video caching',
      '📍 Picture in Picture',
      '🎮 Custom controls',
      '📱 ListView integration',
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features.map((feature) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              feature,
              style: TextStyle(fontSize: 14),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

