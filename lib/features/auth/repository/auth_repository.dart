import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);

  Future<AuthResponse> signUpWithEmail(
    String name,
    String email,
    String password, {
    String role = 'patient',
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? medicalConditions,
  });

  Future<void> signInWithGoogle();
  Future<void> signInWithFacebook();
  Future<void> signInWithApple();
  Future<void> resetPasswordForEmail(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmail(
    String name,
    String email,
    String password, {
    String role = 'patient',
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? medicalConditions,
  }) async {
    print('SIGNUP STARTED');

    final response = await _client.auth
        .signUp(
          email: email,
          password: password,
          data: {
            'full_name': name,
            'role': role,
            if (phone != null) 'phone': phone,
            if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
            if (gender != null) 'gender': gender,
            if (medicalConditions != null)
              'medical_conditions': medicalConditions,
          },
        )
        .timeout(const Duration(seconds: 20));

    print('SIGNUP FINISHED');
    print('USER: ${response.user?.id}');
    print('SESSION: ${response.session != null}');

    return response;
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(OAuthProvider.facebook);
  }

  @override
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(OAuthProvider.apple);
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'carex://reset-password',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}