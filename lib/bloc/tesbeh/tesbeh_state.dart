import 'package:flutter/material.dart';

@immutable
sealed class TesbehState {}

class TesbehInitial extends TesbehState {}

class TesbehUpdate extends TesbehState {}

class TesbehReset extends TesbehState {}
