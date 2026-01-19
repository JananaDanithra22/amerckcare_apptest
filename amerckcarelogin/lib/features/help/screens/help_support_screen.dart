// lib/features/help/screens/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/ui_constants.dart';

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
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingS),
          const Text(
            'Find answers to common questions or get in touch with our support team',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
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
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIConstants.textDark,
            ),
          ),
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
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIConstants.textDark,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Getting Started', Icons.rocket_launch, [
            FaqItem(
              question: 'How do I create an account?',
              answer:
                  'You can create an account by downloading the AmerckCare app and tapping "Sign Up" on the login screen. You can register using your email, Google account, or Facebook account. Follow the on-screen instructions to complete your profile.',
            ),
            FaqItem(
              question: 'How do I enable biometric login?',
              answer:
                  'After logging in, go to Settings > Biometric Login and toggle it on. You\'ll be prompted to verify your password (for email users) or authenticate with your current login method. Once enabled, you can use fingerprint or face recognition to quickly access your account.',
            ),
            FaqItem(
              question: 'What login methods are supported?',
              answer:
                  'AmerckCare supports three login methods: Email/Password, Google Sign-In, and Facebook Sign-In. You can also enable biometric authentication (fingerprint or face recognition) for faster access after your initial login.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Account & Security', Icons.security, [
            FaqItem(
              question: 'How do I reset my password?',
              answer:
                  'On the login screen, tap "Forgot Password?" and enter your registered email address. You\'ll receive an email with instructions to reset your password. Check your spam folder if you don\'t see the email within a few minutes.',
            ),
            FaqItem(
              question: 'Is my health data secure?',
              answer:
                  'Yes, your data is fully encrypted and stored securely. AmerckCare is HIPAA compliant and follows SOC 2 standards. We use enterprise-grade security measures including end-to-end encryption, secure authentication, and regular security audits to protect your information.',
            ),
            FaqItem(
              question: 'Can I change my password?',
              answer:
                  'Yes! Go to Profile > Change Password. You\'ll need to enter your current password, then set and confirm your new password. For security, your new password must be at least 6 characters long and different from your current password.',
            ),
            FaqItem(
              question: 'What happens if I\'m inactive for too long?',
              answer:
                  'For your security, AmerckCare automatically logs you out after 5 minutes of inactivity. You\'ll receive a warning 1 minute before automatic logout, giving you the option to stay signed in. This helps protect your sensitive health information.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Features & Usage', Icons.explore, [
            FaqItem(
              question: 'How do I view my patient records?',
              answer:
                  'Your patient records are accessible from the home screen. Tap on "Patient Profile" to view your complete medical history, including past appointments, prescriptions, lab results, and clinical notes in one centralized timeline.',
            ),
            FaqItem(
              question: 'Can I access the app offline?',
              answer:
                  'Some features require an internet connection, such as syncing new data and accessing cloud-stored records. However, you can view previously loaded information offline. The app will automatically sync when you reconnect to the internet.',
            ),
            FaqItem(
              question: 'How do prescriptions work?',
              answer:
                  'Your healthcare provider can create e-prescriptions directly through the AmerckCare system. You\'ll receive notifications when new prescriptions are available, and you can view them in your patient profile. The system includes safety alerts for drug interactions and allergies.',
            ),
          ]),
          const SizedBox(height: UIConstants.spacingM),
          _buildFaqCategory('Troubleshooting', Icons.build, [
            FaqItem(
              question: 'The app won\'t let me log in',
              answer:
                  'First, check your internet connection. Make sure you\'re entering the correct email and password. If you\'ve forgotten your password, use "Forgot Password?" to reset it. If you continue to have issues, try logging in with a different method (Google/Facebook) or contact support.',
            ),
            FaqItem(
              question: 'Biometric login stopped working',
              answer:
                  'This can happen if you\'ve changed your device\'s biometric settings or logged in from a different account. Go to Settings > Biometric Login, toggle it off, then back on. You\'ll need to re-authenticate to set it up again.',
            ),
            FaqItem(
              question: 'I\'m not receiving notifications',
              answer:
                  'Check that notifications are enabled for AmerckCare in your device settings. In the app, go to Settings > Notifications and ensure they\'re turned on. You may need to restart the app after changing notification settings.',
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
          const Text(
            'Still need help?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: UIConstants.textDark,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          const Text(
            'Our support team is here to help you',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: UIConstants.textMedium),
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
          const Text(
            'Additional Resources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: UIConstants.textDark,
            ),
          ),
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
          Text(
            'AmerckCare v1.0.0',
            style: TextStyle(fontSize: 12, color: UIConstants.textMedium),
          ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingXs),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: UIConstants.textMedium,
              ),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: UIConstants.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isExpanded ? FontWeight.bold : FontWeight.w500,
                      color:
                          isExpanded
                              ? UIConstants.primaryBlue
                              : UIConstants.textDark,
                    ),
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
              child: Text(
                item.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: UIConstants.textMedium,
                  height: 1.5,
                ),
              ),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: UIConstants.textMedium,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: UIConstants.textDark,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: UIConstants.textMedium,
                ),
              ),
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: UIConstants.primaryBlue,
          decoration: TextDecoration.underline,
        ),
      ),
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
