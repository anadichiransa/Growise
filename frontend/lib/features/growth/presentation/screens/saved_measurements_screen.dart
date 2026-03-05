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

    @override
  State<SavedMeasurementsScreen> createState() => _SavedMeasurementsScreenState();
}

class _SavedMeasurementsScreenState extends State<SavedMeasurementsScreen> {
  final GrowthController _controller = GrowthController();
  List<GrowthRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await _controller.loadRecords(widget.childId);
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _records = records);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(GrowthRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3B1B45),
        title: const Text('Delete Measurement', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete measurement from ${record.date.day}/${record.date.month}/${record.date.year}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteRecord(record.id, widget.childId);
      _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Measurement deleted'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _editRecord(GrowthRecord record) {
    final weightController = TextEditingController(text: record.weight.toString());
    final heightController = TextEditingController(text: record.height.toString());
    final notesController = TextEditingController(text: record.notes ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3B1B45),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Measurement',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '${record.date.day}/${record.date.month}/${record.date.year}',
              style: const TextStyle(color: Color(0xFFD9A577), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _editField('Weight (kg)', weightController, Icons.monitor_weight_outlined),
            const SizedBox(height: 14),
            _editField('Height (cm)', heightController, Icons.height),
            const SizedBox(height: 14),
            _editField('Notes (optional)', notesController, Icons.notes, maxLines: 2),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final w = double.tryParse(weightController.text.trim());
                final h = double.tryParse(heightController.text.trim());
                if (w == null || h == null) return;

                await _controller.updateRecord(
                  recordId: record.id,
                  childId: widget.childId,
                  gender: widget.gender,
                  dateOfBirth: widget.dateOfBirth,
                  date: record.date,
                  weight: w,
                  height: h,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadRecords();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('✅ Measurement updated!'),
                    backgroundColor: Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }