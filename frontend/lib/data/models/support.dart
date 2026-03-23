import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// ── Models ─────────────────────────────────────────────────────────────────────

class FaqItem {
  final String id;
  final String category;
  final IconData icon;
  final String title;
  final String answer;

  const FaqItem({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'],
        category: json['category'],
        icon: _iconFromName(json['icon']),
        title: json['title'],
        answer: json['answer'],
      );

  // Maps the string returned by the API to a Flutter IconData.
  // Add more entries here as you expand the FAQ list.
  static IconData _iconFromName(String name) {
    const map = <String, IconData>{
      'vaccines_outlined':        Icons.vaccines_outlined,
      'lock_reset_outlined':      Icons.lock_reset_outlined,
      'visibility_off_outlined':  Icons.visibility_off_outlined,
      'monitor_weight_outlined':  Icons.monitor_weight_outlined,
      'notifications_outlined':   Icons.notifications_outlined,
      'shield':                   Icons.shield_outlined,
      'credit_card':              Icons.credit_card_outlined,
      'build':                    Icons.build_outlined,
      'report':                   Icons.report_outlined,
      'lock':                     Icons.lock_outlined,
      'help':                     Icons.help_outline,
    };
    return map[name] ?? Icons.help_outline;
  }
}

class ContactInfo {
  final String helpline;
  final String helplineTel;
  final String email;
  final String emailMailto;
  final bool liveChatOnline;
  final String communityUrl;

  const ContactInfo({
    required this.helpline,
    required this.helplineTel,
    required this.email,
    required this.emailMailto,
    required this.liveChatOnline,
    required this.communityUrl,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        helpline:      json['helpline'],
        helplineTel:   json['helpline_tel'],
        email:         json['email'],
        emailMailto:   json['email_mailto'],
        liveChatOnline: json['live_chat_online'] ?? false,
        communityUrl:  json['community_url'],
      );
}

// ── Controller ─────────────────────────────────────────────────────────────────

class SupportController extends GetxController {
  // ── Replace with your deployed API base URL ──────────────────────────────────
  static const String _base = 'https://your-api.com/api/v1';

  // Observables consumed directly by the UI
  final RxList<FaqItem> faqs          = <FaqItem>[].obs;
  final Rx<ContactInfo?> contactInfo  = Rx<ContactInfo?>(null);
  final RxBool loadingFaqs            = true.obs;
  final RxBool loadingContact         = true.obs;
  final RxString error                = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> refresh() => _loadAll();

  void launchHelpline() {
    final tel = contactInfo.value?.helplineTel;
    if (tel == null) return;
    _launch(tel, label: 'helpline');
  }

  void launchEmail() {
    final mailto = contactInfo.value?.emailMailto;
    if (mailto == null) return;
    _launch(mailto, label: 'email');
  }

  void launchCommunity() {
    final url = contactInfo.value?.communityUrl;
    if (url == null) return;
    _launch(url, label: 'community');
  }

  void showLiveChatComingSoon() {
    Get.snackbar(
      'Live Chat',
      'Our live chat is currently unavailable. Please try email or helpline.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E1558),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    await Future.wait([_fetchFaqs(), _fetchContactInfo()]);
  }

  Future<void> _fetchFaqs() async {
    loadingFaqs.value = true;
    try {
      final res = await http.get(Uri.parse('$_base/support/faqs'));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        faqs.value = list.map((e) => FaqItem.fromJson(e)).toList();
      } else {
        error.value = 'Could not load FAQs (${res.statusCode})';
      }
    } catch (e) {
      error.value = 'Network error: $e';
    } finally {
      loadingFaqs.value = false;
    }
  }

  Future<void> _fetchContactInfo() async {
    loadingContact.value = true;
    try {
      final res = await http.get(Uri.parse('$_base/support/contact-info'));
      if (res.statusCode == 200) {
        contactInfo.value = ContactInfo.fromJson(jsonDecode(res.body));
      }
    } catch (_) {
      // Non-fatal — UI can still render with fallback values
    } finally {
      loadingContact.value = false;
    }
  }

  Future<void> _launch(String urlString, {required String label}) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Oops',
        'Could not open $label. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E1558),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // ── Ticket submission (used by a separate Submit Ticket screen) ───────────────

  Future<bool> submitTicket({
    required String category,
    required String subject,
    required String description,
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('$_base/support/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category': category,
          'subject': subject,
          'description': description,
        }),
      );

      if (res.statusCode == 201) {
        Get.snackbar(
          'Ticket submitted',
          'We\'ll get back to you within 24 hours.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF04E8C0).withOpacity(0.15),
          colorText: const Color(0xFF04E8C0),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
