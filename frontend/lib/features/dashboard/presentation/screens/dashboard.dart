import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';

class BabyTrackerHome extends StatefulWidget {
  const BabyTrackerHome({super.key});

  @override
  State<BabyTrackerHome> createState() => _BabyTrackerHomeState();
}

class _BabyTrackerHomeState extends State<BabyTrackerHome> {
  @override
  void initState() {
    super.initState();
    // Refresh child data when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChildController>().loadChildren();
    });
  }
