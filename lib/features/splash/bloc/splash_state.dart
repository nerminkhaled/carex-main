part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashFinished extends SplashState {
  const SplashFinished({required this.showOnboarding, this.isLoggedIn = false});

  final bool showOnboarding;
  final bool isLoggedIn;

  @override
  List<Object> get props => [showOnboarding, isLoggedIn];
}
