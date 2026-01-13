// lib/features/about/screens/about_us_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

/// About Us screen for AmerckCare
/// Displays company information, mission, and core values
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildAboutSection(),
            _buildMissionSection(),
            _buildQuoteSection(),
            _buildValuesSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('About Us'),
      elevation: 0,
      backgroundColor: UIConstants.primaryBlue,
      foregroundColor: Colors.white,
    );
  }

  /// Build hero section with logo and tagline
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: UIConstants.primaryGradient,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.spacingXxl,
        horizontal: UIConstants.spacingL,
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: UIConstants.shadowMedium,
            ),
            padding: const EdgeInsets.all(UIConstants.spacingL),
            child: Image.asset(
              'assets/images/signlogo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_hospital,
                size: 60,
                color: UIConstants.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          // Company name
          const Text(
            'Amerck Care',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          // Tagline
          const Text(
            'Redefining Digital Healthcare\nfor a Connected World',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build about section
  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingL),
      padding: const EdgeInsets.all(UIConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                decoration: BoxDecoration(
                  color: UIConstants.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
                child: const Icon(
                  Icons.business,
                  color: UIConstants.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: UIConstants.spacingM),
              const Expanded(
                child: Text(
                  'About Amerck Care',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UIConstants.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          const Text(
            'Amerck Care is a leading healthcare IT company delivering intelligent, integrated, and secure digital solutions tailored for modern healthcare systems.',
            style: TextStyle(
              fontSize: 16,
              color: UIConstants.textDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Since 2015, we have been empowering healthcare providers, laboratories, pharmacies, and health networks with scalable, cloud-based platforms that enhance patient care, improve operational efficiency, and ensure full regulatory compliance.',
            style: TextStyle(
              fontSize: 15,
              color: UIConstants.textMedium,
              height: 1.6,
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          // Key highlights
          _buildHighlight(
            Icons.star,
            'AI-Driven Insights',
            'Intelligent automation for smarter healthcare decisions',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildHighlight(
            Icons.link,
            'Interoperability',
            'Seamless integration with HL7/FHIR standards',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildHighlight(
            Icons.security,
            'Enterprise Security',
            'HIPAA, SOC 2, and international compliance',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildHighlight(
            Icons.public,
            'Global Reach',
            'Operations across North America, Europe, and South Asia',
          ),
        ],
      ),
    );
  }

  /// Build mission section
  Widget _buildMissionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowMedium,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'With smart features like AI summaries, e-prescriptions, and lab integrations, we enable faster, safer, and smarter care.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Our platform changes the game — built for speed, simplicity, and smarter care.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build quote section
  Widget _buildQuoteSection() {
    return Container(
      margin: const EdgeInsets.all(UIConstants.spacingL),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      decoration: BoxDecoration(
        color: UIConstants.errorRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color: UIConstants.errorRed.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: UIConstants.errorRed,
            size: 40,
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Every heart beat counts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: UIConstants.errorRed,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          const Text(
            'Old paper systems and complicated EMRs slow doctors down, scatter patient data, and cost lives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: UIConstants.textMedium,
              height: 1.6,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Because when doctors are free to focus, patients truly win.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UIConstants.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build core values section
  Widget _buildValuesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Core Values',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: UIConstants.textDark,
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          _buildValueCard(
            color: const Color(0xFF2196F3),
            icon: Icons.person_outline,
            title: 'Patient-Centered',
            description: 'Every solution designed with patient outcomes in mind',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildValueCard(
            color: const Color(0xFF9C27B0),
            icon: Icons.psychology,
            title: 'AI-Powered',
            description: 'Intelligent automation for smarter healthcare decisions',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildValueCard(
            color: const Color(0xFFFF9800),
            icon: Icons.people,
            title: 'Collaborative',
            description: 'Seamless teamwork across all healthcare professionals',
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildValueCard(
            color: const Color(0xFF4CAF50),
            icon: Icons.workspace_premium,
            title: 'Excellence',
            description: 'Commitment to the highest standards of quality',
          ),
        ],
      ),
    );
  }

  /// Build footer
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.spacingXl),
      padding: const EdgeInsets.all(UIConstants.spacingXl),
      decoration: const BoxDecoration(
        gradient: UIConstants.primaryGradient,
      ),
      child: Column(
        children: [
          const Text(
            'Building meaningful healthcare experiences through technology',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            'Delivering smarter systems, stronger outcomes,\nand sustainable innovation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: UIConstants.spacingXl),
          const Divider(color: Colors.white30, thickness: 1),
          const SizedBox(height: UIConstants.spacingM),
          const Text(
            '© 2024 Amerck Care',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          const Text(
            'Version 1.0.0 • Build 2024.12.18',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  /// Build highlight item
  Widget _buildHighlight(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.spacingS),
          decoration: BoxDecoration(
            color: UIConstants.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: Icon(
            icon,
            color: UIConstants.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: UIConstants.textDark,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXs),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: UIConstants.textMedium,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build value card
  Widget _buildValueCard({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowLight,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXs),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UIConstants.textMedium,
                    height: 1.4,
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