import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/growth_record_model.dart';
import '../../../data/models/who_standard_model.dart';
import '../../../data/repositories/api_service.dart';
import '../controllers/growth_controller.dart';
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

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  final GrowthController _controller = GrowthController();
  late TabController _tabController;

  List<GrowthRecord> _records = [];
  WHOStandardsData?  _whoData;
  bool   _isLoading  = true;
  bool   _whoLoading = true;
  String _error      = '';
  String _whoError   = '';

  // ── Fallback WHO data — always available even without backend ─────────────
  static final List<WHOStandardEntry> _fallbackWeight = [
    WHOStandardEntry(month:0,  sdMinus3:2.1,sdMinus2:2.5,sdMinus1:2.9,median:3.3,sdPlus1:3.9,sdPlus2:4.4,sdPlus3:5.0),
    WHOStandardEntry(month:1,  sdMinus3:2.9,sdMinus2:3.4,sdMinus1:3.9,median:4.5,sdPlus1:5.1,sdPlus2:5.8,sdPlus3:6.6),
    WHOStandardEntry(month:2,  sdMinus3:3.8,sdMinus2:4.3,sdMinus1:4.9,median:5.6,sdPlus1:6.3,sdPlus2:7.1,sdPlus3:8.0),
    WHOStandardEntry(month:3,  sdMinus3:4.4,sdMinus2:5.0,sdMinus1:5.7,median:6.4,sdPlus1:7.2,sdPlus2:8.0,sdPlus3:9.0),
    WHOStandardEntry(month:4,  sdMinus3:4.9,sdMinus2:5.6,sdMinus1:6.2,median:7.0,sdPlus1:7.8,sdPlus2:8.7,sdPlus3:9.7),
    WHOStandardEntry(month:5,  sdMinus3:5.3,sdMinus2:6.0,sdMinus1:6.7,median:7.5,sdPlus1:8.4,sdPlus2:9.3,sdPlus3:10.4),
    WHOStandardEntry(month:6,  sdMinus3:5.7,sdMinus2:6.4,sdMinus1:7.1,median:7.9,sdPlus1:8.8,sdPlus2:9.8,sdPlus3:10.9),
    WHOStandardEntry(month:7,  sdMinus3:5.9,sdMinus2:6.7,sdMinus1:7.4,median:8.3,sdPlus1:9.2,sdPlus2:10.3,sdPlus3:11.4),
    WHOStandardEntry(month:8,  sdMinus3:6.2,sdMinus2:7.0,sdMinus1:7.7,median:8.6,sdPlus1:9.6,sdPlus2:10.7,sdPlus3:11.9),
    WHOStandardEntry(month:9,  sdMinus3:6.4,sdMinus2:7.2,sdMinus1:8.0,median:8.9,sdPlus1:9.9,sdPlus2:11.0,sdPlus3:12.3),
    WHOStandardEntry(month:10, sdMinus3:6.6,sdMinus2:7.5,sdMinus1:8.2,median:9.2,sdPlus1:10.2,sdPlus2:11.4,sdPlus3:12.7),
    WHOStandardEntry(month:11, sdMinus3:6.8,sdMinus2:7.7,sdMinus1:8.5,median:9.4,sdPlus1:10.5,sdPlus2:11.7,sdPlus3:13.0),
    WHOStandardEntry(month:12, sdMinus3:6.9,sdMinus2:7.8,sdMinus1:8.6,median:9.6,sdPlus1:10.8,sdPlus2:12.0,sdPlus3:13.3),
    WHOStandardEntry(month:13, sdMinus3:7.1,sdMinus2:8.0,sdMinus1:8.9,median:9.9,sdPlus1:11.0,sdPlus2:12.3,sdPlus3:13.7),
    WHOStandardEntry(month:14, sdMinus3:7.2,sdMinus2:8.1,sdMinus1:9.0,median:10.1,sdPlus1:11.3,sdPlus2:12.6,sdPlus3:14.0),
    WHOStandardEntry(month:15, sdMinus3:7.4,sdMinus2:8.3,sdMinus1:9.2,median:10.3,sdPlus1:11.5,sdPlus2:12.8,sdPlus3:14.3),
    WHOStandardEntry(month:16, sdMinus3:7.5,sdMinus2:8.4,sdMinus1:9.4,median:10.5,sdPlus1:11.7,sdPlus2:13.1,sdPlus3:14.6),
    WHOStandardEntry(month:17, sdMinus3:7.6,sdMinus2:8.6,sdMinus1:9.5,median:10.7,sdPlus1:11.9,sdPlus2:13.3,sdPlus3:14.9),
    WHOStandardEntry(month:18, sdMinus3:7.8,sdMinus2:8.8,sdMinus1:9.7,median:10.9,sdPlus1:12.2,sdPlus2:13.6,sdPlus3:15.2),
    WHOStandardEntry(month:19, sdMinus3:7.9,sdMinus2:8.9,sdMinus1:9.9,median:11.1,sdPlus1:12.4,sdPlus2:13.8,sdPlus3:15.5),
    WHOStandardEntry(month:20, sdMinus3:8.0,sdMinus2:9.0,sdMinus1:10.1,median:11.3,sdPlus1:12.6,sdPlus2:14.1,sdPlus3:15.7),
    WHOStandardEntry(month:21, sdMinus3:8.2,sdMinus2:9.2,sdMinus1:10.2,median:11.5,sdPlus1:12.9,sdPlus2:14.4,sdPlus3:16.1),
    WHOStandardEntry(month:22, sdMinus3:8.3,sdMinus2:9.3,sdMinus1:10.4,median:11.8,sdPlus1:13.1,sdPlus2:14.7,sdPlus3:16.4),
    WHOStandardEntry(month:23, sdMinus3:8.4,sdMinus2:9.5,sdMinus1:10.6,median:11.9,sdPlus1:13.4,sdPlus2:14.9,sdPlus3:16.7),
    WHOStandardEntry(month:24, sdMinus3:8.6,sdMinus2:9.7,sdMinus1:10.8,median:12.2,sdPlus1:13.6,sdPlus2:15.3,sdPlus3:17.1),
  ];

  static final List<WHOStandardEntry> _fallbackHeight = [
    WHOStandardEntry(month:0,  sdMinus3:44.2,sdMinus2:46.1,sdMinus1:48.0,median:49.9,sdPlus1:51.8,sdPlus2:53.7,sdPlus3:55.6),
    WHOStandardEntry(month:1,  sdMinus3:48.9,sdMinus2:50.8,sdMinus1:52.8,median:54.7,sdPlus1:56.7,sdPlus2:58.6,sdPlus3:60.6),
    WHOStandardEntry(month:2,  sdMinus3:52.4,sdMinus2:54.4,sdMinus1:56.4,median:58.4,sdPlus1:60.4,sdPlus2:62.4,sdPlus3:64.4),
    WHOStandardEntry(month:3,  sdMinus3:55.3,sdMinus2:57.3,sdMinus1:59.4,median:61.4,sdPlus1:63.5,sdPlus2:65.5,sdPlus3:67.6),
    WHOStandardEntry(month:4,  sdMinus3:57.6,sdMinus2:59.7,sdMinus1:61.8,median:63.9,sdPlus1:66.0,sdPlus2:68.0,sdPlus3:70.1),
    WHOStandardEntry(month:5,  sdMinus3:59.6,sdMinus2:61.7,sdMinus1:63.8,median:65.9,sdPlus1:68.0,sdPlus2:70.1,sdPlus3:72.2),
    WHOStandardEntry(month:6,  sdMinus3:61.2,sdMinus2:63.3,sdMinus1:65.5,median:67.6,sdPlus1:69.8,sdPlus2:71.9,sdPlus3:74.0),
    WHOStandardEntry(month:7,  sdMinus3:62.7,sdMinus2:64.8,sdMinus1:67.0,median:69.2,sdPlus1:71.3,sdPlus2:73.5,sdPlus3:75.7),
    WHOStandardEntry(month:8,  sdMinus3:64.0,sdMinus2:66.2,sdMinus1:68.4,median:70.6,sdPlus1:72.8,sdPlus2:75.0,sdPlus3:77.2),
    WHOStandardEntry(month:9,  sdMinus3:65.2,sdMinus2:67.5,sdMinus1:69.7,median:72.0,sdPlus1:74.2,sdPlus2:76.5,sdPlus3:78.7),
    WHOStandardEntry(month:10, sdMinus3:66.4,sdMinus2:68.7,sdMinus1:71.0,median:73.3,sdPlus1:75.6,sdPlus2:77.9,sdPlus3:80.2),
    WHOStandardEntry(month:11, sdMinus3:67.6,sdMinus2:69.9,sdMinus1:72.2,median:74.5,sdPlus1:76.9,sdPlus2:79.2,sdPlus3:81.5),
    WHOStandardEntry(month:12, sdMinus3:68.6,sdMinus2:71.0,sdMinus1:73.4,median:75.7,sdPlus1:78.1,sdPlus2:80.5,sdPlus3:82.9),
    WHOStandardEntry(month:13, sdMinus3:69.8,sdMinus2:72.1,sdMinus1:74.5,median:76.9,sdPlus1:79.3,sdPlus2:81.8,sdPlus3:84.2),
    WHOStandardEntry(month:14, sdMinus3:70.8,sdMinus2:73.1,sdMinus1:75.6,median:78.0,sdPlus1:80.5,sdPlus2:82.9,sdPlus3:85.4),
    WHOStandardEntry(month:15, sdMinus3:71.7,sdMinus2:74.1,sdMinus1:76.6,median:79.1,sdPlus1:81.6,sdPlus2:84.1,sdPlus3:86.6),
    WHOStandardEntry(month:16, sdMinus3:72.7,sdMinus2:75.2,sdMinus1:77.7,median:80.2,sdPlus1:82.7,sdPlus2:85.2,sdPlus3:87.8),
    WHOStandardEntry(month:17, sdMinus3:73.6,sdMinus2:76.1,sdMinus1:78.7,median:81.2,sdPlus1:83.7,sdPlus2:86.3,sdPlus3:88.8),
    WHOStandardEntry(month:18, sdMinus3:74.5,sdMinus2:77.1,sdMinus1:79.7,median:82.3,sdPlus1:84.9,sdPlus2:87.5,sdPlus3:90.1),
    WHOStandardEntry(month:19, sdMinus3:75.3,sdMinus2:78.0,sdMinus1:80.6,median:83.2,sdPlus1:85.9,sdPlus2:88.5,sdPlus3:91.2),
    WHOStandardEntry(month:20, sdMinus3:76.2,sdMinus2:78.9,sdMinus1:81.5,median:84.2,sdPlus1:86.8,sdPlus2:89.5,sdPlus3:92.2),
    WHOStandardEntry(month:21, sdMinus3:77.0,sdMinus2:79.7,sdMinus1:82.4,median:85.1,sdPlus1:87.9,sdPlus2:90.6,sdPlus3:93.3),
    WHOStandardEntry(month:22, sdMinus3:77.8,sdMinus2:80.5,sdMinus1:83.3,median:86.0,sdPlus1:88.8,sdPlus2:91.5,sdPlus3:94.3),
    WHOStandardEntry(month:23, sdMinus3:78.6,sdMinus2:81.3,sdMinus1:84.1,median:86.9,sdPlus1:89.7,sdPlus2:92.5,sdPlus3:95.3),
    WHOStandardEntry(month:24, sdMinus3:79.3,sdMinus2:82.1,sdMinus1:85.0,median:87.8,sdPlus1:90.7,sdPlus2:93.5,sdPlus3:96.4),
  ];

  static final List<WHOStandardEntry> _fallbackBMI = [
    WHOStandardEntry(month:0,  sdMinus3:10.2,sdMinus2:11.1,sdMinus1:12.2,median:13.4,sdPlus1:14.8,sdPlus2:16.3,sdPlus3:18.1),
    WHOStandardEntry(month:3,  sdMinus3:12.5,sdMinus2:13.5,sdMinus1:14.6,median:15.9,sdPlus1:17.2,sdPlus2:18.7,sdPlus3:20.3),
    WHOStandardEntry(month:6,  sdMinus3:12.0,sdMinus2:13.0,sdMinus1:14.1,median:15.3,sdPlus1:16.6,sdPlus2:18.0,sdPlus3:19.7),
    WHOStandardEntry(month:9,  sdMinus3:11.6,sdMinus2:12.6,sdMinus1:13.7,median:14.9,sdPlus1:16.2,sdPlus2:17.7,sdPlus3:19.3),
    WHOStandardEntry(month:12, sdMinus3:11.3,sdMinus2:12.3,sdMinus1:13.4,median:14.7,sdPlus1:16.0,sdPlus2:17.4,sdPlus3:19.1),
    WHOStandardEntry(month:15, sdMinus3:11.1,sdMinus2:12.1,sdMinus1:13.2,median:14.4,sdPlus1:15.8,sdPlus2:17.2,sdPlus3:18.9),
    WHOStandardEntry(month:18, sdMinus3:10.9,sdMinus2:11.9,sdMinus1:13.0,median:14.3,sdPlus1:15.6,sdPlus2:17.1,sdPlus3:18.7),
    WHOStandardEntry(month:21, sdMinus3:10.8,sdMinus2:11.8,sdMinus1:12.9,median:14.1,sdPlus1:15.5,sdPlus2:16.9,sdPlus3:18.6),
    WHOStandardEntry(month:24, sdMinus3:10.6,sdMinus2:11.6,sdMinus1:12.8,median:14.0,sdPlus1:15.4,sdPlus2:16.8,sdPlus3:18.5),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true; _whoLoading = true;
      _error = ''; _whoError = '';
    });
    await Future.wait([_loadRecords(), _loadWHO()]);
  }

  Future<void> _loadRecords() async {
    try {
      final r = await _controller.loadRecords(widget.childId);
      r.sort((a, b) => b.date.compareTo(a.date));
      setState(() { _records = r; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadWHO() async {
    try {
      final d = await ApiService.getWHOStandardsBoys();
      setState(() { _whoData = d; _whoLoading = false; });
    } catch (e) {
      // Always fall back to built-in data — charts never fail
      setState(() {
        _whoData = WHOStandardsData(
          weight: _fallbackWeight,
          height: _fallbackHeight,
          bmi:    _fallbackBMI,
        );
        _whoError = 'offline';
        _whoLoading = false;
      });
    }
  }

  GrowthRecord? get _latest => _records.isNotEmpty ? _records.first : null;
  String get _status        => _latest?.category ?? 'healthy';

  String get _summary {
    if (_latest == null) return 'Add a measurement to plot your baby\'s growth curve on the chart!';
    return _controller.generateSummary(
      category: _status, weightZ: _latest!.weightForAgeZ,
      heightZ: _latest!.heightForAgeZ, childName: widget.childName,
    );
  }

  List<String> get _recs =>
      _latest == null ? [] : _controller.getRecommendations(_status);

  int _age(DateTime d) {
    int m = (d.year - widget.dateOfBirth.year) * 12;
    m += d.month - widget.dateOfBirth.month;
    if (d.day < widget.dateOfBirth.day) m--;
    return m.clamp(0, 24);
  }

  double? _bmi(double w, double h) {
    if (h <= 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  Color _statusColor(String? c) {
    switch (c) {
      case 'healthy':         return AppColours.healthy;
      case 'stunting':
      case 'wasting':         return AppColours.warning;
      case 'severe_stunting':
      case 'severe_wasting':  return AppColours.danger;
      case 'overweight':      return AppColours.overweight;
      default:                return AppColours.healthy;
    }
  }

  String _statusLabel(String? c) {
    switch (c) {
      case 'healthy':         return 'Normal';
      case 'stunting':        return 'Stunting';
      case 'wasting':         return 'Wasting (MAM)';
      case 'severe_stunting': return 'Severe Stunting';
      case 'severe_wasting':  return 'SAM';
      case 'overweight':      return 'Overweight';
      default:                return 'Normal';
    }
  }

  String _zLabel(double? z) {
    if (z == null)          return 'N/A';
    if (z >= -1 && z <= 1) return 'Normal';
    if (z < -3)             return 'Severely low';
    if (z < -2)             return 'Low';
    if (z > 3)              return 'Very high';
    if (z > 2)              return 'High';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconBtn(Icons.arrow_back, Colors.white12,
                  () => Navigator.pop(context)),
              Text('${widget.childName}\'s Growth',
                  style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold, color: Colors.white)),
              _iconBtn(Icons.add, AppColours.primaryGold, () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddMeasurementScreen(
                    childId: widget.childId, childName: widget.childName,
                    gender: widget.gender, dateOfBirth: widget.dateOfBirth,
                  ),
                ));
                _loadAll();
              }),
            ],
          ),
        ),

        Expanded(
          child: (_isLoading || _whoLoading)
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD9A577)),
                    SizedBox(height: 16),
                    Text('Loading...', style: TextStyle(color: Colors.white54)),
                  ]))
              : _buildContent(),
        ),
      ])),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        _buildStatusBanner(),
        const SizedBox(height: 16),
        if (_latest != null) ...[_buildLatestCallout(), const SizedBox(height: 16)],
        _buildTabBar(),
        const SizedBox(height: 4),
        if (_whoError == 'offline') _buildOfflineBanner(),
        const SizedBox(height: 8),

        // Charts always show
        SizedBox(height: 420, child: TabBarView(
          controller: _tabController,
          children: [_buildWeightChart(), _buildHeightChart(), _buildBMIChart()],
        )),

        const SizedBox(height: 16),
        if (_latest != null) ...[_buildSummaryTable(), const SizedBox(height: 16)],
        if (_latest != null) ...[_buildMetricsCard(), const SizedBox(height: 16)],
        if (_recs.isNotEmpty) ...[_buildRecsCard(), const SizedBox(height: 16)],

        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddMeasurementScreen(
                childId: widget.childId, childName: widget.childName,
                gender: widget.gender, dateOfBirth: widget.dateOfBirth,
              ),
            ));
            _loadAll();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Measurement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => SavedMeasurementsScreen(
              childId: widget.childId, childName: widget.childName,
              gender: widget.gender, dateOfBirth: widget.dateOfBirth,
            ),
          )).then((_) => _loadAll()),
          icon: Icon(Icons.list_alt, color: AppColours.primaryGold),
          label: Text('View Saved Measurements',
              style: TextStyle(color: AppColours.primaryGold, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: AppColours.primaryGold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _buildStatusBanner() {
    final color = _statusColor(_status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2),
                shape: BoxShape.circle),
            child: Icon(_latest != null ? Icons.child_care : Icons.add_chart,
                color: color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(_latest != null ? _statusLabel(_status) : 'WHO Growth Chart',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_summary, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _buildOfflineBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8)),
    child: const Row(children: [
      Icon(Icons.offline_bolt, color: Colors.white38, size: 12),
      SizedBox(width: 6),
      Text('Using built-in WHO reference data',
          style: TextStyle(color: Colors.white38, fontSize: 10)),
    ]),
  );

  Widget _buildTabBar() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) => Container(
        decoration: BoxDecoration(color: AppColours.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10)),
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          _tab(0, 'Weight/Age', Icons.monitor_weight_outlined),
          _tab(1, 'Height/Age', Icons.height),
          _tab(2, 'BMI/Age',    Icons.analytics_outlined),
        ]),
      ),
    );
  }

  Widget _tab(int i, String label, IconData icon) {
    final sel = _tabController.index == i;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tabController.animateTo(i)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: sel ? 14 : 10, horizontal: 4),
        decoration: BoxDecoration(
          color: sel ? AppColours.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: sel ? [BoxShadow(color: AppColours.primaryGold.withOpacity(0.35),
              blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 3))] : [],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: sel ? 20 : 17, color: sel ? Colors.black : Colors.white38),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(
              fontSize: sel ? 11 : 10,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? Colors.black : Colors.white38)),
        ]),
      ),
    ));
  }

  Widget _buildWHOChart({
    required String title, required String yLabel,
    required List<WHOStandardEntry> entries, required List<FlSpot> babySpots,
    required double minY, required double maxY, required double yInterval,
  }) {
    final m3  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus3)).toList();
    final m2  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus2)).toList();
    final m1  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdMinus1)).toList();
    final med = entries.map((e) => FlSpot(e.month.toDouble(), e.median)).toList();
    final p1  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus1)).toList();
    final p2  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus2)).toList();
    final p3  = entries.map((e) => FlSpot(e.month.toDouble(), e.sdPlus3)).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(color: AppColours.deepMagenta,
          borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white,
              fontSize: 12, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColours.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColours.primaryGold.withOpacity(0.5))),
            child: Text('WHO 2006', style: TextStyle(
                color: AppColours.primaryGold, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 2),
        const Text('Boys · 0–24 months',
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 12),

        Expanded(child: LineChart(LineChartData(
          minX: 0, maxX: 24, minY: minY, maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(show: true, horizontalInterval: yInterval,
              verticalInterval: 3,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: Colors.white.withOpacity(0.07), strokeWidth: 0.8),
              getDrawingVerticalLine: (_) =>
                  FlLine(color: Colors.white.withOpacity(0.07), strokeWidth: 0.8)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(yLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 9)),
              axisNameSize: 18,
              sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                  interval: yInterval,
                  getTitlesWidget: (v, _) => Text(
                      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white54, fontSize: 9)))),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Age (months)',
                  style: TextStyle(color: Colors.white54, fontSize: 9)),
              axisNameSize: 16,
              sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 3,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(color: Colors.white54, fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                reservedSize: 30, interval: yInterval,
                getTitlesWidget: (v, _) => Text(
                    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white38, fontSize: 9)))),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true,
              border: Border.all(color: Colors.white24, width: 0.8)),
          lineBarsData: [
            _fill(m3, AppColours.whoSAM,      0.70),
            _fill(m2, AppColours.whoMAM,      0.55),
            _fill(m1, AppColours.whoModerate, 0.35),
            _fill(p1, AppColours.whoNormal,   0.40),
            _fill(p2, AppColours.whoAbove,    0.25),
            _fill(p3, AppColours.whoOverwt,   0.30),
            _line(m3,  const Color(0xFFEF5350), 1.5),
            _line(m2,  const Color(0xFFFF7043), 1.5),
            _line(m1,  const Color(0xFFFFCA28).withOpacity(0.8), 1.0, dash: [4,3]),
            _line(med, Colors.white, 1.5, dash: [8,4]),
            _line(p1,  const Color(0xFF66BB6A).withOpacity(0.8), 1.0, dash: [4,3]),
            _line(p2,  AppColours.primaryGold, 1.5),
            _line(p3,  const Color(0xFFFFB300), 1.5),
            if (babySpots.isNotEmpty)
              LineChartBarData(
                spots: babySpots, isCurved: true, curveSmoothness: 0.2,
                color: Colors.white, barWidth: 2.5,
                dotData: FlDotData(show: true,
                  getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                    radius: i == babySpots.length - 1 ? 6 : 4,
                    color: i == babySpots.length - 1
                        ? AppColours.primaryGold : Colors.white,
                    strokeWidth: 2, strokeColor: AppColours.background)),
                belowBarData: BarAreaData(show: false)),
          ],
        ))),

        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 5, children: [
          _lBox('<−3SD',   AppColours.whoSAM),
          _lBox('−3→−2',  AppColours.whoMAM),
          _lBox('−2→−1',  AppColours.whoModerate),
          _lBox('Normal', AppColours.whoNormal),
          _lLine('Median', Colors.white, dashed: true),
          if (babySpots.isNotEmpty) _lLine('Baby', AppColours.primaryGold),
        ]),
      ]),
    );
  }

  LineChartBarData _fill(List<FlSpot> s, Color c, double o) =>
      LineChartBarData(spots: s, isCurved: true, curveSmoothness: 0.3,
          color: Colors.transparent, barWidth: 0,
          belowBarData: BarAreaData(show: true, color: c.withOpacity(o)),
          dotData: FlDotData(show: false));

  LineChartBarData _line(List<FlSpot> s, Color c, double w, {List<int>? dash}) =>
      LineChartBarData(spots: s, isCurved: true, curveSmoothness: 0.3,
          color: c, barWidth: w, dashArray: dash,
          dotData: FlDotData(show: false), belowBarData: BarAreaData(show: false));

  Widget _buildWeightChart() => _buildWHOChart(
    title: 'WEIGHT-FOR-AGE (0–24 months)', yLabel: 'Weight (kg)',
    entries: _whoData!.weight,
    babySpots: _records.reversed
        .map((r) => FlSpot(_age(r.date).toDouble(), r.weight)).toList(),
    minY: 0, maxY: 20, yInterval: 2);

  Widget _buildHeightChart() => _buildWHOChart(
    title: 'HEIGHT-FOR-AGE (0–24 months)', yLabel: 'Length/Height (cm)',
    entries: _whoData!.height,
    babySpots: _records.reversed
        .map((r) => FlSpot(_age(r.date).toDouble(), r.height)).toList(),
    minY: 40, maxY: 100, yInterval: 5);

  Widget _buildBMIChart() => _buildWHOChart(
    title: 'BMI-FOR-AGE (0–24 months)', yLabel: 'BMI (kg/m²)',
    entries: _whoData!.bmi,
    babySpots: _records.reversed.map((r) {
      final b = _bmi(r.weight, r.height);
      if (b == null) return null;
      return FlSpot(_age(r.date).toDouble(), b);
    }).whereType<FlSpot>().toList(),
    minY: 8, maxY: 22, yInterval: 2);

  Widget _buildLatestCallout() {
    final r = _latest!;
    final prev = _records.length > 1 ? _records[1] : null;
    final diff = prev != null ? r.weight - prev.weight : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColours.deepMagenta,
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('LATEST WEIGHT', style: TextStyle(
              color: Colors.white54, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('${r.weight.toStringAsFixed(1)} kg', style: const TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ])),
        if (diff != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: diff >= 0
                ? const Color(0xFF2E7D32).withOpacity(0.3)
                : const Color(0xFFC62828).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: diff >= 0
                ? const Color(0xFF4CAF50) : const Color(0xFFEF5350))),
          child: Row(children: [
            Icon(diff >= 0 ? Icons.trending_up : Icons.trending_down,
                color: diff >= 0
                    ? const Color(0xFF4CAF50) : const Color(0xFFEF5350), size: 16),
            const SizedBox(width: 4),
            Text('${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                style: TextStyle(
                    color: diff >= 0
                        ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSummaryTable() {
    final r = _latest!;
    final ageMonths = _age(r.date);
    final bmiVal = _bmi(r.weight, r.height);
    final we = _whoData!.weight.reduce((a, b) =>
        (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);
    final he = _whoData!.height.reduce((a, b) =>
        (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColours.deepMagenta,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColours.primaryGold.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.table_chart_outlined, color: AppColours.primaryGold, size: 20),
          const SizedBox(width: 8),
          const Text('Growth Summary', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        const SizedBox(height: 16),
        _tRow(isHeader: true,
            cells: ['Indicator', 'Actual', 'Median', 'Z-Score', 'Status']),
        const Divider(color: Colors.white12, height: 1),
        _tRow(cells: ['Weight/Age', '${r.weight.toStringAsFixed(1)} kg',
          '${we.median.toStringAsFixed(1)} kg',
          r.weightForAgeZ?.toStringAsFixed(2) ?? '—', _zLabel(r.weightForAgeZ)],
          sc: r.weightForAgeZ != null
              ? (r.weightForAgeZ!.abs() <= 2
                  ? const Color(0xFF4CAF50) : const Color(0xFFC62828))
              : Colors.white38),
        const Divider(color: Colors.white12, height: 1),
        _tRow(cells: ['Height/Age', '${r.height.toStringAsFixed(0)} cm',
          '${he.median.toStringAsFixed(0)} cm',
          r.heightForAgeZ?.toStringAsFixed(2) ?? '—', _zLabel(r.heightForAgeZ)],
          sc: r.heightForAgeZ != null
              ? (r.heightForAgeZ!.abs() <= 2
                  ? const Color(0xFF4CAF50) : const Color(0xFFC62828))
              : Colors.white38),
        const Divider(color: Colors.white12, height: 1),
        _tRow(cells: ['BMI', bmiVal != null ? bmiVal.toStringAsFixed(1) : '—',
          '—', '—',
          bmiVal != null
              ? (bmiVal < 14.0 ? 'Low' : bmiVal > 18.0 ? 'High' : 'Normal')
              : '—'],
          sc: bmiVal != null
              ? (bmiVal >= 14 && bmiVal <= 18
                  ? const Color(0xFF4CAF50) : const Color(0xFFF57F17))
              : Colors.white38),
        const Divider(color: Colors.white12, height: 1),
        _tRow(cells: ['Overall', '', '', '', _statusLabel(_status)],
            sc: _statusColor(_status)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColours.background,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(Icons.child_care, color: AppColours.primaryGold, size: 16),
            const SizedBox(width: 8),
            Text('Age: $ageMonths months'
                '${ageMonths >= 12 ? ' (${(ageMonths / 12).floor()}y ${ageMonths % 12}m)' : ''}',
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _tRow({required List<String> cells, bool isHeader = false, Color? sc}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: cells.asMap().entries.map((e) {
        final i = e.key; final t = e.value;
        final isStat = i == 4 && !isHeader;
        return Expanded(flex: i == 0 ? 2 : 1,
          child: isStat && sc != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: sc.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sc.withOpacity(0.5), width: 1)),
                  child: Text(t, textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: sc)))
              : Text(t, textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                  style: TextStyle(fontSize: isHeader ? 11 : 12,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      color: isHeader ? AppColours.primaryGold : Colors.white70)));
      }).toList()));
  }

  Widget _buildMetricsCard() {
    final r = _latest!;
    final b = _bmi(r.weight, r.height);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColours.deepMagenta,
          borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Latest Measurements', style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _metric('Weight', '${r.weight.toStringAsFixed(1)} kg',
              'z: ${r.weightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
              Icons.monitor_weight_outlined),
          Container(width: 1, height: 60, color: Colors.white12),
          _metric('Height', '${r.height.toStringAsFixed(0)} cm',
              'z: ${r.heightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}', Icons.height),
          Container(width: 1, height: 60, color: Colors.white12),
          _metric('BMI', b != null ? b.toStringAsFixed(1) : '—',
              'kg/m²', Icons.analytics_outlined),
        ]),
      ]),
    );
  }

  Widget _buildRecsCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColours.deepMagenta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColours.primaryGold.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.lightbulb_outline, color: AppColours.primaryGold, size: 20),
        const SizedBox(width: 8),
        const Text('Recommendations', style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
      const SizedBox(height: 14),
      ..._recs.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('• ', style: TextStyle(color: AppColours.primaryGold, fontSize: 18)),
          Expanded(child: Text(r, style: const TextStyle(
              color: Colors.white70, fontSize: 14, height: 1.4))),
        ]))),
    ]),
  );

  Widget _metric(String label, String val, String sub, IconData icon) =>
      Column(children: [
        Icon(icon, color: AppColours.primaryGold, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ]);

  Widget _iconBtn(IconData icon, Color bg, VoidCallback onTap) =>
      GestureDetector(onTap: onTap,
          child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24)));

  Widget _lBox(String label, Color color) => Row(mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ]);

  Widget _lLine(String label, Color color, {bool dashed = false}) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        dashed
            ? Row(children: List.generate(3, (_) => Container(
                width: 4, height: 2, color: color,
                margin: const EdgeInsets.only(right: 1))))
            : Container(width: 14, height: 2.5, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ]);
}