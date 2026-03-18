/// One month of WHO growth standard data with all 7 SD lines
class WHOStandardEntry {
  final int month;
  final double sdMinus3;
  final double sdMinus2;
  final double sdMinus1;
  final double median;
  final double sdPlus1;
  final double sdPlus2;
  final double sdPlus3;

  const WHOStandardEntry({
    required this.month,
    required this.sdMinus3,
    required this.sdMinus2,
    required this.sdMinus1,
    required this.median,
    required this.sdPlus1,
    required this.sdPlus2,
    required this.sdPlus3,
  });

  factory WHOStandardEntry.fromJson(Map<String, dynamic> json) {
    return WHOStandardEntry(
      month:    (json['month']     as num).toInt(),
      sdMinus3: (json['sd_minus3'] as num).toDouble(),
      sdMinus2: (json['sd_minus2'] as num).toDouble(),
      sdMinus1: (json['sd_minus1'] as num).toDouble(),
      median:   (json['median']    as num).toDouble(),
      sdPlus1:  (json['sd_plus1']  as num).toDouble(),
      sdPlus2:  (json['sd_plus2']  as num).toDouble(),
      sdPlus3:  (json['sd_plus3']  as num).toDouble(),
    );
  }
}

/// All 3 WHO datasets for boys loaded from backend
class WHOStandardsData {
  final List<WHOStandardEntry> weight;
  final List<WHOStandardEntry> height;
  final List<WHOStandardEntry> bmi;

  const WHOStandardsData({
    required this.weight,
    required this.height,
    required this.bmi,
  });

  factory WHOStandardsData.fromJson(Map<String, dynamic> json) {
    return WHOStandardsData(
      weight: (json['weight'] as List)
          .map((e) => WHOStandardEntry.fromJson(e)).toList(),
      height: (json['height'] as List)
          .map((e) => WHOStandardEntry.fromJson(e)).toList(),
      bmi:    (json['bmi']    as List)
          .map((e) => WHOStandardEntry.fromJson(e)).toList(),
    );
  }
}