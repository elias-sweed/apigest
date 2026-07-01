import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_role.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/home/shell_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/loans/loans_page.dart';
import '../../presentation/pages/loans/loan_create_page.dart';
import '../../presentation/pages/loans/loan_detail_page.dart';
import '../../presentation/pages/loans/loan_return_page.dart';
import '../../presentation/pages/equipment/equipment_page.dart';
import '../../presentation/pages/equipment/equipo_form_page.dart';
import '../../presentation/pages/equipment/equipo_detail_page.dart';
import '../../presentation/pages/teachers/teachers_page.dart';
import '../../presentation/pages/teachers/docente_form_page.dart';
import '../../presentation/pages/teachers/docente_detail_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/reportes/reportes_page.dart';
import 'route_names.dart';

GoRouter appRouter(SupabaseClient supabase) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;
      final isOnLogin = state.matchedLocation == RouteNames.login;
      final isOnSplash = state.matchedLocation == RouteNames.splash;

      if (isOnSplash) return null;

      if (!isLoggedIn && !isOnLogin) return RouteNames.login;
      if (isLoggedIn && isOnLogin) return RouteNames.dashboard;

      if (isLoggedIn) {
        final role = UserRole.fromString(
          session.user.userMetadata?['rol'] as String?,
        );
        if (role.isPracticante) {
          final location = state.matchedLocation;
          final isRestricted = location.startsWith(RouteNames.equipos) ||
              location.startsWith(RouteNames.docentes) ||
              location.startsWith(RouteNames.reportes);
          if (isRestricted) {
            return RouteNames.dashboard;
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteNames.prestamos,
            name: 'prestamos',
            builder: (context, state) => const LoansPage(),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'prestamoNuevo',
                builder: (context, state) => const LoanCreatePage(),
              ),
              GoRoute(
                path: ':id',
                name: 'prestamoDetalle',
                builder: (context, state) => const LoanDetailPage(),
              ),
              GoRoute(
                path: 'devolucion/:id',
                name: 'prestamoDevolucion',
                builder: (context, state) => LoanReturnPage(
                    prestamoId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.equipos,
            name: 'equipos',
            builder: (context, state) => const EquipmentPage(),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'equipoNuevo',
                builder: (context, state) => const EquipoFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'equipoDetalle',
                builder: (context, state) => const EquipoDetailPage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.docentes,
            name: 'docentes',
            builder: (context, state) => const TeachersPage(),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'docenteNuevo',
                builder: (context, state) => const DocenteFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'docenteDetalle',
                builder: (context, state) => const DocenteDetailPage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.historial,
            name: 'historial',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: RouteNames.reportes,
            name: 'reportes',
            builder: (context, state) => const ReportesPage(),
          ),
        ],
      ),
    ],
  );
}
