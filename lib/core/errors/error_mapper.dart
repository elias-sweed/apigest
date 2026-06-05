import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_messages.dart';

class ErrorMapper {
  ErrorMapper._();

  static String map(Object error, {String? context}) {
    final message = error.toString().toLowerCase();

    if (error is SocketException) {
      return AppMessages.sinConexion;
    }

    if (error is FormatException) {
      return AppMessages.errorInesperado;
    }

    if (error is PostgrestException) {
      final code = _parseCode(error);
      if (code != null) {
        final mapped = _mapPostgresCode(code, context: context);
        if (mapped != null) return mapped;
      }
    }

    if (message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated') ||
        message.contains('handshake error')) {
      return AppMessages.sinConexion;
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return AppMessages.sinConexion;
    }

    if (message.contains('23505') || message.contains('duplicate key')) {
      return _mapDuplicate(context);
    }

    if (message.contains('23502') ||
        message.contains('null value') ||
        message.contains('not-null')) {
      return AppMessages.errorDatosObligatorios;
    }

    if (message.contains('23503') || message.contains('foreign key')) {
      return AppMessages.errorDatosObligatorios;
    }

    return _fallback(context);
  }

  static String? _parseCode(PostgrestException e) {
    if (e.code != null && e.code!.isNotEmpty) return e.code;
    return null;
  }

  static String? _mapPostgresCode(String code, {String? context}) {
    switch (code) {
      case '23505':
        return _mapDuplicate(context);
      case '23502':
        return AppMessages.errorDatosObligatorios;
      case '23503':
        return AppMessages.errorDatosObligatorios;
      case '42P01':
      case '42P02':
        return AppMessages.errorInesperado;
    }
    return null;
  }

  static String _mapDuplicate(String? context) {
    switch (context) {
      case 'create_equipo':
      case 'update_equipo':
        return AppMessages.errorEquipoDuplicado;
      case 'create_docente':
      case 'update_docente':
        return AppMessages.docenteDuplicado;
      case 'add_equipo_prestamo':
        return AppMessages.equipoDuplicadoPrestamo;
      default:
        return AppMessages.errorRegistroDuplicado;
    }
  }

  static String _fallback(String? context) {
    switch (context) {
      case 'create_prestamo':
        return AppMessages.errorPrestamo;
      case 'create_devolucion':
        return AppMessages.errorDevolucion;
      case 'load_equipos':
        return AppMessages.errorCargaEquipos;
      case 'load_docentes':
        return AppMessages.errorCargaDocentes;
      default:
        return AppMessages.errorInesperado;
    }
  }
}
