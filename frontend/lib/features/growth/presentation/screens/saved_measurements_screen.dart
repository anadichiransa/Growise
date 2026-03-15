import 'package:flutter/material.dart';
import '../controllers/growth_controller.dart';
import 'package:growise/data/models/growth_record.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';

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
  State<SavedMeasurementsScreen> createState() =>
      _SavedMeasurementsScreenState();
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
        title: const Text('Delete Measurement',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete measurement from ${record.date.day}/${record.date.month}/${record.date.year}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteRecord(record.id);
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
    final weightController =
        TextEditingController(text: record.weight.toString());
    final heightController =
        TextEditingController(text: record.height.toString());
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
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Measurement',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '${record.date.day}/${record.date.month}/${record.date.year}',
              style: const TextStyle(color: Color(0xFFD9A577), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _editField(
                'Weight (kg)', weightController, Icons.monitor_weight_outlined),
            const SizedBox(height: 14),
            _editField('Height (cm)', heightController, Icons.height),
            const SizedBox(height: 14),
            _editField('Notes (optional)', notesController, Icons.notes,
                maxLines: 2),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final w = double.tryParse(weightController.text.trim());
                final h = double.tryParse(heightController.text.trim());
                if (w == null || h == null) return;

                final updatedRecord = GrowthRecord(
                  id: record.id,
                  childId: widget.childId,
                  userId: record.userId,
                  date: record.date,
                  weight: w,
                  height: h,
                  bmi: record.bmi,
                  weightForAgeZ: record.weightForAgeZ,
                  heightForAgeZ: record.heightForAgeZ,
                  category: record.category,
                  recommendations: record.recommendations,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  createdAt: record.createdAt,
                );
                await _controller.updateRecord(updatedRecord);
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: maxLines == 1
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFD9A577), size: 20),
            filled: true,
            fillColor: const Color(0xFF1B0B3B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9A577)),
            ),
          ),
        ),
      ],
    );
  }

  void _viewRecord(GrowthRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3B1B45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${record.date.day}/${record.date.month}/${record.date.year}',
              style: const TextStyle(
                  color: Color(0xFFD9A577),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _viewTile(
                        'Weight',
                        '${record.weight.toStringAsFixed(1)} kg',
                        Icons.monitor_weight_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _viewTile(
                        'Height',
                        '${record.height.toStringAsFixed(0)} cm',
                        Icons.height)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _viewTile(
                        'Weight Z-Score',
                        record.weightForAgeZ?.toStringAsFixed(2) ?? 'N/A',
                        Icons.analytics_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _viewTile(
                        'Height Z-Score',
                        record.heightForAgeZ?.toStringAsFixed(2) ?? 'N/A',
                        Icons.analytics_outlined)),
              ],
            ),
            if (record.category != null) ...[
              const SizedBox(height: 12),
              _viewTile(
                  'Status',
                  record.category!.replaceAll('_', ' ').toUpperCase(),
                  Icons.flag_outlined),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _viewTile('Notes', record.notes!, Icons.notes),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _viewTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0B3B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD9A577), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? category) {
    switch (category) {
      case 'healthy':
        return const Color(0xFF2E7D32);
      case 'stunting':
      case 'wasting':
        return const Color(0xFFF57F17);
      case 'severe_stunting':
      case 'severe_wasting':
        return const Color(0xFFC62828);
      case 'overweight':
        return const Color(0xFFE65100);
      default:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0B3B),
      bottomNavigationBar: AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('${widget.childName}\'s Measurements',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  Text('${_records.length} records',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFD9A577)))
                  : _records.isEmpty
                      ? const Center(
                          child: Text('No saved measurements yet.',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final record = _records[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B1B45),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _statusColor(record.category)
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _statusColor(record.category)),
                                  ),
                                  child: Icon(Icons.show_chart,
                                      color: _statusColor(record.category),
                                      size: 20),
                                ),
                                title: Text(
                                  '${record.date.day}/${record.date.month}/${record.date.year}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${record.weight.toStringAsFixed(1)} kg  •  ${record.height.toStringAsFixed(0)} cm  •  ${record.category?.replaceAll('_', ' ') ?? ''}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // View
                                    GestureDetector(
                                      onTap: () => _viewRecord(record),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                            Icons.visibility_outlined,
                                            color: Colors.white54,
                                            size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Edit
                                    GestureDetector(
                                      onTap: () => _editRecord(record),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD9A577)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.edit_outlined,
                                            color: Color(0xFFD9A577), size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete
                                    GestureDetector(
                                      onTap: () => _deleteRecord(record),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF5350)
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.delete_outline,
                                            color: Color(0xFFEF5350), size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
