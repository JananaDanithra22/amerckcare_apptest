import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

class DocumentEditorScreen extends StatefulWidget {
  final String? initialContent;
  const DocumentEditorScreen({Key? key, this.initialContent}) : super(key: key);

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  late TextEditingController _ctrl;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialContent ?? '');
    _ctrl.addListener(() {
      final words = _ctrl.text.trim().split(RegExp(r'\s+'));
      setState(() => _wordCount = _ctrl.text.trim().isEmpty ? 0 : words.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Write Document'),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              if (_ctrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document is empty')),
                );
                return;
              }
              Navigator.pop(context, _ctrl.text.trim());
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                _toolBtn(Icons.format_bold, 'Bold', () => _wrap('**', '**')),
                _toolBtn(Icons.format_italic, 'Italic', () => _wrap('_', '_')),
                _toolBtn(
                  Icons.format_underlined,
                  'Underline',
                  () => _wrap('<u>', '</u>'),
                ),
                const Spacer(),
                Text(
                  '$_wordCount words',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 15, height: 1.7),
                decoration: const InputDecoration(
                  hintText: 'Start writing your document here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Bottom word count bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                const Text(
                  'Tap Done when finished',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String tooltip, VoidCallback onTap) =>
      IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
        color: Colors.grey.shade700,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      );

  void _wrap(String open, String close) {
    final sel = _ctrl.selection;
    if (!sel.isValid) return;
    final text = _ctrl.text;
    final selected = sel.textInside(text);
    final replaced = '$open$selected$close';
    _ctrl.value = TextEditingValue(
      text: text.replaceRange(sel.start, sel.end, replaced),
      selection: TextSelection.collapsed(offset: sel.start + replaced.length),
    );
  }
}
