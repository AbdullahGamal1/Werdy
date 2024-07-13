part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeTabUpdateScreen extends HomeState {}

final class SuccessRaedFile extends HomeState {}

final class LoadingRaedFile extends HomeState {}

final class ErrorRaedFile extends HomeState {}
