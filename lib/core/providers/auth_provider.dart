import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_role.dart';
import '../network/supabase_client.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return SupabaseClientConfig.client;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUserRoleProvider = FutureProvider<UserRole>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return UserRole.practicante;

  final metadataRole = user.userMetadata?['rol'] as String?;
  if (metadataRole != null) return UserRole.fromString(metadataRole);

  final supabase = ref.read(supabaseProvider);
  try {
    final result = await supabase
        .from('usuarios')
        .select('rol')
        .eq('email', user.email ?? '')
        .maybeSingle();
    if (result != null) {
      return UserRole.fromString(result['rol'] as String?);
    }
  } catch (_) {}

  return UserRole.practicante;
});

final logoutProvider = Provider<void Function()>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return () async => supabase.auth.signOut();
});
