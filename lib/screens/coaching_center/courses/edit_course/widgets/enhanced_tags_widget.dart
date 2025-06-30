// widgets/enhanced_tags_widget.dart
import 'package:flutter/material.dart';

class EnhancedTagsWidget extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;
  final BoxConstraints constraints;

  const EnhancedTagsWidget({
    super.key,
    required this.tags,
    required this.onChanged,
    required this.constraints,
  });

  @override
  State<EnhancedTagsWidget> createState() => _EnhancedTagsWidgetState();
}

class _EnhancedTagsWidgetState extends State<EnhancedTagsWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: widget.constraints.maxWidth > 600 ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add tags separated by commas (e.g., "web development, javascript, react") or use # (e.g., "#webdev #js #react")',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        
        // Input Field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Add tags: web development, javascript, #react, #nodejs',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onFieldSubmitted: (_) => _addTags(),
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addTags,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Quick Add Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickTag('Programming'),
            _buildQuickTag('Web Development'),
            _buildQuickTag('Mobile App'),
            _buildQuickTag('JavaScript'),
            _buildQuickTag('Flutter'),
            _buildQuickTag('React'),
            _buildQuickTag('Node.js'),
            _buildQuickTag('Python'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tags Display
        if (widget.tags.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Tags (${widget.tags.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _clearAllTags,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: const Color(0xFF00B894).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF00B894)),
                    deleteIconColor: Colors.red,
                    side: BorderSide(color: const Color(0xFF00B894).withOpacity(0.3)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No tags added yet. Add tags to help students find your course.',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickTag(String tag) {
    final isSelected = widget.tags.contains(tag.toLowerCase());
    return InkWell(
      onTap: () => isSelected ? _removeTag(tag.toLowerCase()) : _addSingleTag(tag.toLowerCase()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B894).withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? const Color(0xFF00B894) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : Icons.add,
              size: 14,
              color: isSelected ? const Color(0xFF00B894) : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF00B894) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTags() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    List<String> newTags = [];
    
    // Handle comma-separated tags
    if (input.contains(',')) {
      newTags.addAll(
        input.split(',').map((tag) => tag.trim().toLowerCase()).where((tag) => tag.isNotEmpty)
      );
    }
    // Handle hashtag format
    else if (input.contains('#')) {
      final hashtagRegex = RegExp(r'#(\w+)');
      final matches = hashtagRegex.allMatches(input);
      newTags.addAll(matches.map((match) => match.group(1)!.toLowerCase()));
      
      // Also add non-hashtag words
      final nonHashtagWords = input.replaceAll(hashtagRegex, '').split(' ')
          .map((word) => word.trim().toLowerCase())
          .where((word) => word.isNotEmpty);
      newTags.addAll(nonHashtagWords);
    }
    // Handle space-separated tags
    else {
      newTags.addAll(
        input.split(' ').map((tag) => tag.trim().toLowerCase()).where((tag) => tag.isNotEmpty)
      );
    }

    // Remove duplicates and add to existing tags
    final updatedTags = List<String>.from(widget.tags);
    for (final tag in newTags) {
      if (!updatedTags.contains(tag) && tag.length > 1) {
        updatedTags.add(tag);
      }
    }

    widget.onChanged(updatedTags);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _addSingleTag(String tag) {
    if (!widget.tags.contains(tag)) {
      final updatedTags = List<String>.from(widget.tags);
      updatedTags.add(tag);
      widget.onChanged(updatedTags);
    }
  }

  void _removeTag(String tag) {
    final updatedTags = List<String>.from(widget.tags);
    updatedTags.remove(tag);
    widget.onChanged(updatedTags);
  }

  void _clearAllTags() {
    widget.onChanged([]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
