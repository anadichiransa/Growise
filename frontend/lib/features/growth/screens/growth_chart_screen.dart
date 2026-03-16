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
      setState(() { _error = 'Failed to load records.'; _isLoading = false; });
    }
  }

  Future<void> _loadWHO() async {
    try {
      final d = await ApiService.getWHOStandardsBoys();
      setState(() { _whoData = d; _whoLoading = false; });
    } catch (e) {
      setState(() {
        _whoError = 'WHO data unavailable. Run seed_who_data.py on backend.';
        _whoLoading = false;
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  GrowthRecord? get _latest => _records.isNotEmpty ? _records.first : null;
  String get _status        => _latest?.category ?? 'unknown';

  String get _summary {
    if (_latest == null) return 'No measurements yet. Add your first!';
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
      default:                return 'Unknown';
    }
  }

  String _zLabel(double? z) {
    if (z == null)             return 'N/A';
    if (z >= -1 && z <= 1)    return 'Normal';
    if (z < -3)                return 'Severely low';
    if (z < -2)                return 'Low';
    if (z > 3)                 return 'Very high';
    if (z > 2)                 return 'High';
    return 'Normal';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(child: Column(children: [
        // App bar
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

        Expanded(child: (_isLoading || _whoLoading)
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD9A577)),
                  SizedBox(height: 16),
                  Text('Loading growth data...',
                      style: TextStyle(color: Colors.white54)),
                ]))
            : _error.isNotEmpty
                ? _buildError()
                : _records.isEmpty
                    ? _buildEmpty()
                    : _buildContent()),
      ])),
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, color: Color(0xFFD9A577), size: 60),
      const SizedBox(height: 16),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 15)),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: _loadAll,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: const Text('Retry',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ],
  ));

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColours.deepMagenta,
              shape: BoxShape.circle),
          child: const Icon(Icons.show_chart, size: 70,
              color: Color(0xFFD9A577))),
      const SizedBox(height: 24),
      const Text('No measurements yet',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: Colors.white)),
      const SizedBox(height: 10),
      const Text('Start tracking your baby\'s growth\nusing WHO standards',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.5)),
      const SizedBox(height: 32),
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
        label: const Text('Add First Measurement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 58),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
      ),
    ]),
  ));

  // ── Main Content ──────────────────────────────────────────────────────────

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        // Status banner
        _buildStatusBanner(),
        const SizedBox(height: 16),
        if (_latest != null) _buildLatestCallout(),
        const SizedBox(height: 16),

        // Tab bar
        _buildTabBar(),
        const SizedBox(height: 16),

        // WHO error
        if (_whoError.isNotEmpty) _buildWHOErrorBanner(),

        // Charts
        SizedBox(height: 420, child: TabBarView(
          controller: _tabController,
          children: [
            _buildWeightChart(),
            _buildHeightChart(),
            _buildBMIChart(),
          ],
        )),

        const SizedBox(height: 16),
        if (_latest != null) _buildSummaryTable(),
        const SizedBox(height: 16),
        _buildMetricsCard(),
        const SizedBox(height: 16),
        if (_recs.isNotEmpty) _buildRecsCard(),
        const SizedBox(height: 16),

        // Add measurement button
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 12),

        // View saved button
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => SavedMeasurementsScreen(
              childId: widget.childId, childName: widget.childName,
              gender: widget.gender, dateOfBirth: widget.dateOfBirth,
            ),
          )).then((_) => _loadAll()),
          icon: Icon(Icons.list_alt, color: AppColours.primaryGold),
          label: Text('View Saved Measurements',
              style: TextStyle(color: AppColours.primaryGold,
                  fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: AppColours.primaryGold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  // ── Status Banner ─────────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    final color = _statusColor(_status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(Icons.child_care, color: color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(_statusLabel(_status),
              style: TextStyle(color: color, fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_summary, style: const TextStyle(color: Colors.white70,
              fontSize: 12, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _buildWHOErrorBanner() => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFC62828).withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.5)),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded,
          color: Color(0xFFEF5350), size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(_whoError,
          style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12))),
    ]),
  );

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) => Container(
        decoration: BoxDecoration(color: AppColours.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10)),
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          _tab(0, 'Weight/Age',  Icons.monitor_weight_outlined),
          _tab(1, 'Height/Age',  Icons.height),
          _tab(2, 'BMI/Age',     Icons.analytics_outlined),
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
          boxShadow: sel ? [BoxShadow(
            color: AppColours.primaryGold.withValues(alpha: 0.35),
            blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 3),
          )] : [],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: sel ? 20 : 17,
              color: sel ? Colors.black : Colors.white38),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(
              fontSize: sel ? 11 : 10,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? Colors.black : Colors.white38)),
        ]),
      ),
    ));
  }

  // ── WHO Chart ─────────────────────────────────────────────────────────────

  Widget _buildWHOChart({
    required String title,
    required String yLabel,
    required List<WHOStandardEntry>? entries,
    required List<FlSpot> babySpots,
    required double minY,
    required double maxY,
    required double yInterval,
  }) {
    if (entries == null || entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColours.deepMagenta,
            borderRadius: BorderRadius.circular(24)),
        child: const Center(child: Column(mainAxisSize: MainAxisSize.min,
            children: [
          Icon(Icons.cloud_off, color: Colors.white38, size: 40),
          SizedBox(height: 12),
          Text('WHO data unavailable',
              style: TextStyle(color: Colors.white54)),
          SizedBox(height: 4),
          Text('Run seed_who_data.py on the backend',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ])),
      );
    }

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
          Expanded(child: Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColours.primaryGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColours.primaryGold.withValues(alpha: 0.5)),
            ),
            child: Text('WHO 2006', style: TextStyle(
                color: AppColours.primaryGold, fontSize: 9,
                fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 2),
        const Text('Boys · 0–24 months',
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 12),

        Expanded(child: LineChart(LineChartData(
          minX: 0, maxX: 24, minY: minY, maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true, horizontalInterval: yInterval, verticalInterval: 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.white.withValues(alpha: 0.07), strokeWidth: 0.8),
            getDrawingVerticalLine: (_) =>
                FlLine(color: Colors.white.withValues(alpha: 0.07), strokeWidth: 0.8),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(yLabel, style: const TextStyle(
                  color: Colors.white54, fontSize: 9)),
              axisNameSize: 18,
              sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                  interval: yInterval,
                  getTitlesWidget: (v, _) => Text(
                      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white54, fontSize: 9))),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Age (months)',
                  style: TextStyle(color: Colors.white54, fontSize: 9)),
              axisNameSize: 16,
              sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                  interval: 3,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(color: Colors.white54, fontSize: 9))),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 30, interval: yInterval,
                getTitlesWidget: (v, _) => Text(
                    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white38, fontSize: 9)))),
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true,
              border: Border.all(color: Colors.white24, width: 0.8)),
          lineBarsData: [
            // Zone fills
            _fill(m3,  AppColours.whoSAM,      0.70),
            _fill(m2,  AppColours.whoMAM,      0.55),
            _fill(m1,  AppColours.whoModerate, 0.35),
            _fill(p1,  AppColours.whoNormal,   0.40),
            _fill(p2,  AppColours.whoAbove,    0.25),
            _fill(p3,  AppColours.whoOverwt,   0.30),
            // SD lines
            _line(m3,  const Color(0xFFEF5350), 1.5),
            _line(m2,  const Color(0xFFFF7043), 1.5),
            _line(m1,  const Color(0xFFFFCA28).withValues(alpha: 0.8), 1.0, dash: [4,3]),
            _line(med, Colors.white, 1.5, dash: [8,4]),
            _line(p1,  const Color(0xFF66BB6A).withValues(alpha: 0.8), 1.0, dash: [4,3]),
            _line(p2,  AppColours.primaryGold, 1.5),
            _line(p3,  const Color(0xFFFFB300), 1.5),
            // Baby line
            if (babySpots.isNotEmpty)
              LineChartBarData(
                spots: babySpots, isCurved: true, curveSmoothness: 0.2,
                color: Colors.white, barWidth: 2.5,
                dotData: FlDotData(show: true,
                  getDotPainter: (spot, p, e, i) => FlDotCirclePainter(
                    radius: i == babySpots.length - 1 ? 6 : 4,
                    color: i == babySpots.length - 1
                        ? AppColours.primaryGold : Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColours.background,
                  ),
                ),
                belowBarData: BarAreaData(show: false),
              ),
          ],
        ))),

        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 5, children: [
          _lBox('<−3SD',    AppColours.whoSAM),
          _lBox('−3→−2SD', AppColours.whoMAM),
          _lBox('−2→−1SD', AppColours.whoModerate),
          _lBox('Normal',  AppColours.whoNormal),
          _lLine('Median', Colors.white, dashed: true),
          _lLine('Baby',   AppColours.primaryGold),
        ]),
      ]),
    );
  }

  LineChartBarData _fill(List<FlSpot> s, Color c, double o) =>
      LineChartBarData(spots: s, isCurved: true, curveSmoothness: 0.3,
          color: Colors.transparent, barWidth: 0,
          belowBarData: BarAreaData(show: true, color: c.withValues(alpha: o)),
          dotData: FlDotData(show: false));

  LineChartBarData _line(List<FlSpot> s, Color c, double w,
      {List<int>? dash}) =>
      LineChartBarData(spots: s, isCurved: true, curveSmoothness: 0.3,
          color: c, barWidth: w, dashArray: dash,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false));

  // ── 3 chart screens ───────────────────────────────────────────────────────

  Widget _buildWeightChart() => _buildWHOChart(
    title: 'WEIGHT-FOR-AGE (0–24 months)', yLabel: 'Weight (kg)',
    entries: _whoData?.weight,
    babySpots: _records.reversed
        .map((r) => FlSpot(_age(r.date).toDouble(), r.weight)).toList(),
    minY: 0, maxY: 20, yInterval: 2,
  );

  Widget _buildHeightChart() => _buildWHOChart(
    title: 'HEIGHT-FOR-AGE (0–24 months)', yLabel: 'Length/Height (cm)',
    entries: _whoData?.height,
    babySpots: _records.reversed
        .map((r) => FlSpot(_age(r.date).toDouble(), r.height)).toList(),
    minY: 40, maxY: 100, yInterval: 5,
  );

  Widget _buildBMIChart() => _buildWHOChart(
    title: 'BMI-FOR-AGE (0–24 months)', yLabel: 'BMI (kg/m²)',
    entries: _whoData?.bmi,
    babySpots: _records.reversed
        .map((r) { final b = _bmi(r.weight, r.height);
          if (b == null) return null;
          return FlSpot(_age(r.date).toDouble(), b); })
        .whereType<FlSpot>().toList(),
    minY: 8, maxY: 22, yInterval: 2,
  );

  // ── Latest Callout ────────────────────────────────────────────────────────

  Widget _buildLatestCallout() {
    final r    = _latest!;
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
                ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                : const Color(0xFFC62828).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: diff >= 0
                ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)),
          ),
          child: Row(children: [
            Icon(diff >= 0 ? Icons.trending_up : Icons.trending_down,
                color: diff >= 0
                    ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                size: 16),
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

  // ── Summary Table ─────────────────────────────────────────────────────────

  Widget _buildSummaryTable() {
    final r         = _latest!;
    final ageMonths = _age(r.date);
    final bmiVal    = _bmi(r.weight, r.height);

    String medW = '—', medH = '—';
    if (_whoData != null) {
      final we = _whoData!.weight.reduce((a, b) =>
          (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);
      final he = _whoData!.height.reduce((a, b) =>
          (a.month - ageMonths).abs() < (b.month - ageMonths).abs() ? a : b);
      medW = '${we.median.toStringAsFixed(1)} kg';
      medH = '${he.median.toStringAsFixed(0)} cm';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColours.deepMagenta, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColours.primaryGold.withValues(alpha: 0.3)),
      ),
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
          medW, r.weightForAgeZ?.toStringAsFixed(2) ?? '—',
          _zLabel(r.weightForAgeZ)],
          sc: r.weightForAgeZ != null
              ? (r.weightForAgeZ!.abs() <= 2
                  ? const Color(0xFF4CAF50) : const Color(0xFFC62828))
              : Colors.white38),
        const Divider(color: Colors.white12, height: 1),
        _tRow(cells: ['Height/Age', '${r.height.toStringAsFixed(0)} cm',
          medH, r.heightForAgeZ?.toStringAsFixed(2) ?? '—',
          _zLabel(r.heightForAgeZ)],
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

  Widget _tRow({required List<String> cells, bool isHeader = false,
      Color? sc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: cells.asMap().entries.map((e) {
        final i = e.key; final t = e.value;
        final isStat = i == 4 && !isHeader;
        return Expanded(
          flex: i == 0 ? 2 : 1,
          child: isStat && sc != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sc.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Text(t, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.bold, color: sc)))
              : Text(t, textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                      fontSize: isHeader ? 11 : 12,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      color: isHeader ? AppColours.primaryGold : Colors.white70)),
        );
      }).toList()),
    );
  }

  // ── Metrics Card ──────────────────────────────────────────────────────────

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
              'z: ${r.heightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
              Icons.height),
          Container(width: 1, height: 60, color: Colors.white12),
          _metric('BMI', b != null ? b.toStringAsFixed(1) : '—',
              'kg/m²', Icons.analytics_outlined),
        ]),
      ]),
    );
  }

  // ── Recommendations ───────────────────────────────────────────────────────

  Widget _buildRecsCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColours.deepMagenta, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColours.primaryGold.withValues(alpha: 0.4)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.lightbulb_outline, color: AppColours.primaryGold, size: 20),
        const SizedBox(width: 8),
        const Text('Recommendations', style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
      const SizedBox(height: 14),
      ..._recs.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('• ', style: TextStyle(
              color: AppColours.primaryGold, fontSize: 18)),
          Expanded(child: Text(r, style: const TextStyle(
              color: Colors.white70, fontSize: 14, height: 1.4))),
        ]),
      )),
    ]),
  );

  // ── Tiny helpers ──────────────────────────────────────────────────────────

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

  Widget _lBox(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
    ],
  );

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