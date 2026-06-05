import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../remote/datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource remote;

  DashboardRepositoryImpl({required this.remote});

  @override
  Future<DashboardStats> getStats() {
    return remote.getStats();
  }

  @override
  Future<List<ActivityItem>> getRecentActivity() {
    return remote.getRecentActivity();
  }
}
