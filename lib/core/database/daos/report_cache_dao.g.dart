// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReportCacheTableTable get reportCacheTable =>
      attachedDatabase.reportCacheTable;
  ReportCacheDaoManager get managers => ReportCacheDaoManager(this);
}

class ReportCacheDaoManager {
  final _$ReportCacheDaoMixin _db;
  ReportCacheDaoManager(this._db);
  $$ReportCacheTableTableTableManager get reportCacheTable =>
      $$ReportCacheTableTableTableManager(
        _db.attachedDatabase,
        _db.reportCacheTable,
      );
}
