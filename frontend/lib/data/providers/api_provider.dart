/// Sync a growth record to the FastAPI backend
Future<bool> syncGrowthRecord(Map<String, dynamic> recordData) async {
  try {
    await _dio.post('/growth/records', data: recordData);
    return true;
  } catch (e) {
    print('Backend growth sync failed (will retry on next connection): $e');
    return false;
  }
}