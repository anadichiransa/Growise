// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../core/constants/colors.dart';
// import '../../data/models/growth_record_model.dart';
// import '../../data/models/who_standard_model.dart';
// import '../../data/repositories/api_service.dart';
// import '../../features/growth/controllers/growth_controller.dart';
// import '../../features/growth/screens/add_measurement_screen.dart';
// import '../../features/growth/screens/saved_measurements_screen.dart';

// class GrowthChartScreen extends StatefulWidget {
//   final String childId;
//   final String childName;
//   final String gender;
//   final DateTime dateOfBirth;

//   const GrowthChartScreen({
//     super.key,
//     required this.childId,
//     required this.childName,
//     required this.gender,
//     required this.dateOfBirth,
//   });

//   @override
//   State<GrowthChartScreen> createState() => _GrowthChartScreenState();
// }

// class _GrowthChartScreenState extends State<GrowthChartScreen>
//     with SingleTickerProviderStateMixin {
//   final GrowthController _controller = GrowthController();
//   late TabController _tabController;

//   List<GrowthRecord> _records    = [];
//   WHOStandardsData?  _whoData;
//   bool _isLoading                = true;
//   bool _whoLoading               = true;
//   String _errorMessage           = '';
//   String _whoError               = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadAll();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   /// Load growth records AND WHO standards in parallel
//   Future<void> _loadAll() async {
//     setState(() { _isLoading = true; _whoLoading = true;
//                   _errorMessage = ''; _whoError = ''; });
//     await Future.wait([_loadRecords(), _loadWHOData()]);
//   }

//   Future<void> _loadRecords() async {
//     try {
//       final records = await _controller.loadRecords(widget.childId);
//       records.sort((a, b) => b.date.compareTo(a.date));
//       setState(() { _records = records; _isLoading = false; });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load records. Please try again.';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadWHOData() async {
//     try {
//       final data = await ApiService.getWHOStandardsBoys();
//       setState(() { _whoData = data; _whoLoading = false; });
//     } catch (e) {
//       setState(() {
//         _whoError   = 'WHO data unavailable. Check backend connection.';
//         _whoLoading = false;
//       });
//     }
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────

//   GrowthRecord? get _latestRecord => _records.isNotEmpty ? _records.first : null;
//   String get _currentStatus      => _latestRecord?.category ?? 'unknown';

//   String get _summary {
//     if (_latestRecord == null) return 'No measurements yet. Add your first measurement!';
//     return _controller.generateSummary(
//       category:  _currentStatus,
//       weightZ:   _latestRecord!.weightForAgeZ,
//       heightZ:   _latestRecord!.heightForAgeZ,
//       childName: widget.childName,
//     );
//   }

//   List<String> get _recommendations =>
//       _latestRecord == null ? [] : _controller.getRecommendations(_currentStatus);

//   int _ageInMonths(DateTime date) {
//     int m = (date.year - widget.dateOfBirth.year) * 12;
//     m += date.month - widget.dateOfBirth.month;
//     if (date.day < widget.dateOfBirth.day) m--;
//     return m.clamp(0, 24);
//   }

//   double? _bmi(double weight, double height) {
//     if (height <= 0) return null;
//     final hm = height / 100;
//     return weight / (hm * hm);
//   }

//   Color _statusColor(String? c) {
//     switch (c) {
//       case 'healthy':         return const Color(0xFF4CAF50);
//       case 'stunting':
//       case 'wasting':         return const Color(0xFFF57F17);
//       case 'severe_stunting':
//       case 'severe_wasting':  return const Color(0xFFC62828);
//       case 'overweight':      return const Color(0xFFE65100);
//       default:                return const Color(0xFF4CAF50);
//     }
//   }

//   String _statusLabel(String? c) {
//     switch (c) {
//       case 'healthy':         return 'Normal';
//       case 'stunting':        return 'Stunting';
//       case 'wasting':         return 'Wasting (MAM)';
//       case 'severe_stunting': return 'Severe Stunting';
//       case 'severe_wasting':  return 'SAM';
//       case 'overweight':      return 'Overweight';
//       default:                return 'Unknown';
//     }
//   }

