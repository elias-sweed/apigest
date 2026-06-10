import '../../domain/entities/user_role.dart';

abstract final class Permissions {
  Permissions._();

  static bool canManageEquipos(UserRole role) => role.isEncargadoAip;
  static bool canManageDocentes(UserRole role) => role.isEncargadoAip;
  static bool canManageUsuarios(UserRole role) => role.isEncargadoAip;

  static bool canEditEquipo(UserRole role) => role.isEncargadoAip;
  static bool canEditDocente(UserRole role) => role.isEncargadoAip;
  static bool canDeleteDocente(UserRole role) => role.isEncargadoAip;
  static bool canChangeEquipoEstado(UserRole role) => role.isEncargadoAip;

  static bool canViewFullDashboard(UserRole role) => role.isEncargadoAip;
  static bool canViewRecentActivity(UserRole role) => role.isEncargadoAip;
  static bool canViewEquiposMantenimiento(UserRole role) => role.isEncargadoAip;
  static bool canViewReportes(UserRole role) => role.isEncargadoAip;
}
