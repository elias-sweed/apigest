import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignatureService {
  final SupabaseClient _client;
  static const String _bucket = 'firmas';

  SignatureService(this._client);

  Future<String> uploadSignature({
    required Uint8List imageBytes,
    required String prestamoId,
    required String userId,
    required String role,
    required String nombreCompleto,
    String? devolucionId,
  }) async {
    final context = devolucionId != null ? 'devoluciones' : 'prestamos';
    final contextId = devolucionId ?? prestamoId;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$context/$contextId/${role}_$timestamp.png';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );

    await _client.from('firmas_digitales').insert({
      'prestamo_id': devolucionId != null ? null : prestamoId,
      'devolucion_id': devolucionId,
      'usuario_id': userId,
      'rol': role,
      'nombre_completo': nombreCompleto,
      'storage_path': path,
      'mime_type': 'image/png',
    });

    return path;
  }
}
