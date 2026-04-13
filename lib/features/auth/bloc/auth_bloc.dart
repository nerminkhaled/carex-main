import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_error.dart';
import '../repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<FacebookSignInRequested>(_onFacebookSignIn);
    on<AppleSignInRequested>(_onAppleSignIn);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  final AuthRepository _repository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signInWithEmail(event.email, event.password);
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }
Future<void> _onSignupSubmitted(
  SignupSubmitted event,
  Emitter<AuthState> emit,
) async {
  emit(const AuthLoading());
  print('BLOC: signup event received');

  try {
    final response = await _repository.signUpWithEmail(
      event.name,
      event.email,
      event.password,
      role: event.role,
      phone: event.phone,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
      medicalConditions: event.medicalConditions,
    );

    print('BLOC: signup response received');
    print('BLOC: user = ${response.user?.id}');
    print('BLOC: session exists = ${response.session != null}');

    if (response.user == null) {
      emit(const AuthFailure(message: 'Signup failed. No user returned.'));
      return;
    }

    if (response.session == null) {
      emit(const AuthEmailConfirmationRequired(
        message: 'Account created successfully. Please verify your email before logging in.',
      ));
      return;
    }

    emit(const AuthSuccess());
  } catch (e, st) {
    print('BLOC SIGNUP ERROR: $e');
    print(st);
    emit(AuthFailure(message: toUserMessage(e)));
  }
}

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signInWithGoogle();
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }

  Future<void> _onFacebookSignIn(
    FacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signInWithFacebook();
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }

  Future<void> _onAppleSignIn(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signInWithApple();
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.resetPasswordForEmail(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.updatePassword(event.newPassword);
      emit(const AuthPasswordUpdated());
    } catch (e) {
      emit(AuthFailure(message: toUserMessage(e)));
    }
  }
}
