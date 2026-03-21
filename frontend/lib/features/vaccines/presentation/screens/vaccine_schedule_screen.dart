import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vaccine_controller.dart';
import '../widgets/age_group_header.dart';
import '../widgets/vaccine_card.dart';
import '../widgets/mark_done_sheet.dart';
import '../widgets/vaccine_details_sheet.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineScheduleScreen extends StatefulWidget {
  const VaccineScheduleScreen({super.key});

  @override
  State<VaccineScheduleScreen> createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen> {
  late ChildController _childController;
  String _childId = '';
  String _childName = 'Your Child';
  int _childAgeMonths = 0;
  bool _childReady = false;

  @override
  void initState() {
    super.initState();
    _childController = Get.find<ChildController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWithRetry();
    });
  }

  void _loadWithRetry({int attempt = 1}) {
    final id = _childController.childId ?? '';
    final name = _childController.childName ?? 'Your Child';
    final rawDate = _childController.child?['birthDate'];
    final DateTime? birthDate = rawDate is Timestamp
        ? rawDate.toDate()
        : (rawDate is DateTime ? rawDate : null);
    final now = DateTime.now();
    final ageMonths = birthDate != null
        ? (now.year - birthDate.year) * 12 + now.month - birthDate.month
        : 0;

    if (id.isNotEmpty) {
      if (mounted) {
        setState(() {
          _childId = id;
          _childName = name;
          _childAgeMonths = ageMonths;
          _childReady = true;
        });
        context.read<VaccineController>().loadSchedule(id);
      }
    } else if (attempt < 5) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _loadWithRetry(attempt: attempt + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Immunization Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: !_childReady
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : Consumer<VaccineController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  );
                }
                if (controller.error != null) {
                  return Center(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Column(
                  children: [
                    _buildChildHeader(),
                    const Divider(color: Colors.white12, height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 32),
                        itemCount: controller.groupedSchedule.length,
                        itemBuilder: (context, index) {
                          final group = controller.groupedSchedule[index];
                          final isDueNow = group.vaccines.any(
                            (v) =>
                                v.status == 'pending' &&
                                v.daysUntilDue != null &&
                                v.daysUntilDue! <= 0,
                          );
                          final isLocked =
                              group.ageMonths > _childAgeMonths + 1;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AgeGroupHeader(
                                ageLabel: group.ageLabel,
                                allDone: group.allDone,
                                isDueNow: isDueNow,
                                isLocked: isLocked,
                              ),
                              ...group.vaccines.map(
                                (vaccine) => VaccineCard(
                                  record: vaccine,
                                  onMarkDone: () => _showMarkDoneSheet(vaccine),
                                  onDetails: () => _showDetailsSheet(vaccine),
                                ),
                              ),
                              if (isLocked) _buildProgressBar(group.ageLabel),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildChildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Obx(() {
            final isGirl =
                Get.find<ChildController>().childGender.toLowerCase() == 'girl';
            return CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2A1245),
              child: Icon(
                isGirl ? Icons.face_2 : Icons.face,
                color: Colors.white,
                size: 26,
              ),
            );
          }),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _childName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '$_childAgeMonths Months Old',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Locked until $label',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.3,
              backgroundColor: Color(0xFF4A2574),
              valueColor: AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkDoneSheet(vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarkDoneBottomSheet(
        vaccineName: vaccine.vaccineName,
        onSubmit: (data) {
          context.read<VaccineController>().markVaccineDone(
            _childId,
            vaccine.vaccineId,
            data,
          );
        },
      ),
    );
  }

  void _showDetailsSheet(vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VaccineDetailsSheet(record: vaccine),
    );
  }
}
