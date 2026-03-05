import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; //

class ActivityPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String videoPath;

  const ActivityPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.videoPath,
  });