//   String _zLabel(double? z) {
//     if (z == null) return 'N/A';
//     if (z >= -1 && z <= 1) return 'Normal';
//     if (z < -3)            return 'Severely low';
//     if (z < -2)            return 'Low';
//     if (z > 3)             return 'Very high';
//     if (z > 2)             return 'High';
//     return 'Normal';
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B0B3B),
//       bottomNavigationBar: AppBottomNav(currentIndex: 1),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // App bar
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _iconBtn(Icons.arrow_back, Colors.white12,
//                       () => Navigator.pop(context)),
//                   Text('${widget.childName}\'s Growth',
//                       style: const TextStyle(fontSize: 18,
//                           fontWeight: FontWeight.bold, color: Colors.white)),
//                   _iconBtn(Icons.add, const Color(0xFFD9A577), () async {
//                     await Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => AddMeasurementScreen(
//                         childId: widget.childId, childName: widget.childName,
//                         gender: widget.gender, dateOfBirth: widget.dateOfBirth,
//                       ),
//                     ));
//                     _loadAll();
//                   }),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: (_isLoading || _whoLoading)
//                   ? const Center(child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircularProgressIndicator(color: Color(0xFFD9A577)),
//                         SizedBox(height: 16),
//                         Text('Loading growth data...',
//                             style: TextStyle(color: Colors.white54)),
//                       ],
//                     ))
//                   : _errorMessage.isNotEmpty
//                       ? _buildErrorState()
//                       : _records.isEmpty
//                           ? _buildEmptyState()
//                           : _buildChartView(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── States ────────────────────────────────────────────────────────────────

//   Widget _buildErrorState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(Icons.error_outline, color: Color(0xFFD9A577), size: 60),
//         const SizedBox(height: 16),
//         Text(_errorMessage, textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70, fontSize: 15)),
//         const SizedBox(height: 24),
//         ElevatedButton(
//           onPressed: _loadAll,
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
//           child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       ],
//     ),
//   );

//   Widget _buildEmptyState() => Center(
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: const BoxDecoration(
//                 color: Color(0xFF3B1B45), shape: BoxShape.circle),
//             child: const Icon(Icons.show_chart, size: 70, color: Color(0xFFD9A577)),
//           ),
//           const SizedBox(height: 24),
//           const Text('No measurements yet',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
//                   color: Colors.white)),
//           const SizedBox(height: 10),
//           const Text('Start tracking your baby\'s growth\nusing WHO standards',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.5)),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: () async {
//               await Navigator.push(context, MaterialPageRoute(
//                 builder: (_) => AddMeasurementScreen(
//                   childId: widget.childId, childName: widget.childName,
//                   gender: widget.gender, dateOfBirth: widget.dateOfBirth,
//                 ),
//               ));
//               _loadAll();
//             },
//             icon: const Icon(Icons.add),
//             label: const Text('Add First Measurement',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange, foregroundColor: Colors.black,
//               minimumSize: const Size(double.infinity, 58),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );

//   // ── Main Chart View ───────────────────────────────────────────────────────

//   Widget _buildChartView() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           StatusBanner(status: _currentStatus, summary: _summary),
//           const SizedBox(height: 16),
//           if (_latestRecord != null) _buildLatestCallout(),
//           const SizedBox(height: 16),
//           _buildTabBar(),
//           const SizedBox(height: 16),

//           // WHO error banner
//           if (_whoError.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFC62828).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.5)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.warning_amber_rounded,
//                       color: Color(0xFFEF5350), size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(child: Text(_whoError,
//                       style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12))),
//                 ],
//               ),
//             ),

//           // Charts
//           SizedBox(
//             height: 420,
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildWeightChart(),
//                 _buildHeightChart(),
//                 _buildBMIChart(),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),
//           if (_latestRecord != null) _buildSummaryTable(),
//           const SizedBox(height: 16),
//           _buildMetricsCard(),
//           const SizedBox(height: 16),
//           if (_recommendations.isNotEmpty) _buildRecommendationsCard(),
//           const SizedBox(height: 16),

//           ElevatedButton.icon(
//             onPressed: () async {
//               await Navigator.push(context, MaterialPageRoute(
//                 builder: (_) => AddMeasurementScreen(
//                   childId: widget.childId, childName: widget.childName,
//                   gender: widget.gender, dateOfBirth: widget.dateOfBirth,
//                 ),
//               ));
//               _loadAll();
//             },
//             icon: const Icon(Icons.add),
//             label: const Text('Add Measurement',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange, foregroundColor: Colors.black,
//               minimumSize: const Size(double.infinity, 58),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//             ),
//           ),
//           const SizedBox(height: 12),

//           OutlinedButton.icon(
//             onPressed: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) => SavedMeasurementsScreen(
//                 childId: widget.childId, childName: widget.childName,
//                 gender: widget.gender, dateOfBirth: widget.dateOfBirth,
//               ),
//             )).then((_) => _loadAll()),
//             icon: const Icon(Icons.list_alt, color: Color(0xFFD9A577)),
//             label: const Text('View Saved Measurements',
//                 style: TextStyle(color: Color(0xFFD9A577),
//                     fontWeight: FontWeight.bold)),
//             style: OutlinedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 52),
//               side: const BorderSide(color: Color(0xFFD9A577)),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//             ),
//           ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }

//   // ── Tab Bar ───────────────────────────────────────────────────────────────

//   Widget _buildTabBar() {
//     return AnimatedBuilder(
//       animation: _tabController,
//       builder: (context, _) => Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A1040),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white10),
//         ),
//         padding: const EdgeInsets.all(4),
//         child: Row(children: [
//           _tabItem(0, 'Weight/Age',  Icons.monitor_weight_outlined),
//           _tabItem(1, 'Height/Age',  Icons.height),
//           _tabItem(2, 'BMI/Age',     Icons.analytics_outlined),
//         ]),
//       ),
//     );
//   }

//   Widget _tabItem(int index, String label, IconData icon) {
//     final sel = _tabController.index == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _tabController.animateTo(index)),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           padding: EdgeInsets.symmetric(vertical: sel ? 14 : 10, horizontal: 4),
//           decoration: BoxDecoration(
//             color: sel ? const Color(0xFFD9A577) : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: sel ? [BoxShadow(
//               color: const Color(0xFFD9A577).withOpacity(0.35),
//               blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 3),
//             )] : [],
//           ),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Icon(icon, size: sel ? 20 : 17,
//                 color: sel ? Colors.black : Colors.white38),
//             const SizedBox(height: 4),
//             Text(label, textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: sel ? 11 : 10,
//                     fontWeight: sel ? FontWeight.bold : FontWeight.normal,
//                     color: sel ? Colors.black : Colors.white38)),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ── WHO Chart Builder ─────────────────────────────────────────────────────

//   Widget _buildWHOChart({
//     required String title,
//     required String yLabel,
//     required List<WHOStandardEntry>? whoEntries,
//     required List<FlSpot> babySpots,
//     required double minY,
//     required double maxY,
//     required double yInterval,
//   }) {
//     // If WHO data unavailable show a fallback message
//     if (whoEntries == null || whoEntries.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: const Color(0xFF3B1B45),
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.cloud_off, color: Colors.white38, size: 40),
//               SizedBox(height: 12),
//               Text('WHO reference data unavailable',
//                   style: TextStyle(color: Colors.white54)),
//               SizedBox(height: 4),
//               Text('Check backend connection and run seed_who_data.py',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.white38, fontSize: 11)),
//             ],
//           ),
//         ),
//       );
//     }

//     List<FlSpot> m3  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus3)).toList();
//     List<FlSpot> m2  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus2)).toList();
//     List<FlSpot> m1  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus1)).toList();
//     List<FlSpot> med = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.median)).toList();
//     List<FlSpot> p1  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus1)).toList();
//     List<FlSpot> p2  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus2)).toList();
//     List<FlSpot> p3  = whoEntries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus3)).toList();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF3B1B45),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             Expanded(child: Text(title,
//                 style: const TextStyle(color: Colors.white, fontSize: 12,
//                     fontWeight: FontWeight.bold))),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD9A577).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFD9A577).withOpacity(0.5)),
//               ),
//               child: const Text('WHO 2006',
//                   style: TextStyle(color: Color(0xFFD9A577), fontSize: 9,
//                       fontWeight: FontWeight.bold)),
//             ),
//           ]),
//           const SizedBox(height: 2),
//           const Text('Boys · 0–24 months',
//               style: TextStyle(color: Colors.white38, fontSize: 10)),
//           const SizedBox(height: 12),

//           Expanded(
//             child: LineChart(LineChartData(
//               minX: 0, maxX: 24,
//               minY: minY, maxY: maxY,
//               clipData: const FlClipData.all(),

//               gridData: FlGridData(
//                 show: true,
//                 horizontalInterval: yInterval,
//                 verticalInterval: 3,
//                 getDrawingHorizontalLine: (_) =>
//                     FlLine(color: Colors.white.withOpacity(0.07), strokeWidth: 0.8),
//                 getDrawingVerticalLine: (_) =>
//                     FlLine(color: Colors.white.withOpacity(0.07), strokeWidth: 0.8),
//               ),

//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   axisNameWidget: Text(yLabel,
//                       style: const TextStyle(color: Colors.white54, fontSize: 9)),
//                   axisNameSize: 18,
//                   sideTitles: SideTitles(
//                     showTitles: true, reservedSize: 30, interval: yInterval,
//                     getTitlesWidget: (v, _) => Text(
//                         v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
//                         style: const TextStyle(color: Colors.white54, fontSize: 9)),
//                   ),
//                 ),
//                 bottomTitles: AxisTitles(
//                   axisNameWidget: const Text('Age (months)',
//                       style: TextStyle(color: Colors.white54, fontSize: 9)),
//                   axisNameSize: 16,
//                   sideTitles: SideTitles(
//                     showTitles: true, reservedSize: 22, interval: 3,
//                     getTitlesWidget: (v, _) => Text('${v.toInt()}',
//                         style: const TextStyle(color: Colors.white54, fontSize: 9)),
//                   ),
//                 ),
//                 rightTitles: AxisTitles(sideTitles: SideTitles(
//                   showTitles: true, reservedSize: 30, interval: yInterval,
//                   getTitlesWidget: (v, _) => Text(
//                       v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
//                       style: const TextStyle(color: Colors.white38, fontSize: 9)),
//                 )),
//                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),

//               borderData: FlBorderData(
//                   show: true,
//                   border: Border.all(color: Colors.white24, width: 0.8)),

//               lineBarsData: [
//                 // ── Colored zone fills ────────────────────────────────────

//                 // Below -3SD → SAM (deep red)
//                 _zoneFill(m3, const Color(0xFFB71C1C), 0.70),
//                 // -3SD to -2SD → MAM (orange)
//                 _zoneFill(m2, const Color(0xFFE65100), 0.55),
//                 // -2SD to -1SD → Moderate risk (yellow)
//                 _zoneFill(m1, const Color(0xFFF9A825), 0.35),
//                 // -1SD to +1SD → Normal (green)
//                 _zoneFill(p1, const Color(0xFF1B5E20), 0.40),
//                 // +1SD to +2SD → Above normal (light green)
//                 _zoneFill(p2, const Color(0xFF33691E), 0.25),
//                 // +2SD to +3SD → Risk overweight (amber)
//                 _zoneFill(p3, const Color(0xFFF57F17), 0.30),

//                 // ── SD Reference lines ────────────────────────────────────
//                 _sdLine(m3,  const Color(0xFFEF5350), 1.5),
//                 _sdLine(m2,  const Color(0xFFFF7043), 1.5),
//                 _sdLine(m1,  const Color(0xFFFFCA28).withOpacity(0.8), 1.0,
//                     dash: [4, 3]),
//                 _sdLine(med, Colors.white,             1.5, dash: [8, 4]),
//                 _sdLine(p1,  const Color(0xFF66BB6A).withOpacity(0.8), 1.0,
//                     dash: [4, 3]),
//                 _sdLine(p2,  const Color(0xFFD9A577), 1.5),
//                 _sdLine(p3,  const Color(0xFFFFB300), 1.5),

//                 // ── Baby's growth line ────────────────────────────────────
//                 if (babySpots.isNotEmpty)
//                   LineChartBarData(
//                     spots: babySpots,
//                     isCurved: true, curveSmoothness: 0.2,
//                     color: Colors.white, barWidth: 2.5,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
//                         radius: i == babySpots.length - 1 ? 6 : 4,
//                         color: i == babySpots.length - 1
//                             ? const Color(0xFFD9A577)
//                             : Colors.white,
//                         strokeWidth: 2,
//                         strokeColor: const Color(0xFF1B0B3B),
//                       ),
//                     ),
//                     belowBarData: BarAreaData(show: false),
//                   ),
//               ],
//             )),
//           ),

//           const SizedBox(height: 10),
//           // Legend
//           Wrap(
//             spacing: 10, runSpacing: 5,
//             children: [
//               _legendBox('<−3SD',    const Color(0xFFB71C1C)),
//               _legendBox('−3→−2SD', const Color(0xFFE65100)),
//               _legendBox('−2→−1SD', const Color(0xFFF9A825)),
//               _legendBox('Normal',  const Color(0xFF1B5E20)),
//               _legendLine('Median', Colors.white, dashed: true),
//               _legendLine('Baby',   const Color(0xFFD9A577)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Chart Helpers ─────────────────────────────────────────────────────────

//   LineChartBarData _zoneFill(List<FlSpot> spots, Color color, double opacity) =>
//       LineChartBarData(
//         spots: spots, isCurved: true, curveSmoothness: 0.3,
//         color: Colors.transparent, barWidth: 0,
//         belowBarData: BarAreaData(show: true, color: color.withOpacity(opacity)),
//         dotData: FlDotData(show: false),
//       );

//   LineChartBarData _sdLine(List<FlSpot> spots, Color color, double width,
//       {List<int>? dash}) =>
//       LineChartBarData(
//         spots: spots, isCurved: true, curveSmoothness: 0.3,
//         color: color, barWidth: width,
//         dashArray: dash,
//         dotData: FlDotData(show: false),
//         belowBarData: BarAreaData(show: false),
//       );

//   // ── Three chart screens ───────────────────────────────────────────────────

//   Widget _buildWeightChart() {
//     final spots = _records.reversed
//         .map((r) => FlSpot(_ageInMonths(r.date).toDouble(), r.weight))
//         .toList();
//     return _buildWHOChart(
//       title: 'WEIGHT-FOR-AGE (0–24 months)',
//       yLabel: 'Weight (kg)',
//       whoEntries: _whoData?.weight,
//       babySpots: spots,
//       minY: 0, maxY: 20, yInterval: 2,
//     );
//   }

//   Widget _buildHeightChart() {
//     final spots = _records.reversed
//         .map((r) => FlSpot(_ageInMonths(r.date).toDouble(), r.height))
//         .toList();
//     return _buildWHOChart(
//       title: 'HEIGHT-FOR-AGE (0–24 months)',
//       yLabel: 'Length/Height (cm)',
//       whoEntries: _whoData?.height,
//       babySpots: spots,
//       minY: 40, maxY: 100, yInterval: 5,
//     );
//   }

//   Widget _buildBMIChart() {
//     final spots = _records.reversed
//         .map((r) {
//           final b = _bmi(r.weight, r.height);
//           if (b == null) return null;
//           return FlSpot(_ageInMonths(r.date).toDouble(), b);
//         })
//         .whereType<FlSpot>()
//         .toList();
//     return _buildWHOChart(
//       title: 'BMI-FOR-AGE (0–24 months)',
//       yLabel: 'BMI (kg/m²)',
//       whoEntries: _whoData?.bmi,
//       babySpots: spots,
//       minY: 8, maxY: 22, yInterval: 2,
//     );
//   }

//   // ── Latest Callout ────────────────────────────────────────────────────────

//   Widget _buildLatestCallout() {
//     final latest = _latestRecord!;
//     final prev = _records.length > 1 ? _records[1] : null;
//     final diff = prev != null ? latest.weight - prev.weight : null;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: const Color(0xFF3B1B45),
//           borderRadius: BorderRadius.circular(20)),
//       child: Row(children: [
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('LATEST WEIGHT',
//                   style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
//               const SizedBox(height: 4),
//               Text('${latest.weight.toStringAsFixed(1)} kg',
//                   style: const TextStyle(color: Colors.white, fontSize: 32,
//                       fontWeight: FontWeight.bold)),
//             ])),
//         if (diff != null)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: diff >= 0
//                   ? const Color(0xFF2E7D32).withOpacity(0.3)
//                   : const Color(0xFFC62828).withOpacity(0.3),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: diff >= 0
//                   ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)),
//             ),
//             child: Row(children: [
//               Icon(diff >= 0 ? Icons.trending_up : Icons.trending_down,
//                   color: diff >= 0
//                       ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
//                   size: 16),
//               const SizedBox(width: 4),
//               Text('${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
//                   style: TextStyle(
//                       color: diff >= 0
//                           ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
//                       fontWeight: FontWeight.bold, fontSize: 13)),
//             ]),
//           ),
//       ]),
//     );
//   }

//   // ── Summary Table ─────────────────────────────────────────────────────────

//   Widget _buildSummaryTable() {
//     final latest    = _latestRecord!;
//     final ageMonths = _ageInMonths(latest.date);
//     final weightZ   = latest.weightForAgeZ;
//     final heightZ   = latest.heightForAgeZ;
//     final bmiVal    = _bmi(latest.weight, latest.height);

//     // Get median from WHO data if available
//     String medianWeight = '—';
//     String medianHeight = '—';
//     if (_whoData != null) {
//       final wEntry = _whoData!.weight
//           .reduce((a, b) => (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);
//       final hEntry = _whoData!.height
//           .reduce((a, b) => (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);
//       medianWeight = '${wEntry.median.toStringAsFixed(1)} kg';
//       medianHeight = '${hEntry.median.toStringAsFixed(0)} cm';
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF3B1B45),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFD9A577).withOpacity(0.3)),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Row(children: [
//           Icon(Icons.table_chart_outlined, color: Color(0xFFD9A577), size: 20),
//           SizedBox(width: 8),
//           Text('Growth Summary', style: TextStyle(fontSize: 16,
//               fontWeight: FontWeight.bold, color: Colors.white)),
//         ]),
//         const SizedBox(height: 16),
//         _tableRow(isHeader: true,
//             cells: ['Indicator', 'Actual', 'Median', 'Z-Score', 'Status']),
//         const Divider(color: Colors.white12, height: 1),
//         _tableRow(
//           cells: ['Weight/Age', '${latest.weight.toStringAsFixed(1)} kg',
//             medianWeight, weightZ != null ? weightZ.toStringAsFixed(2) : '—',
//             _zLabel(weightZ)],
//           statusColor: weightZ != null
//               ? (weightZ.abs() <= 2 ? const Color(0xFF4CAF50) : const Color(0xFFC62828))
//               : Colors.white38,
//         ),
//         const Divider(color: Colors.white12, height: 1),
//         _tableRow(
//           cells: ['Height/Age', '${latest.height.toStringAsFixed(0)} cm',
//             medianHeight, heightZ != null ? heightZ.toStringAsFixed(2) : '—',
//             _zLabel(heightZ)],
//           statusColor: heightZ != null
//               ? (heightZ.abs() <= 2 ? const Color(0xFF4CAF50) : const Color(0xFFC62828))
//               : Colors.white38,
//         ),
//         const Divider(color: Colors.white12, height: 1),
//         _tableRow(
//           cells: ['BMI', bmiVal != null ? bmiVal.toStringAsFixed(1) : '—',
//             '—', '—',
//             bmiVal != null
//                 ? (bmiVal < 14.0 ? 'Low' : bmiVal > 18.0 ? 'High' : 'Normal')
//                 : '—'],
//           statusColor: bmiVal != null
//               ? (bmiVal >= 14.0 && bmiVal <= 18.0
//                   ? const Color(0xFF4CAF50) : const Color(0xFFF57F17))
//               : Colors.white38,
//         ),
//         const Divider(color: Colors.white12, height: 1),
//         _tableRow(
//           cells: ['Overall', '', '', '', _statusLabel(_currentStatus)],
//           statusColor: _statusColor(_currentStatus),
//         ),
//         const SizedBox(height: 14),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(color: const Color(0xFF1B0B3B),
//               borderRadius: BorderRadius.circular(10)),
//           child: Row(children: [
//             const Icon(Icons.child_care, color: Color(0xFFD9A577), size: 16),
//             const SizedBox(width: 8),
//             Text(
//               'Age: $ageMonths months'
//               '${ageMonths >= 12 ? ' (${(ageMonths / 12).floor()}y ${ageMonths % 12}m)' : ''}',
//               style: const TextStyle(color: Colors.white60, fontSize: 12),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _tableRow({required List<String> cells, bool isHeader = false,
//       Color? statusColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: cells.asMap().entries.map((entry) {
//           final i = entry.key; final text = entry.value;
//           final isStatus = i == 4 && !isHeader;
//           return Expanded(
//             flex: i == 0 ? 2 : 1,
//             child: isStatus && statusColor != null
//                 ? Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
//                     ),
//                     child: Text(text, textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 10,
//                             fontWeight: FontWeight.bold, color: statusColor)),
//                   )
//                 : Text(text,
//                     textAlign: i == 0 ? TextAlign.left : TextAlign.center,
//                     style: TextStyle(
//                         fontSize: isHeader ? 11 : 12,
//                         fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//                         color: isHeader ? const Color(0xFFD9A577) : Colors.white70)),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ── Metrics Card ──────────────────────────────────────────────────────────

//   Widget _buildMetricsCard() {
//     final latest = _latestRecord!;
//     final bmiVal = _bmi(latest.weight, latest.height);
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(color: const Color(0xFF3B1B45),
//           borderRadius: BorderRadius.circular(24)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('Latest Measurements', style: TextStyle(fontSize: 16,
//             fontWeight: FontWeight.bold, color: Colors.white)),
//         const SizedBox(height: 16),
//         Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//           _metric('Weight', '${latest.weight.toStringAsFixed(1)} kg',
//               'z: ${latest.weightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
//               Icons.monitor_weight_outlined),
//           Container(width: 1, height: 60, color: Colors.white12),
//           _metric('Height', '${latest.height.toStringAsFixed(0)} cm',
//               'z: ${latest.heightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
//               Icons.height),
//           Container(width: 1, height: 60, color: Colors.white12),
//           _metric('BMI', bmiVal != null ? bmiVal.toStringAsFixed(1) : '—',
//               'kg/m²', Icons.analytics_outlined),
//         ]),
//       ]),
//     );
//   }

//   // ── Recommendations Card ──────────────────────────────────────────────────

//   Widget _buildRecommendationsCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF3B1B45),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFD9A577).withOpacity(0.4)),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Row(children: [
//           Icon(Icons.lightbulb_outline, color: Color(0xFFD9A577), size: 20),
//           SizedBox(width: 8),
//           Text('Recommendations', style: TextStyle(fontSize: 16,
//               fontWeight: FontWeight.bold, color: Colors.white)),
//         ]),
//         const SizedBox(height: 14),
//         ..._recommendations.map((r) => Padding(
//           padding: const EdgeInsets.only(bottom: 10),
//           child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('• ', style: TextStyle(color: Color(0xFFD9A577), fontSize: 18)),
//             Expanded(child: Text(r,
//                 style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4))),
//           ]),
//         )),
//       ]),
//     );
//   }

//   // ── Tiny helpers ──────────────────────────────────────────────────────────

//   Widget _metric(String label, String value, String sub, IconData icon) =>
//       Column(children: [
//         Icon(icon, color: const Color(0xFFD9A577), size: 26),
//         const SizedBox(height: 6),
//         Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
//         const SizedBox(height: 4),
//         Text(value, style: const TextStyle(color: Colors.white, fontSize: 18,
//             fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
//       ]);

//   Widget _iconBtn(IconData icon, Color bg, VoidCallback onTap) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
//           child: Icon(icon, color: Colors.white, size: 24),
//         ),
//       );

//   Widget _legendBox(String label, Color color) => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Container(width: 10, height: 10,
//           decoration: BoxDecoration(color: color.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(2))),
//       const SizedBox(width: 4),
//       Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
//     ],
//   );

//   Widget _legendLine(String label, Color color, {bool dashed = false}) =>
//       Row(mainAxisSize: MainAxisSize.min, children: [
//         dashed
//             ? Row(children: List.generate(3, (_) =>
//                 Container(width: 4, height: 2, color: color,
//                     margin: const EdgeInsets.only(right: 1))))
//             : Container(width: 14, height: 2.5, color: color),
//         const SizedBox(width: 4),
//         Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
//       ]);
// }