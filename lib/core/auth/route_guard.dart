import '../../domain/entities/user_role.dart';
import '../router/route_names.dart';

abstract final class RouteGuard {
  RouteGuard._();

  static const _restrictedRoutes = [
    RouteNames.equipos,
    RouteNames.docentes,
    RouteNames.reportes,
  ];

  static bool canAccess(String location, UserRole role) {
    if (role.isEncargadoAip) return true;
    return !_restrictedRoutes.any((r) => location.startsWith(r));
  }

  static String? checkRedirect(String location, UserRole role, String dashboardPath) {
    if (!canAccess(location, role)) return dashboardPath;
    return null;
  }
}
