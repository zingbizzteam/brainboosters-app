// screens/coaching_center/courses/widgets/video_upload_widget.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class VideoUploadWidget extends StatefulWidget {
  final String? initialVideoUrl;
  final Function(String) onVideoUploaded;

  const VideoUploadWidget({
    super.key,
    this.initialVideoUrl,
    required this.onVideoUploaded,
  });

  @override
  State<VideoUploadWidget> createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  File? _selectedVideo;
  String? _videoUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _videoUrl = widget.initialVideoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lesson Video',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_videoUrl != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      SizedBox(height: 8),
                      Text('Video Uploaded', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Change Video'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _videoUrl = null),
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ] else if (_selectedVideo != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_file, size: 64, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      _selectedVideo!.path.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text('${(_uploadProgress * 100).toInt()}% uploaded'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadVideo,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Upload Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : () => setState(() => _selectedVideo = null),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _pickVideo,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Click to select video'),
                      SizedBox(height: 4),
                      Text(
                        'Supported formats: MP4, MOV, AVI\nMax size: 500MB',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);
        
        if (fileSizeInMB > 500) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video file is too large. Maximum size is 500MB.')),
            );
          }
          return;
        }

        setState(() {
          _selectedVideo = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting video: $e')),
        );
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedVideo!.path.split('/').last}';
      
      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('course-videos')
          .upload(
            'lessons/$fileName',
            _selectedVideo!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final videoUrl = Supabase.instance.client.storage
          .from('course-videos')
          .getPublicUrl('lessons/$fileName');

      setState(() {
        _videoUrl = videoUrl;
        _selectedVideo = null;
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      widget.onVideoUploaded(videoUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
    }
  }
}
