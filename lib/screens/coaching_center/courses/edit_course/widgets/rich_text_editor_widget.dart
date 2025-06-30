// widgets/rich_text_editor_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditorWidget extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(List<String>) onChanged;
  final BoxConstraints constraints;

  const RichTextEditorWidget({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.constraints,
  });

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    // Delay initialization to avoid scroll position issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingContent();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  void _loadExistingContent() {
    if (widget.items.isNotEmpty) {
      // Join items with line breaks instead of bullet points
      final content = widget.items.join('\n');
      _controller.document = Document()..insert(0, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.constraints.maxWidth > 600 ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),

        // Toolbar - Only show when initialized
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: _isInitialized
              ? QuillSimpleToolbar(
                  controller: _controller,
                  config: const QuillSimpleToolbarConfig(
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showListNumbers: true,
                    showListBullets: true,
                    showCodeBlock: false,
                    showInlineCode: false,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    multiRowsDisplay: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showQuote: false,
                    showIndent: false,
                    showDirection: false,
                    showHeaderStyle: false,
                    showListCheck: false,
                    showClearFormat: true,
                  ),
                )
              : Container(
                  height: 50,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00B894),
                      ),
                    ),
                  ),
                ),
        ),

        // Editor
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            color: Colors.grey[50],
          ),
          child: QuillEditor.basic(
            controller: _controller,
            focusNode: _focusNode,
            config: QuillEditorConfig(
              padding: const EdgeInsets.all(16),
              placeholder: 'Add ${widget.label.toLowerCase()}...',
              autoFocus: false,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Action Buttons
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isInitialized ? _saveContent : null,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _isInitialized ? _clearContent : null,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _isInitialized ? _addAsNewItem : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        // Preview
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Current ${widget.label}:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _clearAllItems,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeItem(index),
                            icon: const Icon(Icons.close, size: 16),
                            color: Colors.red,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _saveContent() {
    if (!_isInitialized) return;

    try {
      final plainText = _controller.document.toPlainText().trim();
      if (plainText.isNotEmpty) {
        // Save the entire content as a single item instead of splitting by lines
        final updatedItems = List<String>.from(widget.items);

        // Check if this content already exists
        if (!updatedItems.contains(plainText)) {
          updatedItems.add(plainText);
        }

        widget.onChanged(updatedItems);
        _controller.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.label} saved successfully'),
              backgroundColor: const Color(0xFF00B894),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving content: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addAsNewItem() {
    if (!_isInitialized) return;

    try {
      final plainText = _controller.document.toPlainText().trim();
      if (plainText.isNotEmpty) {
        // Split content by paragraphs/lines and add each as separate items
        final lines = plainText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();

        final updatedItems = List<String>.from(widget.items);

        for (final line in lines) {
          if (!updatedItems.contains(line)) {
            updatedItems.add(line);
          }
        }

        widget.onChanged(updatedItems);
        _controller.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${lines.length} item(s) added successfully'),
              backgroundColor: const Color(0xFF00B894),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding items: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearContent() {
    if (!_isInitialized) return;

    try {
      _controller.clear();
    } catch (e) {
      // Handle any clear errors silently
    }
  }

  void _removeItem(int index) {
    final updatedItems = List<String>.from(widget.items);
    updatedItems.removeAt(index);
    widget.onChanged(updatedItems);
  }

  void _clearAllItems() {
    widget.onChanged([]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
