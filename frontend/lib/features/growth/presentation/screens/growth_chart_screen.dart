import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/common/status_banner.dart';
import '../../controllers/growth_controller.dart';
import '../../models/growth_record_model.dart';
import '../../components/common/bottom_nav.dart';
import 'add_measurement_screen.dart';
import 'saved_measurements_screen.dart';

class GrowthChartScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String gender;
  final DateTime dateOfBirth;

  const GrowthChartScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
    required this.dateOfBirth,
  });