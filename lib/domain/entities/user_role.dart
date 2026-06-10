enum UserRole {
  encargadoAip,
  practicante;

  static UserRole fromString(String? value) {
    return switch (value) {
      'encargado_aip' => UserRole.encargadoAip,
      _ => UserRole.practicante,
    };
  }

  bool get isEncargadoAip => this == UserRole.encargadoAip;
  bool get isPracticante => this == UserRole.practicante;
}
