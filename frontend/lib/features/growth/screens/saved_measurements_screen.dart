import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/growth_record_model.dart';
import '../controllers/growth_controller.dart';

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
        backgroundColor: AppColours.deepMagenta,
        title: const Text('Delete Measurement',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete measurement from ${record.date.day}/${record.date.month}/${record.date.year}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
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
    final wCtrl = TextEditingController(text: record.weight.toString());
    final hCtrl = TextEditingController(text: record.height.toString());
    final nCtrl = TextEditingController(text: record.notes ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColours.deepMagenta,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      // Bug #7 fix: use StatefulBuilder so we can toggle a loading state inside
      // the bottom sheet — prevents multiple taps on Save while the API call runs
      builder: (ctx) {
        // Declared outside the builder so it persists across setSheetState() rebuilds
        bool isUpdating = false;
        return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Edit Measurement',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${record.date.day}/${record.date.month}/${record.date.year}',
                  style: TextStyle(color: AppColours.primaryGold, fontSize: 13)),
              const SizedBox(height: 20),
              _editField('Weight (kg)', wCtrl, Icons.monitor_weight_outlined),
              const SizedBox(height: 14),
              _editField('Height (cm)', hCtrl, Icons.height),
              const SizedBox(height: 14),
              _editField('Notes (optional)', nCtrl, Icons.notes, maxLines: 2),
              const SizedBox(height: 24),
              ElevatedButton(
                // Disable button while update is in progress
                onPressed: isUpdating ? null : () async {
                  final w = double.tryParse(wCtrl.text.trim());
                  final h = double.tryParse(hCtrl.text.trim());
                  if (w == null || h == null) return;
                  setSheetState(() => isUpdating = true);
                  try {
                    await _controller.updateRecord(
                      recordId: record.id, childId: widget.childId,
                      gender: widget.gender, dateOfBirth: widget.dateOfBirth,
                      date: record.date, weight: w, height: h,
                      notes: nCtrl.text.trim().isEmpty ? null : nCtrl.text.trim(),
                    );
                   if (ctx.mounted) { Navigator.pop(ctx); }
                    _loadRecords();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Measurement updated!'),
                            backgroundColor: Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating));
                    }
                  } catch (_) {
                    setSheetState(() => isUpdating = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update. Try again.'),
                            backgroundColor: Color(0xFFC62828),
                            behavior: SnackBarBehavior.floating));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  disabledBackgroundColor: Colors.orange.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: isUpdating
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5))
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ]),
          );
        },
        );
      },
    );
  }


  Widget _editField(String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, maxLines: maxLines,
        keyboardType: maxLines == 1
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColours.primaryGold, size: 20),
          filled: true, fillColor: AppColours.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColours.primaryGold)),
        ),
      ),
    ]);
  }

  Color _statusColor(String? c) {
    switch (c) {
      case 'healthy':           return const Color(0xFF2E7D32);
      case 'stunting':
      case 'wasting':           return const Color(0xFFF57F17);
      case 'severe_stunting':
      case 'severe_wasting':    return const Color(0xFFC62828);
      case 'overweight':        return const Color(0xFFE65100);
      default:                  return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
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
              Expanded(child: Text('${widget.childName}\'s Measurements',
                  style: const TextStyle(fontSize: 17,
                      fontWeight: FontWeight.bold, color: Colors.white))),
              Text('${_records.length} records',
                  style: const TextStyle(color: Colors.white38, fontSize: 13)),
            ]),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFFD9A577)))
                : _records.isEmpty
                    ? const Center(child: Text('No saved measurements yet.',
                        style: TextStyle(color: Colors.white54, fontSize: 15)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final r = _records[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColours.deepMagenta,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: _statusColor(r.category)
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _statusColor(r.category)),
                                ),
                                child: Icon(Icons.show_chart,
                                    color: _statusColor(r.category), size: 20),
                              ),
                              title: Text(
                                '${r.date.day}/${r.date.month}/${r.date.year}',
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${r.weight.toStringAsFixed(1)} kg  •  '
                                '${r.height.toStringAsFixed(0)} cm  •  '
                                '${r.category?.replaceAll('_', ' ') ?? ''}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                              trailing: Row(mainAxisSize: MainAxisSize.min,
                                  children: [
                                _actionBtn(Icons.edit_outlined,
                                    AppColours.primaryGold.withValues(alpha: 0.15),
                                    AppColours.primaryGold,
                                    () => _editRecord(r)),
                                const SizedBox(width: 8),
                                _actionBtn(Icons.delete_outline,
                                    const Color(0xFFEF5350).withValues(alpha: 0.15),
                                    const Color(0xFFEF5350),
                                    () => _deleteRecord(r)),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color bg, Color iconColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}