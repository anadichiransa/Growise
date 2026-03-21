import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_measurement_screen.dart';
import 'saved_measurements_screen.dart';
import 'package:growise/shared/widgets/common/status_banner.dart';
import '../controllers/growth_controller.dart';
import 'package:growise/data/models/growth_record.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';
import 'package:get/get.dart';
import 'package:growise/core/config/routes.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';

class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen>
    with SingleTickerProviderStateMixin {
  late ChildController _childController;
  late DateTime _dateOfBirth;
  late String _childId;
  late String _childName;
  final GrowthController _controller = GrowthController();
  late TabController _tabController;

  List<GrowthRecord> _records = [];
  bool _isLoading = true;
  String _errorMessage = '';

  static const Map<int, List<double>> _weightRefBoys = {
    0: [2.5, 3.3, 4.4],
    2: [3.8, 5.6, 7.4],
    4: [5.0, 7.0, 9.2],
    6: [5.7, 7.9, 10.2],
    9: [6.4, 8.9, 11.6],
    12: [7.1, 9.6, 12.3],
    15: [7.6, 10.3, 13.2],
    18: [8.1, 10.9, 14.0],
    24: [9.0, 12.2, 15.7],
    30: [9.8, 13.3, 17.1],
    36: [10.6, 14.3, 18.3],
  };

  static const Map<int, List<double>> _weightRefGirls = {
    0: [2.4, 3.2, 4.2],
    2: [3.4, 5.1, 6.9],
    4: [4.5, 6.4, 8.6],
    6: [5.1, 7.3, 9.8],
    9: [5.8, 8.2, 11.0],
    12: [6.3, 8.9, 11.8],
    15: [6.8, 9.6, 12.8],
    18: [7.2, 10.2, 13.7],
    24: [8.1, 11.5, 15.5],
    30: [8.8, 12.7, 17.1],
    36: [9.6, 13.9, 18.7],
  };

  static const Map<int, List<double>> _heightRefBoys = {
    0: [46.1, 49.9, 53.7],
    2: [52.4, 58.4, 64.4],
    4: [57.6, 63.9, 70.2],
    6: [61.2, 67.6, 74.0],
    9: [65.2, 72.0, 78.7],
    12: [68.6, 75.7, 82.9],
    15: [71.6, 79.1, 86.6],
    18: [74.0, 82.3, 90.4],
    24: [78.0, 87.1, 96.1],
    30: [81.7, 91.2, 100.7],
    36: [85.0, 95.1, 105.2],
  };

  static const Map<int, List<double>> _heightRefGirls = {
    0: [45.6, 49.1, 52.7],
    2: [51.0, 57.1, 63.2],
    4: [56.2, 62.1, 68.0],
    6: [59.8, 65.7, 71.6],
    9: [63.7, 70.1, 76.5],
    12: [66.3, 73.3, 80.2],
    15: [69.8, 77.5, 85.3],
    18: [72.8, 80.7, 88.7],
    24: [76.0, 85.7, 95.4],
    30: [80.1, 90.0, 99.9],
    36: [83.6, 94.1, 104.5],
  };

  @override
  void initState() {
    super.initState();
    _childController = Get.find<ChildController>();
    _dateOfBirth = _childController.child?['birthDate'] != null
        ? (_childController.child!['birthDate'] as dynamic).toDate()
        : DateTime(2022, 1, 1);
    _childId = _childController.childId;
    _childName = _childController.childName;
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final records = await _controller.loadRecords(_childId);
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _records = records;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load records. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  GrowthRecord? get _latestRecord =>
      _records.isNotEmpty ? _records.first : null;

  String get _currentStatus => _latestRecord?.category ?? 'unknown';

  String get _summary {
    if (_latestRecord == null) {
      return 'No measurements yet. Add your first measurement!';
    }

    return _controller.generateSummary(
      category: _currentStatus,
      weightZ: _latestRecord!.weightForAgeZ,
      heightZ: _latestRecord!.heightForAgeZ,
      childName: _childName,
    );
  }

  List<String> get _recommendations =>
      _latestRecord == null ? [] : _controller.getRecommendations(_currentStatus);

  int _calculateAgeInMonths(DateTime measurementDate) {
    int months = (measurementDate.year - _dateOfBirth.year) * 12;
    months += measurementDate.month - _dateOfBirth.month;
    if (measurementDate.day < _dateOfBirth.day) months--;
    return months;
  }

  Map<int, List<double>> get _weightRef =>
      _childController.childGender.toLowerCase() == 'boy'
          ? _weightRefBoys
          : _weightRefGirls;

  Map<int, List<double>> get _heightRef =>
      _childController.childGender.toLowerCase() == 'boy'
          ? _heightRefBoys
          : _heightRefGirls;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0B3B),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circularIconButton(
                    Icons.arrow_back,
                    Colors.white12,
                    () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        } else {
                          Get.offNamed(AppRoutes.dashboard);
                        }
                      },
                  ),
                  Expanded(
                    child: Text(
                      '$_childName\'s Growth',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _circularIconButton(
                    Icons.add,
                    const Color(0xFFD9A577),
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMeasurementScreen(
                            childId: _childId,
                            childName: _childName,
                            gender: _childController.childGender,
                            dateOfBirth: _dateOfBirth,
                          ),
                        ),
                      );
                      _loadRecords();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD9A577),
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _buildChartView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD9A577), size: 60),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRecords,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          StatusBanner(status: _currentStatus, summary: _summary),
          const SizedBox(height: 16),

          if (_latestRecord != null) ...[
            _buildLatestCallout(),
            const SizedBox(height: 16),
          ],

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B1B45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFD9A577),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Weight-for-Age'),
                Tab(text: 'Height-for-Age'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartCard(
                  'WEIGHT-FOR-AGE WHO STANDARDS',
                  'kg',
                  _buildWeightChartData(),
                ),
                _buildChartCard(
                  'HEIGHT-FOR-AGE WHO STANDARDS',
                  'cm',
                  _buildHeightChartData(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_records.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1B45),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD9A577).withOpacity(0.3),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'No measurements yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'WHO growth charts are shown above. Add the first measurement to plot your baby’s progress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_latestRecord != null) ...[
            _buildMetricsCard(),
            const SizedBox(height: 16),
          ],

          if (_recommendations.isNotEmpty) ...[
            _buildRecommendationsCard(),
            const SizedBox(height: 16),
          ],

          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMeasurementScreen(
                    childId: _childId,
                    childName: _childName,
                    gender: _childController.childGender,
                    dateOfBirth: _dateOfBirth,
                  ),
                ),
              );
              _loadRecords();
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Measurement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedMeasurementsScreen(
                    childId: _childId,
                    childName: _childName,
                    gender: _childController.childGender,
                    dateOfBirth: _dateOfBirth,
                  ),
                ),
              ).then((_) => _loadRecords());
            },
            icon: const Icon(Icons.list_alt, color: Color(0xFFD9A577)),
            label: const Text(
              'View Saved Measurements',
              style: TextStyle(
                color: Color(0xFFD9A577),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Color(0xFFD9A577)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLatestCallout() {
    if (_latestRecord == null) return const SizedBox();

    final latest = _latestRecord!;
    final prevRecord = _records.length > 1 ? _records[1] : null;
    final weightDiff =
        prevRecord != null ? latest.weight - prevRecord.weight : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1B45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEIGHT-FOR-AGE WHO STANDARDS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latest.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (weightDiff != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: weightDiff >= 0
                    ? const Color(0xFF2E7D32).withOpacity(0.3)
                    : const Color(0xFFC62828).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: weightDiff >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    weightDiff >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: weightDiff >= 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${weightDiff >= 0 ? '+' : ''}${weightDiff.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: weightDiff >= 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String unit, LineChartData chartData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1B45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: LineChart(chartData)),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem('Baby', const Color(0xFFFFFFFF)),
              _legendItem('+2 SD', const Color(0xFFD9A577)),
              _legendDashed('Median'),
              _legendItem('-2 SD', const Color(0xFFD9A577)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    if (_latestRecord == null) return const SizedBox();

    final latest = _latestRecord!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1B45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Measurements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  'Weight',
                  '${latest.weight.toStringAsFixed(1)} kg',
                  'z-score: ${latest.weightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
                  Icons.monitor_weight_outlined,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white12),
              Expanded(
                child: _metricTile(
                  'Height',
                  '${latest.height.toStringAsFixed(0)} cm',
                  'z-score: ${latest.heightForAgeZ?.toStringAsFixed(2) ?? 'N/A'}',
                  Icons.height,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1B45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9A577).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFD9A577), size: 20),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: Color(0xFFD9A577), fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildWeightChartData() {
    final babySpots = <FlSpot>[];
    for (final r in _records.reversed) {
      babySpots.add(FlSpot(_calculateAgeInMonths(r.date).toDouble(), r.weight));
    }
    return _buildRefChartData(babySpots, _weightRef, 0, 20);
  }

  LineChartData _buildHeightChartData() {
    final babySpots = <FlSpot>[];
    for (final r in _records.reversed) {
      babySpots.add(FlSpot(_calculateAgeInMonths(r.date).toDouble(), r.height));
    }
    return _buildRefChartData(babySpots, _heightRef, 40, 110);
  }

  LineChartData _buildRefChartData(
    List<FlSpot> babySpots,
    Map<int, List<double>> ref,
    double minY,
    double maxY,
  ) {
    final plus2Spots =
        ref.entries.map((e) => FlSpot(e.key.toDouble(), e.value[2])).toList();
    final medianSpots =
        ref.entries.map((e) => FlSpot(e.key.toDouble(), e.value[1])).toList();
    final minus2Spots =
        ref.entries.map((e) => FlSpot(e.key.toDouble(), e.value[0])).toList();

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 5,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.white.withOpacity(0.06), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            'AGE (MONTHS)',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 6,
            getTitlesWidget: (value, _) => Text(
              '${value.toInt()}m',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.15)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: plus2Spots,
          isCurved: true,
          color: const Color(0xFFD9A577),
          barWidth: 1.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: medianSpots,
          isCurved: true,
          color: Colors.white38,
          barWidth: 1,
          dashArray: [6, 4],
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: minus2Spots,
          isCurved: true,
          color: const Color(0xFFD9A577),
          barWidth: 1.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: babySpots,
          isCurved: true,
          color: Colors.white,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 5,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: const Color(0xFF1B0B3B),
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1B0B3B),
          getTooltipItems: (spots) => spots.map((spot) {
            if (spot.barIndex != 3) return null;
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(1)}\nAge: ${spot.x.toInt()}mo',
              const TextStyle(
                color: Color(0xFFD9A577),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, String sub, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFD9A577), size: 26),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 2.5, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _legendDashed(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (_) => Container(
              width: 4,
              height: 2,
              color: Colors.white38,
              margin: const EdgeInsets.only(right: 2),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _circularIconButton(IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}