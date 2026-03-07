import 'package:flutter/material.dart';

class HelpRecoveryScreen extends StatefulWidget {
  const HelpRecoveryScreen({super.key});

  @override
  State<HelpRecoveryScreen> createState() => _HelpRecoveryScreenState();
}

class _HelpRecoveryScreenState extends State<HelpRecoveryScreen> {
  final List<Map<String, dynamic>> _allHelpItems = [
    {
      "title": "How to reset my password?",
      "icon": Icons.vpn_key_outlined,
      "content": "To reset your password, tap on 'Forgot Password' on the login screen. Enter your registered email address, and we will send you a link to set a new password.",
      "isExpanded": true,
    },
    {
      "title": "Didn't receive reset email?",
      "icon": Icons.email_outlined,
      "content": "Check your spam folder. If it's not there, wait 5 minutes before requesting a new link. Ensure your email matches your registered account.",
      "isExpanded": false,
    },
    {
      "title": "How to recover my username?",
      "icon": Icons.person_outline,
      "content": "Tap 'Forgot Username' on the login page. We will send your username to your registered mobile number via SMS.",
      "isExpanded": false,
    },
    {
      "title": "Account lockout issues",
      "icon": Icons.shield_outlined,
      "content": "Accounts are temporarily locked after 5 failed attempts. Please wait 30 minutes or contact support to verify your identity.",
      "isExpanded": false,
    },
  ];

  late List<Map<String, dynamic>> _filteredItems;
  String _searchQuery = "";
