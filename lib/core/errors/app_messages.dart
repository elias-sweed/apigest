class AppMessages {
  AppMessages._();

  static const String equipoDuplicadoPrestamo =
      'Este equipo ya fue agregado al préstamo.';
  static const String equipoYaPrestado =
      'Este equipo ya se encuentra prestado actualmente.';
  static const String equipoEnMantenimiento =
      'Este equipo está en mantenimiento y no puede prestarse.';

  static const String docenteDuplicado =
      'Ya existe un docente registrado con esos datos.';

  static const String faltaEquipos = 'Seleccione al menos un equipo.';
  static const String faltaDocente = 'Seleccione un docente.';
  static const String faltaFirma =
      'Debe registrar una firma antes de continuar.';
  static const String errorPrestamo =
      'No se pudo registrar el préstamo. Intente nuevamente.';

  static const String faltaEquiposDevolucion =
      'Seleccione al menos un equipo para devolver.';
  static const String errorDevolucion =
      'No se pudo registrar la devolución.';

  static const String sinConexion =
      'Sin conexión. Los cambios se sincronizarán automáticamente cuando vuelva la conexión.';

  static const String errorInesperado =
      'Ocurrió un error inesperado. Intente nuevamente.';
  static const String errorCarga = 'No se pudieron cargar los datos.';
  static const String errorCargaEquipos =
      'No se pudieron cargar los equipos.';
  static const String errorCargaDocentes =
      'No se pudieron cargar los docentes.';
  static const String errorDatosObligatorios =
      'Faltan datos obligatorios. Verifique el formulario.';
  static const String errorRegistroDuplicado =
      'Ya existe un registro con esos datos.';
  static const String errorEquipoDuplicado =
      'Ya existe un equipo con ese código patrimonial.';

  static const String prestamoCreado = 'Préstamo creado exitosamente';
  static const String devolucionRegistrada = 'Devolución registrada';
  static const String docenteGuardado = 'Docente guardado correctamente';
  static const String equipoGuardado = 'Equipo guardado correctamente';
  static const String estadoCambiado = 'Estado cambiado correctamente';
}
