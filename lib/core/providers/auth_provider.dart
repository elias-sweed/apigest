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

final currentUserRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider);
  return UserRole.fromString(user?.userMetadata?['rol'] as String?);
});
