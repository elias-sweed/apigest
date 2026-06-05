import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/remote/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRemoteDatasourceProvider = Provider<DashboardRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DashboardRemoteDatasource(supabase);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remote = ref.watch(dashboardRemoteDatasourceProvider);
  return DashboardRepositoryImpl(remote: remote);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStats();
});

final recentActivityProvider = FutureProvider<List<ActivityItem>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentActivity();
});
