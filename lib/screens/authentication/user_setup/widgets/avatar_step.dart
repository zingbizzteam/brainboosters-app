import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarStep extends StatefulWidget {
  final File? avatarFile;
  final String? avatarUrl;
  final Function(File?) onImagePicked;

  const AvatarStep({
    super.key,
    required this.avatarFile,
    required this.avatarUrl,
    required this.onImagePicked,
  });

  @override
  State<AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<AvatarStep> {
  final ImagePicker _picker = ImagePicker(); // Create instance once
  bool _isPickingImage = false; // Prevent multiple calls

  Future<void> _pickImage() async {
    // Prevent multiple simultaneous calls
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      // Show bottom sheet to choose source
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        if (!kIsWeb) {
          widget.onImagePicked(File(pickedFile.path));
        } else {
          // Handle web platform if needed
          widget.onImagePicked(null);
        }
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
          _isPickingImage = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              if (widget.avatarFile != null || widget.avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onImagePicked(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Add a profile picture",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          GestureDetector(
            onTap: _isPickingImage ? null : _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(
                  color: _isPickingImage
                      ? Colors.grey
                      : const Color(0xFF5DADE2),
                  width: 2,
                ),
              ),
              child: _isPickingImage
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5DADE2),
                        strokeWidth: 2,
                      ),
                    )
                  : _buildAvatarContent(),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _isPickingImage ? 'Loading...' : 'Tap to choose image',
            style: TextStyle(
              color: _isPickingImage ? Colors.grey : const Color(0xFF5DADE2),
            ),
          ),

          const SizedBox(height: 16),

          // Optional: Add buttons for better UX
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () async {
                        if (_isPickingImage) return;
                        setState(() => _isPickingImage = true);

                        try {
                          final XFile? pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );

                          if (pickedFile != null && mounted && !kIsWeb) {
                            widget.onImagePicked(File(pickedFile.path));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isPickingImage = false);
                        }
                      },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),

              const SizedBox(width: 16),

              OutlinedButton.icon(
                onPressed: _isPickingImage
                    ? null
                    : () async {
                        if (_isPickingImage) return;
                        setState(() => _isPickingImage = true);

                        try {
                          final XFile? pickedFile = await _picker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );

                          if (pickedFile != null && mounted && !kIsWeb) {
                            widget.onImagePicked(File(pickedFile.path));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isPickingImage = false);
                        }
                      },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (widget.avatarFile != null) {
      return ClipOval(
        child: Image.file(
          widget.avatarFile!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 40, color: Colors.red);
          },
        ),
      );
    }

    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.avatarUrl!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5DADE2),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 40, color: Colors.red);
          },
        ),
      );
    }

    return const Icon(Icons.add_a_photo, size: 40, color: Color(0xFF5DADE2));
  }
}
