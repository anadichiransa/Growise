// ─── FILE: frontend/lib/features/support/presentation/controllers/support_controller.dart ───

// url_launcher is the package we just added in pubspec.yaml.
// It gives us canLaunchUrl() and launchUrl() functions.
import 'package:url_launcher/url_launcher.dart';

// GetX is your project's state management library (already in pubspec.yaml).
// GetxController is the base class for all GetX controllers.
// Get.snackbar() is a GetX function that shows a small message to the user.
import 'package:flutter/material.dart'; // needed for Color in snackbar
import 'package:get/get.dart';

// Think of a Controller like a "manager" for a screen.
// The screen (View) only DRAWS things.
// The controller DOES the work — opening dialers, launching email, etc.
// This separation is called MVC (Model-View-Controller).
//
// Why GetxController instead of a plain Dart class?
//   A plain Dart class would work fine here since we're not managing
//   reactive state. BUT GetxController gives us Get.put() / Get.find()
//   which lets any widget access this controller without passing it around
//   through constructor parameters. Your project already uses GetX everywhere,
//   so we stay consistent.
class SupportController extends GetxController {

  // ── Contact details defined HERE, not in the UI file ──────────────────────
  //
  // This is called "Single Source of Truth".
  // If your phone number changes next year, you change it in ONE place
  // (here), instead of hunting through UI files.
  //
  // The underscore prefix means these are PRIVATE to this class.
  // No other file can accidentally read or change them.
  //
  // 'static' means these belong to the CLASS itself, not to any instance.
  // You can think of 'static const' as a fixed label attached to the class.
  static const String _helplineNumber = '+94112345678';
  static const String _supportEmail   = 'support@growise.com';
  static const String _communityUrl   = 'https://community.growise.com';

  // ── HELPLINE ───────────────────────────────────────────────────────────────
  //
  // 'Future<void>' means: this function is ASYNCHRONOUS (it does something
  // that takes a tiny bit of time — asking the OS to open an app).
  // 'void' means it doesn't return any value when it finishes.
  //
  // Why async at all? canLaunchUrl() and launchUrl() talk to the OS,
  // and talking to the OS is always async in Flutter.
  Future<void> launchHelpline() async {

    // Uri() is a Dart built-in class that represents a URI.
    // We build it piece by piece:
    //   scheme: 'tel'        ← tells the OS "this is a phone number"
    //   path: _helplineNumber ← the actual number
    // The result is the URI: tel:+94112345678
    //
    // Alternative: Uri.parse('tel:+94112345678') also works —
    // but Uri() with named params is clearer about what each part means.
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: _helplineNumber,
    );

    // canLaunchUrl() asks the OS: "Do you have an app that handles tel: URIs?"
    // On a real Android/iOS phone: YES (the Phone app handles tel:)
    // On an emulator without phone features: sometimes NO
    // On a tablet without a SIM: sometimes NO
    //
    // We check FIRST so we can show the user a helpful message instead
    // of crashing. This is called "defensive programming" — always check
    // before assuming something will work.
    //
    // 'await' means: "wait for this to finish before moving to the next line".
    // Without await, the code would rush past before the OS answers.
    if (await canLaunchUrl(phoneUri)) {

      // launchUrl() tells the OS: "Open this URI please."
      // The OS looks at 'tel:' and knows to open the Phone dialer.
      //
      // LaunchMode.externalApplication means: open it in a SEPARATE app
      // (outside our Flutter app). This is what we want for phone calls
      // because we can't embed a phone dialer inside Flutter.
      //
      // Alternative: LaunchMode.inAppWebView opens a mini-browser INSIDE
      // our app. That's for websites only, not phone calls or email.
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);

    } else {
      // Get.snackbar() shows a small notification bar at the bottom.
      // It's GetX's way to show messages without needing a BuildContext.
      //
      // Alternative: ScaffoldMessenger.of(context).showSnackBar(...)
      // That works too, but requires passing 'context' all the way from
      // the widget tree into this controller. GetX avoids that complexity.
      Get.snackbar(
        'Cannot Open Dialer',                           // title
        'No phone app found. Call us at $_helplineNumber', // body
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E1A72),       // your cardSurface colour
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  // ── EMAIL ──────────────────────────────────────────────────────────────────
  Future<void> launchEmail() async {

    // mailto: URI scheme opens email apps.
    // queryParameters lets us PRE-FILL the subject and body.
    //
    // Why pre-fill the body?
    // Without this, support emails arrive saying "it's broken" with zero context.
    // Pre-filling prompts the user to give you useful information.
    //
    // queryParameters: is a Map<String, String> that gets encoded
    // into the URI like: mailto:support@growise.com?subject=...&body=...
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
        // 5 seconds so user has time to read and note the email address
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  // ── COMMUNITY ──────────────────────────────────────────────────────────────
  Future<void> launchCommunity() async {

    // For a regular https:// URL, Uri.parse() is simpler than Uri() constructor.
    // Uri.parse() takes the whole string and figures out the parts automatically.
    final Uri communityUri = Uri.parse(_communityUrl);

    if (await canLaunchUrl(communityUri)) {
      // We use externalApplication (real browser) instead of inAppWebView because:
      // 1. The community site likely has logins — user wants their saved password
      // 2. Users trust their own browser for social/community content
      // 3. inAppWebView doesn't share cookies with Chrome/Safari
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

  // ── LIVE CHAT (not implemented yet) ───────────────────────────────────────
  //
  // No async here — we're just showing a snackbar immediately.
  // Nothing to wait for.
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