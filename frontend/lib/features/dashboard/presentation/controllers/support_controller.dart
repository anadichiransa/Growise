import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportController extends GetxController {
  static const String _helplineNumber = '+94112345678';
  static const String _supportEmail   = 'support@growise.com';
  static const String _communityUrl   = 'https://community.growise.com';

  Future<void> launchHelpline() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: _helplineNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open Dialer',
        'No phone app found. Call us at $_helplineNumber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E1A72),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Growise Support Request',
        'body':
            'Hi Growise Support Team,\n\n'
            'I need help with:\n\n'
            '[Please describe your issue here]\n\n'
            '---\n'
            'App Version: 1.0.0\n'
            'Device: [Your device model]',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open Email',
        'Email us directly at $_supportEmail',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E1A72),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  Future<void> launchCommunity() async {
    final Uri communityUri = Uri.parse(_communityUrl);

    if (await canLaunchUrl(communityUri)) {
      await launchUrl(communityUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Cannot Open Browser',
        'Visit us at $_communityUrl',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E1A72),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  void showLiveChatComingSoon() {
    Get.snackbar(
      'Coming Soon 🚀',
      'Live Chat will be available in the next update.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E1A72),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}