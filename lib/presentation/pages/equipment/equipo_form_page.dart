import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/error_helpers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/equipo_providers.dart';

class EquipoFormPage extends ConsumerStatefulWidget {
  const EquipoFormPage({super.key});

  @override
  ConsumerState<EquipoFormPage> createState() => _EquipoFormPageState();
}

class _EquipoFormPageState extends ConsumerState<EquipoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _serieController = TextEditingController();
  final _observacionesController = TextEditingController();

  String? _tipo;
  bool _isSaving = false;
  Equipo? _editEquipo;

  static const _tipos = [
    'laptop_dell',
    'laptop_hp',
    'cargador',
    'extension',
    'otro_accesorio',
  ];

  bool get _isEditing => _editEquipo != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Equipo) {
        setState(() {
          _editEquipo = extra;
          _codigoController.text = extra.codigoPatrimonial;
          _tipo = extra.tipo;
          _marcaController.text = extra.marca ?? '';
          _modeloController.text = extra.modelo ?? '';
          _serieController.text = extra.numeroSerie ?? '';
          _observacionesController.text = extra.observaciones ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _serieController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(equipoRepositoryProvider);
      final now = DateTime.now();

      if (_isEditing) {
        await repository.updateEquipo(Equipo(
          id: _editEquipo!.id,
          codigoPatrimonial: _codigoController.text.trim(),
          tipo: _tipo!,
          marca: _marcaController.text.trim().isEmpty
              ? null
              : _marcaController.text.trim(),
          modelo: _modeloController.text.trim().isEmpty
              ? null
              : _modeloController.text.trim(),
          numeroSerie: _serieController.text.trim().isEmpty
              ? null
              : _serieController.text.trim(),
          estado: _editEquipo!.estado,
          observaciones: _observacionesController.text.trim().isEmpty
              ? null
              : _observacionesController.text.trim(),
          imagenUrl: _editEquipo!.imagenUrl,
          createdAt: _editEquipo!.createdAt,
          updatedAt: now,
        ));
      } else {
        await repository.createEquipo(Equipo(
          id: const Uuid().v4(),
          codigoPatrimonial: _codigoController.text.trim(),
          tipo: _tipo!,
          marca: _marcaController.text.trim().isEmpty
              ? null
              : _marcaController.text.trim(),
          modelo: _modeloController.text.trim().isEmpty
              ? null
              : _modeloController.text.trim(),
          numeroSerie: _serieController.text.trim().isEmpty
              ? null
              : _serieController.text.trim(),
          estado: 'disponible',
          observaciones: _observacionesController.text.trim().isEmpty
              ? null
              : _observacionesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        ));
      }

      ref.invalidate(equipoListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        showError(
          context,
          e,
          errorContext: _isEditing ? 'update_equipo' : 'create_equipo',
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
        title: Text(_isEditing ? 'Editar equipo' : 'Nuevo equipo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código patrimonial',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _tipos.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(Equipo.tipoLabels[t] ?? t),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _tipo = v),
                validator: (v) => v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serieController,
                decoration: const InputDecoration(
                  labelText: 'Número de serie',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes),
                ),
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
