import 'dart:convert';
import '../../../core/database/daos/report_cache_dao.dart';

class ReportesLocalDatasource {
  final ReportCacheDao _dao;

  ReportesLocalDatasource(this._dao);

  Future<void> cache(String key, Map<String, dynamic> data) {
    return _dao.upsert(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getCached(String key) async {
    final raw = await _dao.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear(String key) => _dao.remove(key);
  Future<void> clearAll() => _dao.clearAll();
}
