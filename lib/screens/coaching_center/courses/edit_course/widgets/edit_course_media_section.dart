import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditCourseMediaSection extends StatefulWidget {
  final File? courseImage;
  final File? introVideo;
  final String? currentImageUrl;
  final String? currentVideoUrl;
  final Function(File?) onImagePicked;
  final Function(File?) onVideoPicked;
  final BoxConstraints constraints;

  const EditCourseMediaSection({
    super.key,
    required this.courseImage,
    required this.introVideo,
    required this.currentImageUrl,
    required this.currentVideoUrl,
    required this.onImagePicked,
    required this.onVideoPicked,
    required this.constraints,
  });

  @override
  State<EditCourseMediaSection> createState() => _EditCourseMediaSectionState();
}

class _EditCourseMediaSectionState extends State<EditCourseMediaSection> {
  bool _isPickingFile = false;

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
        padding: EdgeInsets.all(widget.constraints.maxWidth > 600 ? 24 : 16),
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
                  child: const Icon(Icons.image_outlined, color: Color(0xFF00B894), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Course Media',
                  style: TextStyle(
                    fontSize: widget.constraints.maxWidth > 600 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.constraints.maxWidth > 600 ? 24 : 20),
            
            if (widget.constraints.maxWidth > 600)
              Row(
                children: [
                  Expanded(child: _buildImageUpload(context)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildVideoUpload(context)),
                ],
              )
            else ...[
              _buildImageUpload(context),
              const SizedBox(height: 16),
              _buildVideoUpload(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Image',
          style: TextStyle(
            fontSize: widget.constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: widget.constraints.maxWidth > 600 ? 180 : 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: widget.courseImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.courseImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => widget.onImagePicked(null),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                )
              : widget.currentImageUrl != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.currentImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildUploadPlaceholder(
                                icon: Icons.image_outlined,
                                title: 'Upload Course Image',
                                subtitle: 'JPG, PNG up to 5MB',
                                onTap: () => _pickImage(context),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: () => _pickImage(context),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildUploadPlaceholder(
                      icon: Icons.image_outlined,
                      title: 'Upload Course Image',
                      subtitle: 'JPG, PNG up to 5MB',
                      onTap: () => _pickImage(context),
                    ),
        ),
        if (widget.courseImage != null || widget.currentImageUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isPickingFile ? null : () => _pickImage(context),
                icon: _isPickingFile 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.edit, size: 16),
                label: Text(_isPickingFile ? 'Picking...' : 'Change Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B894),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _isPickingFile ? null : () => widget.onImagePicked(null),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVideoUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intro Video (Optional)',
          style: TextStyle(
            fontSize: widget.constraints.maxWidth > 600 ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: widget.constraints.maxWidth > 600 ? 180 : 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: widget.introVideo != null || widget.currentVideoUrl != null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B894).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Color(0xFF00B894),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Video Selected',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.introVideo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.introVideo!.path.split('/').last,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: () => widget.onVideoPicked(null),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildUploadPlaceholder(
                  icon: Icons.video_library_outlined,
                  title: 'Upload Intro Video',
                  subtitle: 'MP4, MOV up to 100MB',
                  onTap: () => _pickVideo(context),
                ),
        ),
        if (widget.introVideo != null || widget.currentVideoUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _isPickingFile ? null : () => _pickVideo(context),
                icon: _isPickingFile 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.edit, size: 16),
                label: Text(_isPickingFile ? 'Picking...' : 'Change Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B894),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _isPickingFile ? null : () => widget.onVideoPicked(null),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildUploadPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isPickingFile ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isPickingFile
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B894)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Picking file...',
                      style: TextStyle(
                        color: Color(0xFF00B894),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    if (_isPickingFile) return;

    setState(() {
      _isPickingFile = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        
        // Check file size (5MB limit)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file size should be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        widget.onImagePicked(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    if (_isPickingFile) return;

    setState(() {
      _isPickingFile = true;
    });

    try {
      // Add a small delay to prevent rapid successive calls
      await Future.delayed(const Duration(milliseconds: 300));
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false, // Don't create read stream
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Check file size (100MB limit)
        final fileSize = await file.length();
        if (fileSize > 100 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video file size should be less than 100MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        widget.onVideoPicked(file);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        String errorMessage = 'Error picking video';
        if (e.code == 'already_active') {
          errorMessage = 'File picker is busy. Please wait and try again.';
        } else if (e.code == 'read_external_storage_denied') {
          errorMessage = 'Storage permission denied. Please grant permission in settings.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: e.code == 'read_external_storage_denied'
                ? SnackBarAction(
                    label: 'Settings',
                    onPressed: () {
                      // You can add logic to open app settings here
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }
}
