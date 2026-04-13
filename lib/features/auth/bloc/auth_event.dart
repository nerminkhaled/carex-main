part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignupSubmitted extends AuthEvent {
  const SignupSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.role = 'patient',
    this.dateOfBirth,
    this.gender,
    this.medicalConditions,
  });

  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final String? dateOfBirth;
  final String? gender;
  final String? medicalConditions;

  @override
  List<Object?> get props => [name, email, password, phone, role, dateOfBirth, gender, medicalConditions];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class FacebookSignInRequested extends AuthEvent {
  const FacebookSignInRequested();
}

class AppleSignInRequested extends AuthEvent {
  const AppleSignInRequested();
}

class ForgotPasswordSubmitted extends AuthEvent {
  const ForgotPasswordSubmitted({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class ResetPasswordSubmitted extends AuthEvent {
  const ResetPasswordSubmitted({required this.newPassword});

  final String newPassword;

  @override
  List<Object?> get props => [newPassword];
}
