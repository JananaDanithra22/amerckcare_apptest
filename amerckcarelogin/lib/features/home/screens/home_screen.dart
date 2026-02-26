// lib/features/home/screens/home_screen.dart - DOCTOR'S DASHBOARD (CONSOLIDATED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/session_manager.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/home_widgets.dart';
import '../../profile/providers/profile_provider.dart';
import 'package:intl/intl.dart';
import '../../voice_notes/providers/voice_notes_provider.dart';
import '../../voice_notes/screens/voice_notes_screen.dart';
import '../../../core/constants/ui_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionManager().startSession();
      debugPrint('✅ Home screen loaded - session monitoring active');
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userEmail = auth.getCurrentUserEmail() ?? 'User';

    // Use saved profile name if available, otherwise fall back to email prefix
    final userName = profileProvider.profile?.name ?? userEmail.split('@')[0];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(scaffoldKey: _scaffoldKey),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MorningBriefingCard(userName: userName),
                    const SizedBox(height: 20),
                    const QuickSearchBar(),
                    const SizedBox(height: 24),
                    const QueueStatusSection(),
                    const SizedBox(height: 24),
                    _VoiceNotesCard(), // ← ADD THIS
                    const CoreFeaturesGrid(),
                    const SizedBox(height: 24),
                    const QuickDocumentsGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Voice Notes Preview Card for Home Screen ──
class _VoiceNotesCard extends StatelessWidget {
  const _VoiceNotesCard();

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<VoiceNotesProvider>(context);
    // Show only 2 most recent notes as preview
    final recentNotes = notesProvider.notes.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Voice Notes', style: AppTextStyles.headingMedium),
                const SizedBox(width: 8),
                if (notesProvider.notes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '${notesProvider.notes.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoiceNotesScreen()),
                  ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Note'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child:
              recentNotes.isEmpty
                  ? InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VoiceNotesScreen(),
                          ),
                        ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: UIConstants.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: UIConstants.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tap to record a voice note',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: UIConstants.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      ...recentNotes.map((note) {
                        final formatted = DateFormat(
                          'MMM d • h:mm a',
                        ).format(note.createdAt);
                        return InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VoiceNotesScreen(),
                                ),
                              ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: UIConstants.primaryBlue.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.mic,
                                    color: UIConstants.primaryBlue,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: AppTextStyles.listTileTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            formatted,
                                            style: AppTextStyles.caption,
                                          ),
                                          if (note.patientId.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '· ${note.patientId}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: UIConstants.infoBlue,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: UIConstants.textLight,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // View all button
                      InkWell(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VoiceNotesScreen(),
                              ),
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View All Notes',
                                style: AppTextStyles.listTileTitle.copyWith(
                                  color: UIConstants.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: UIConstants.primaryBlue,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
