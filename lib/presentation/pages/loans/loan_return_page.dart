import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/prestamo_providers.dart';
import '../../providers/devolucion_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../domain/entities/prestamo.dart';
import '../../widgets/signature/signature_pad.dart';

class LoanReturnPage extends ConsumerStatefulWidget {
  final String prestamoId;
  const LoanReturnPage({super.key, required this.prestamoId});

  @override
  ConsumerState<LoanReturnPage> createState() => _LoanReturnPageState();
}

class _LoanReturnPageState extends ConsumerState<LoanReturnPage> {
  int _step = 0;
  final Set<String> _selectedPeIds = {};
  final _observacionesController = TextEditingController();
  final _signatureKey = GlobalKey<SignaturePadState>();

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _nextStep() => setState(() => _step++);
  void _prevStep() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    final prestamoAsync = ref.watch(prestamoDetailProvider(widget.prestamoId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Seleccionar equipos' : 'Firma'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: prestamoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (prestamo) => Column(
          children: [
            Expanded(
              child: _step == 0
                  ? _buildEquiposStep(prestamo)
                  : _buildSignatureStep(prestamo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquiposStep(Prestamo prestamo) {
    final pendientes = prestamo.equipos.where((e) => !e.devuelto).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Devolver: ${prestamo.docenteNombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView(
            children: pendientes.map((pe) {
              final selected = _selectedPeIds.contains(pe.id);
              return CheckboxListTile(
                value: selected,
                title: Text(pe.equipoNombre),
                subtitle: Text(pe.equipoCodigo),
                secondary: const Icon(Icons.devices),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedPeIds.add(pe.id);
                    } else {
                      _selectedPeIds.remove(pe.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              hintText: 'Observaciones (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _selectedPeIds.isNotEmpty ? _nextStep : null,
                  child: Text('Continuar (${_selectedPeIds.length})'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureStep(Prestamo prestamo) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Recibe: ${prestamo.encargadoNombre}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Entrega: ${prestamo.docenteNombre}'),
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
                  onPressed: () => _submitReturn(prestamo),
                  icon: const Icon(Icons.check),
                  label: const Text('CONFIRMAR'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitReturn(Prestamo prestamo) async {
    final pngBytes = await _signatureKey.currentState?.capturePng();
    if (pngBytes == null || pngBytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe firmar antes de confirmar')),
        );
      }
      return;
    }

    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return;

    try {
      await ref.read(devolucionRepositoryProvider).registrarDevolucion(
            prestamoId: widget.prestamoId,
            practicanteId: user.id,
            prestamoEquipoIds: _selectedPeIds.toList(),
            observaciones: _observacionesController.text.isNotEmpty
                ? _observacionesController.text
                : null,
          );

      final signatureService = ref.read(signatureServiceProvider);
      await signatureService.uploadSignature(
        imageBytes: pngBytes,
        prestamoId: widget.prestamoId,
        userId: user.id,
        role: user.userMetadata?['rol'] as String? ?? 'practicante',
        nombreCompleto: user.userMetadata?['nombre_completo'] as String? ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devolución registrada'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(prestamoListProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
