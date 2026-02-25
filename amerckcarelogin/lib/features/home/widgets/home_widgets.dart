// lib/features/home/widgets/home_widgets.dart
// All home screen widgets consolidated in one file

import 'package:flutter/material.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/constants/text_styles.dart';
import '../../../config/routes.dart';

// ============================================================================
// HEADER WIDGET
// ============================================================================
class HomeHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1C8AE5)),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/signlogo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.local_hospital,
                size: 32,
                color: Color(0xFF1C8AE5),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'AmerckCare',
            style: AppTextStyles.appBarTitle.copyWith(
              color: const Color(0xFF1C8AE5),
            ),
          ),
          const Spacer(),
          if (SessionManager().isSessionActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Active',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// MORNING BRIEFING CARD
// ============================================================================
class MorningBriefingCard extends StatelessWidget {
  final String userName;

  const MorningBriefingCard({Key? key, required this.userName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String greeting =
        now.hour < 12
            ? 'Good Morning'
            : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C8AE5), Color(0xFF0650A2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dr. $userName',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Today\'s Overview',
            style: AppTextStyles.settingsTileTitle.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  value: '12',
                  subLabel: 'scheduled today',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Waiting',
                  value: '5',
                  subLabel: 'in queue now',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subLabel;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statValueLarge.copyWith(color: Colors.white),
          ),
          Text(
            subLabel,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK SEARCH BAR
// ============================================================================
class QuickSearchBar extends StatelessWidget {
  const QuickSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search patient by name or ID...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Icon(Icons.mic, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}

// ============================================================================
// QUEUE STATUS SECTION
// ============================================================================
class QueueStatusSection extends StatelessWidget {
  const QueueStatusSection({Key? key}) : super(key: key);

  // TODO: Replace with real data from backend
  static final List<Map<String, dynamic>> _mockPatients = [
    {
      'name': 'Joey Tribbiani',
      'id': 'P001',
      'waiting': '15 min',
      'type': 'Checkup',
    },
    {
      'name': 'Chandler Bing',
      'id': 'P002',
      'waiting': '8 min',
      'type': 'Follow-up',
    },
    {
      'name': 'Ross Geller',
      'id': 'P003',
      'waiting': '3 min',
      'type': 'Emergency',
    },
    {
      'name': 'Monica Geller',
      'id': 'P004',
      'waiting': '12 min',
      'type': 'Checkup',
    },
    {
      'name': 'Phoebe Buffay',
      'id': 'P005',
      'waiting': '20 min',
      'type': 'Follow-up',
    },
    {
      'name': 'Rachel Green',
      'id': 'P006',
      'waiting': '25 min',
      'type': 'Checkup',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final displayedPatients = _mockPatients.take(3).toList();
    final remainingCount = _mockPatients.length - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ...displayedPatients.asMap().entries.map((entry) {
                final isLast =
                    entry.key == displayedPatients.length - 1 &&
                    _mockPatients.length <= 3;
                return _PatientCard(patient: entry.value, isLast: isLast);
              }),
              _ViewFullQueueButton(
                allPatients: _mockPatients,
                remainingCount: remainingCount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Queue Status', style: AppTextStyles.headingMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${_mockPatients.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final bool isLast;

  const _PatientCard({required this.patient, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening ${patient['name']}')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border:
              isLast
                  ? null
                  : Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  patient['name'][0],
                  style: AppTextStyles.cardTitle.copyWith(
                    color: const Color(0xFF1C8AE5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient['name'], style: AppTextStyles.settingsTileTitle),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(patient['id'], style: AppTextStyles.labelSmall),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              patient['type'] == 'Emergency'
                                  ? Colors.red.shade50
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          patient['type'],
                          style: AppTextStyles.labelTiny.copyWith(
                            color:
                                patient['type'] == 'Emergency'
                                    ? Colors.red.shade700
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(height: 2),
                Text(
                  patient['waiting'],
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewFullQueueButton extends StatelessWidget {
  final List<Map<String, dynamic>> allPatients;
  final int remainingCount;

  const _ViewFullQueueButton({
    required this.allPatients,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasMore = allPatients.length > 3;

    return InkWell(
      onTap: () => _showFullQueue(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasMore
                  ? 'View Full Queue ($remainingCount more)'
                  : 'View Full Queue',
              style: AppTextStyles.settingsTileTitle.copyWith(
                color: const Color(0xFF1C8AE5),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF1C8AE5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showFullQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Full Queue',
                                  style: AppTextStyles.headingMedium,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${allPatients.length} patients',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: allPatients.length,
                          itemBuilder: (context, index) {
                            return _PatientCard(
                              patient: allPatients[index],
                              isLast: index == allPatients.length - 1,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

// ============================================================================
// CORE FEATURES GRID
// ============================================================================
class CoreFeaturesGrid extends StatelessWidget {
  const CoreFeaturesGrid({Key? key}) : super(key: key);

  static const _features = [
    {
      'icon': Icons.medical_information,
      'title': 'Patient Profile',
      'subtitle': 'Timeline & History',
      'color': Color(0xFF4CAF50),
      'badge': 'One Record',
    },
    {
      'icon': Icons.medication_liquid,
      'title': 'Smart Rx',
      'subtitle': 'Quick Prescribe',
      'color': Color(0xFFFF9800),
      'badge': 'Safety Alerts',
    },
    {
      'icon': Icons.mic,
      'title': 'Voice Notes',
      'subtitle': 'Dictate & Save',
      'color': Color(0xFF2196F3),
      'badge': 'Voice-to-Text',
    },
    {
      'icon': Icons.note_add,
      'title': 'Quick Templates',
      'subtitle': 'Fast Documentation',
      'color': Color(0xFF9C27B0),
      'badge': 'Tap-to-Select',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('The Essentials', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _features.length,
          itemBuilder:
              (context, index) => _FeatureCard(feature: _features[index]),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Map<String, dynamic> feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final color = feature['color'] as Color;

    return InkWell(
      // REPLACE with:
      onTap: () {
        if (feature['title'] == 'Voice Notes') {
          AppRoutes.toVoiceNotes(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${feature['title']} coming soon')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: color,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    feature['badge'],
                    style: AppTextStyles.labelTiny.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(feature['subtitle'], style: AppTextStyles.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK DOCUMENTS GRID
// ============================================================================
class QuickDocumentsGrid extends StatelessWidget {
  const QuickDocumentsGrid({Key? key}) : super(key: key);

  static const _documents = [
    {
      'icon': Icons.psychology,
      'color': Color(0xFF7C4DFF),
      'title': 'AI Writer',
      'subtitle': 'Generate letters',
    },
    {
      'icon': Icons.send,
      'color': Color(0xFF4CAF50),
      'title': 'Referral',
      'subtitle': 'Send to specialist',
    },
    {
      'icon': Icons.event_note,
      'color': Color(0xFFFF5252),
      'title': 'Leave Cert',
      'subtitle': 'Medical leave',
    },
    {
      'icon': Icons.edit_document,
      'color': Color(0xFFFF6D00),
      'title': 'Custom',
      'subtitle': 'Create from scratch',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quick Documents', style: AppTextStyles.headingMedium),
            TextButton(
              onPressed:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all documents')),
                  ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _documents.length,
          itemBuilder:
              (context, index) => _DocumentCard(document: _documents[index]),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Map<String, dynamic> document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final color = document['color'] as Color;

    return InkWell(
      onTap:
          () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${document['title']} coming soon')),
          ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(document['icon'] as IconData, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    document['title'],
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document['subtitle'],
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
