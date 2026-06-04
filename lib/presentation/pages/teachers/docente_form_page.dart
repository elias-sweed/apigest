import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/docente.dart';
import '../../providers/docente_providers.dart';

class DocenteFormPage extends ConsumerStatefulWidget {
  const DocenteFormPage({super.key});

  @override
  ConsumerState<DocenteFormPage> createState() => _DocenteFormPageState();
}

class _DocenteFormPageState extends ConsumerState<DocenteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _gradoController = TextEditingController();
  final _seccionController = TextEditingController();
  String? _turno;
  bool _isSaving = false;
  Docente? _editDocente;

  static const _turnos = ['mañana', 'tarde'];

  bool get _isEditing => _editDocente != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Docente) {
        setState(() {
          _editDocente = extra;
          _nombresController.text = extra.nombres;
          _apellidosController.text = extra.apellidos;
          _gradoController.text = extra.grado ?? '';
          _seccionController.text = extra.seccion ?? '';
          _turno = extra.turno;
        });
      }
    });
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _gradoController.dispose();
    _seccionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(docenteRepositoryProvider);
      final now = DateTime.now();

      final docente = Docente(
        id: _editDocente?.id ?? const Uuid().v4(),
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        grado: _gradoController.text.trim().isEmpty
            ? null
            : _gradoController.text.trim(),
        seccion: _seccionController.text.trim().isEmpty
            ? null
            : _seccionController.text.trim(),
        turno: _turno,
        activo: _editDocente?.activo ?? true,
        createdAt: _editDocente?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await repository.updateDocente(docente);
      } else {
        await repository.createDocente(docente);
      }

      ref.invalidate(docenteListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar docente' : 'Nuevo docente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradoController,
                decoration: const InputDecoration(
                  labelText: 'Grado',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seccionController,
                decoration: const InputDecoration(
                  labelText: 'Sección',
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _turno,
                decoration: const InputDecoration(
                  labelText: 'Turno',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: _turnos.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t == 'mañana' ? 'Mañana' : 'Tarde'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _turno = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
