import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/prestamo_providers.dart';
import '../../providers/docente_providers.dart';
import '../../providers/equipo_providers.dart';
import '../../providers/devolucion_providers.dart';
import '../../../core/errors/app_messages.dart';
import '../../../core/errors/error_helpers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../domain/entities/docente.dart';
import '../../widgets/signature/signature_pad.dart';

class LoanCreatePage extends ConsumerStatefulWidget {
  const LoanCreatePage({super.key});

  @override
  ConsumerState<LoanCreatePage> createState() => _LoanCreatePageState();
}

class _LoanCreatePageState extends ConsumerState<LoanCreatePage> {
  int _step = 0;
  Docente? _selectedDocente;
  final Set<String> _selectedEquipoIds = {};
  final _searchController = TextEditingController();
  final _signatureKey = GlobalKey<SignaturePadState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _nextStep() => setState(() => _step++);
  void _prevStep() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Seleccionar docente',
      'Seleccionar equipos',
      'Firma digital',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_step < titles.length ? titles[_step] : 'Confirmar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _StepperIndicator(currentStep: _step, totalSteps: 3),
          Expanded(
            child: _step == 0
                ? _buildDocenteStep()
                : _step == 1
                    ? _buildEquiposStep()
                    : _buildSignatureStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocenteStep() {
    final docentes = ref.watch(docenteListProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar docente...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => ref.read(docenteSearchProvider.notifier).state =
                _searchController.text,
          ),
        ),
        Expanded(
          child: docentes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text(AppMessages.errorCarga)),
            data: (lista) {
              final filtered = lista.where((d) {
                if (!d.activo) return false;
                final q = _searchController.text.toLowerCase();
                if (q.isEmpty) return true;
                return d.nombreCompleto.toLowerCase().contains(q);
              }).toList();
              if (filtered.isEmpty) {
                return const Center(child: Text('No se encontraron docentes'));
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final d = filtered[index];
                  final selected = _selectedDocente?.id == d.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      child: Icon(Icons.person,
                          color: selected ? Colors.white : Colors.grey),
                    ),
                    title: Text(d.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: d.grado != null ? Text(d.grado!) : null,
                    trailing:
                        selected ? const Icon(Icons.check_circle) : null,
                    onTap: () {
                      setState(() => _selectedDocente = d);
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedDocente != null ? _nextStep : null,
              child: const Text('Continuar'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquiposStep() {
    final equipos = ref.watch(equipoListProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar equipo...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                ref.read(equipoSearchProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: equipos.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text(AppMessages.errorCarga)),
            data: (lista) {
              final disponibles = lista
                  .where((e) =>
                      e.estado == 'disponible' ||
                      _selectedEquipoIds.contains(e.id))
                  .toList();
              if (disponibles.isEmpty) {
                return const Center(
                    child: Text('No hay equipos disponibles'));
              }
              return ListView.builder(
                itemCount: disponibles.length,
                itemBuilder: (context, index) {
                  final e = disponibles[index];
                  final selected = _selectedEquipoIds.contains(e.id);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(e.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(e.codigoPatrimonial),
                    secondary: Icon(
                      selected ? Icons.check_circle : Icons.devices,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedEquipoIds.add(e.id);
                        } else {
                          _selectedEquipoIds.remove(e.id);
                        }
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed:
                      _selectedEquipoIds.isNotEmpty ? _nextStep : null,
                  child:
                      Text('Continuar (${_selectedEquipoIds.length})'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_selectedDocente != null)
                Text('Docente: ${_selectedDocente!.nombreCompleto}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${_selectedEquipoIds.length} equipo(s) seleccionado(s)'),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SignaturePad(key: _signatureKey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submitLoan,
                  icon: const Icon(Icons.check),
                  label: const Text('CREAR PRÉSTAMO'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitLoan() async {
    if (_selectedDocente == null || _selectedEquipoIds.isEmpty) return;

    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final prestamoData = {
      'docente_id': _selectedDocente!.id,
      'encargado_id': user.id,
    };

    final equiposData = _selectedEquipoIds
        .map((id) => {'equipo_id': id, 'fecha_devolucion_real': null})
        .toList();

    try {
      final prestamo = await ref.read(prestamoRepositoryProvider).createPrestamo(
            prestamoData,
            equiposData,
          );

      final pngBytes = await _signatureKey.currentState?.capturePng();
      if (pngBytes != null && pngBytes.isNotEmpty) {
        final signatureService = ref.read(signatureServiceProvider);
        await signatureService.uploadSignature(
          imageBytes: pngBytes,
          prestamoId: prestamo.id,
          userId: user.id,
          role: user.userMetadata?['rol'] as String? ?? 'encargado_aip',
          nombreCompleto:
              user.userMetadata?['nombre_completo'] as String? ?? '',
        );
      }

      if (mounted) {
        showSuccess(context, AppMessages.prestamoCreado);
        ref.invalidate(prestamoListProvider);
        ref.invalidate(equipoListProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) showError(context, e, errorContext: 'create_prestamo');
    }
  }
}

class _StepperIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepperIndicator(
      {required this.currentStep, this.totalSteps = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final done = index < currentStep;
          final active = index == currentStep;
          return Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: done || active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
