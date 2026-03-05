import 'package:flutter/material.dart';
import '../../controllers/growth_controller.dart';
import '../../models/growth_record_model.dart';
import '../../components/common/bottom_nav.dart';

class SavedMeasurementsScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String gender;
  final DateTime dateOfBirth;

  const SavedMeasurementsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
    required this.dateOfBirth,
  });