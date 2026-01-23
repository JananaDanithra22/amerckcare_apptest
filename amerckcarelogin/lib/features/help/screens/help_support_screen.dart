// lib/features/help/screens/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';

/// Help & Support screen for AmerckCare
/// Includes FAQs, contact options, and support resources
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Track expanded FAQ items
  int? _expandedFaqIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildQuickActionsSection(),
            _buildFaqSection(),
            _buildContactSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Help & Support'),
      elevation: 0,
      backgroundColor: UIConstants.primaryBlue,
      foregroundColor: Colors.white,
    );
  }

  /// Build hero section
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: UIConstants.primaryGradient),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(
            'How can we help you?',
            style: AppTextStyles.headingXLarge.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Find answers to common questions or get in touch with our support team',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.headingMedium),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'support@amerckcare.com',
                  color: UIConstants.primaryBlue,
                  onTap: () => _launchEmail(),
                ),
              ),
              const SizedBox(width: UIConstants.spacingM),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '+1 (555) 123-4567',
                  color: UIConstants.successGreen,
                  onTap: () => _launchPhone(),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.chat_outlined,
                  title: 'Live Chat',
                  subtitle: 'Chat with support',
                  color: UIConstants.warningOrange,
                  onTap: () => _showComingSoonSnackbar('Live Chat'),
                ),
              ),
              const SizedBox(width: UIConstants.spacingM),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.description_outlined,
                  title: 'Docs',
                  subtitle: 'View documentation',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _showComingSoonSnackbar('Documentation'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build FAQ section
  Widget _buildFaqSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Getting Started', Icons.rocket_launch, [
            FaqItem(
              question: 'How do I create an account?',
              answer:
                  'Download the AmerckCare app and tap "Sign Up" on the login screen. You can register using your email, Google, or Facebook by following the on-screen steps.',
            ),
            FaqItem(
              question: 'How do I enable biometric login?',
              answer:
                  'Go to Settings > Biometric Login and turn it on. Verify your login details, then use fingerprint or face recognition to sign in.',
            ),
            FaqItem(
              question: 'What login methods are supported?',
              answer:
                  'You can log in using Email/Password, Google Sign-In, or Facebook Sign-In. Biometric login is also available after first login.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Account & Security', Icons.security, [
            FaqItem(
              question: 'How do I reset my password?',
              answer:
                  'Tap "Forgot Password?" on the login screen, enter your email, and follow the reset instructions sent to your email.',
            ),
            FaqItem(
              question: 'Is my health data secure?',
              answer:
                  'Yes. Your data is encrypted and securely stored using industry-standard security practices.',
            ),
            FaqItem(
              question: 'Can I change my password?',
              answer:
                  'Yes. Go to Profile > Change Password and enter your current password to set a new one.',
            ),
            FaqItem(
              question: 'What happens if I\'m inactive for too long?',
              answer:
                  'The app automatically logs you out after 5 minutes of inactivity to keep your data secure.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Features & Usage', Icons.explore, [
            FaqItem(
              question: 'How do I view my patient records?',
              answer:
                  'Open the home screen and tap "Patient Profile" to see your medical history and records.',
            ),
            FaqItem(
              question: 'Can I access the app offline?',
              answer:
                  'You can view previously loaded data offline, but an internet connection is needed to sync new information.',
            ),
            FaqItem(
              question: 'How do prescriptions work?',
              answer:
                  'Your doctor sends prescriptions through the app. You can view them in your patient profile.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Troubleshooting', Icons.build, [
            FaqItem(
              question: 'The app won\'t let me log in',
              answer:
                  'Check your internet connection and login details. Use "Forgot Password?" or try another login method if needed.',
            ),
            FaqItem(
              question: 'Biometric login stopped working',
              answer:
                  'Turn biometric login off and on again in Settings, then re-authenticate to set it up.',
            ),
            FaqItem(
              question: 'I\'m not receiving notifications',
              answer:
                  'Make sure notifications are enabled in both your device settings and the app settings.',
            ),
          ]),
        ],
      ),
    );
  }

  /// Build contact section
  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingL),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UIConstants.primaryBlue.withOpacity(0.1),
            UIConstants.darkBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: UIConstants.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.contact_support,
            size: 48,
            color: UIConstants.primaryBlue,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Text('Still need help?', style: AppTextStyles.headingMedium),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Our support team is here to help you',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: UIConstants.spacingL),
          _buildContactInfo(
            Icons.email,
            'Email Support',
            'support@amerckcare.com',
            'Response time: Within 24 hours',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildContactInfo(
            Icons.phone,
            'Phone Support',
            '+1 (555) 123-4567',
            'Mon-Fri: 9AM - 6PM EST',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildContactInfo(
            Icons.schedule,
            'Business Hours',
            'Monday - Friday',
            '9:00 AM - 6:00 PM EST',
          ),
        ],
      ),
    );
  }

  /// Build footer
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.spacingL),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      decoration: BoxDecoration(color: UIConstants.mediumGrey),
      child: Column(
        children: [
          Text('Additional Resources', style: AppTextStyles.headingSmall),
          const SizedBox(height: UIConstants.spacingM),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: UIConstants.spacingM,
            runSpacing: UIConstants.spacingS,
            children: [
              _buildFooterLink('Privacy Policy'),
              _buildFooterLink('Terms of Service'),
              _buildFooterLink('User Guide'),
              _buildFooterLink('System Status'),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          const Divider(),
          const SizedBox(height: UIConstants.spacingM),
          Text('AmerckCare v1.0.0', style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  /// Build quick action card
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          boxShadow: UIConstants.shadowLight,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              title,
              style: AppTextStyles.settingsTileTitle.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingXs),
            Text(
              subtitle,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build FAQ category
  Widget _buildFaqCategory(String title, IconData icon, List<FaqItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  decoration: BoxDecoration(
                    color: UIConstants.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Icon(icon, color: UIConstants.primaryBlue, size: 20),
                ),
                const SizedBox(width: UIConstants.spacingM),
                Text(title, style: AppTextStyles.headingSmall),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final globalIndex = items.indexOf(item);

            return _buildFaqItem(item, globalIndex);
          }).toList(),
        ],
      ),
    );
  }

  /// Build individual FAQ item
  Widget _buildFaqItem(FaqItem item, int index) {
    final isExpanded = _expandedFaqIndex == index;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedFaqIndex = isExpanded ? null : index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style:
                        isExpanded
                            ? AppTextStyles.settingsTileTitle.copyWith(
                              color: UIConstants.primaryBlue,
                            )
                            : AppTextStyles.settingsTileTitle,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: UIConstants.primaryBlue,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.spacingM,
              right: UIConstants.spacingM,
              bottom: UIConstants.spacingM,
            ),
            child: Container(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              decoration: BoxDecoration(
                color: UIConstants.lightGrey,
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Text(item.answer, style: AppTextStyles.bodyMedium),
            ),
          ),
        if (index < 10) const Divider(height: 1),
      ],
    );
  }

  /// Build contact info row
  Widget _buildContactInfo(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          decoration: BoxDecoration(
            color: UIConstants.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: Icon(icon, color: UIConstants.primaryBlue, size: 24),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelSmall),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(subtitle, style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  /// Build footer link
  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () => _showComingSoonSnackbar(text),
      child: Text(text, style: AppTextStyles.linkSmall),
    );
  }

  /// Launch email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@amerckcare.com',
      query: 'subject=AmerckCare Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackbar('Could not open email client');
    }
  }

  /// Launch phone
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackbar('Could not open phone dialer');
    }
  }

  /// Show coming soon snackbar
  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UIConstants.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// FAQ item model
class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
