// lib/features/voice_notes/screens/voice_notes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/voice_notes_provider.dart';
import '../models/voice_note_model.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({Key? key}) : super(key: key);

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  bool _speechAvailable = false;
  String _currentText = '';
  String _statusText = 'Tap the mic to start';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for mic button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop();

    _initSpeech();
    _loadNotes();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() => _statusText = 'Microphone permission denied');
      return;
    }

    _speechAvailable = await _speech.initialize(
      onError: (error) {
        setState(() {
          _isListening = false;
          _statusText = 'Error: ${error.errorMsg}';
        });
        _pulseController.stop();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _pulseController.stop();
        }
      },
    );

    setState(() {
      _statusText =
          _speechAvailable
              ? 'Tap the mic to start'
              : 'Speech not available on this device';
    });
  }

  void _loadNotes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid =
          Provider.of<AuthProvider>(context, listen: false).getCurrentUserId();
      if (uid != null) {
        Provider.of<VoiceNotesProvider>(context, listen: false).loadNotes(uid);
      }
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      // Stop listening
      await _speech.stop();
      setState(() {
        _isListening = false;
        _statusText =
            _currentText.isEmpty
                ? 'Tap the mic to start'
                : 'Tap save to keep this note';
      });
      _pulseController.stop();
    } else {
      // Start listening
      setState(() {
        _isListening = true;
        _statusText = 'Listening... speak now';
        _currentText = '';
      });
      _pulseController.repeat(reverse: true);

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _currentText = result.recognizedWords;
          });
        },
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
      );
    }
  }

  Future<void> _saveNote() async {
    if (_currentText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to save — record something first'),
        ),
      );
      return;
    }

    final uid =
        Provider.of<AuthProvider>(context, listen: false).getCurrentUserId();
    if (uid == null) return;

    // Auto-generate title from first few words
    final words = _currentText.trim().split(' ');
    final autoTitle = words.take(5).join(' ') + (words.length > 5 ? '...' : '');

    final note = VoiceNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      content: _currentText.trim(),
      title: autoTitle,
      createdAt: DateTime.now(),
    );

    final success = await Provider.of<VoiceNotesProvider>(
      context,
      listen: false,
    ).saveNote(note);

    if (mounted) {
      if (success) {
        setState(() {
          _currentText = '';
          _statusText = 'Tap the mic to start';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Note saved!'),
            backgroundColor: UIConstants.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save note'),
            backgroundColor: UIConstants.errorRed,
          ),
        );
      }
    }
  }

  void _clearCurrent() {
    setState(() {
      _currentText = '';
      _statusText = 'Tap the mic to start';
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<VoiceNotesProvider>(context);

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('Voice Notes'),
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Recorder Section (top) ──
          _buildRecorderSection(),

          // ── Saved Notes List (bottom) ──
          Expanded(child: _buildNotesList(notesProvider)),
        ],
      ),
    );
  }

  Widget _buildRecorderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: UIConstants.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(UIConstants.spacingL),
      child: Column(
        children: [
          Text(
            _statusText,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: UIConstants.spacingL),

          // Mic Button with pulse animation
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.white)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 40,
                      color:
                          _isListening ? Colors.white : UIConstants.primaryBlue,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: UIConstants.spacingL),

          // Transcribed text box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(UIConstants.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              _currentText.isEmpty
                  ? 'Your transcribed text will appear here...'
                  : _currentText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _currentText.isEmpty ? Colors.white38 : Colors.white,
              ),
            ),
          ),

          const SizedBox(height: UIConstants.spacingM),

          // Save & Clear buttons
          if (_currentText.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCurrent,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: UIConstants.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: UIConstants.spacingS),
        ],
      ),
    );
  }

  Widget _buildNotesList(VoiceNotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notesProvider.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              'No notes yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: UIConstants.textLight,
              ),
            ),
            Text(
              'Record your first voice note above',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Saved Notes (${notesProvider.notes.length})',
            style: AppTextStyles.headingSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
            ),
            itemCount: notesProvider.notes.length,
            itemBuilder: (context, index) {
              return _NoteCard(
                note: notesProvider.notes[index],
                onDelete:
                    () =>
                        notesProvider.deleteNote(notesProvider.notes[index].id),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Note Card Widget ──
class _NoteCard extends StatelessWidget {
  final VoiceNote note;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMM d, yyyy • h:mm a').format(note.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  decoration: BoxDecoration(
                    color: UIConstants.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: UIConstants.primaryBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingS),
                Expanded(
                  child: Text(note.title, style: AppTextStyles.listTileTitle),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(note.content, style: AppTextStyles.bodyMedium),
            const SizedBox(height: UIConstants.spacingS),
            Text(formatted, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Note?'),
            content: const Text('This note will be permanently deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
