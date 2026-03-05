import 'package:flutter/material.dart';
import 'activity_page.dart';

class PlayAndLearnMenu extends StatelessWidget {
  const PlayAndLearnMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "How to wash hands ?", "icon": Icons.back_hand, "step": 1},
      {"title": "How to brush teeth ?", "icon": Icons.brush, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
      {"title": "type hete", "icon": Icons.email_outlined, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
    ];