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
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!kIsWeb) {
        widget.onImagePicked(File(pickedFile.path));
      }
    }
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
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: _buildAvatarContent(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to choose image',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (widget.avatarFile != null) {
      return ClipOval(
        child: Image.file(widget.avatarFile!, fit: BoxFit.cover),
      );
    }
    if (widget.avatarUrl != null) {
      return ClipOval(
        child: Image.network(widget.avatarUrl!, fit: BoxFit.cover),
      );
    }
    return const Icon(
      Icons.add_a_photo,
      size: 40,
      color: Colors.blue,
    );
  }
}
