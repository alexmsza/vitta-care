import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vitta/features/family/domain/entities/service_request.dart';

part 'service_request_provider.freezed.dart';
part 'service_request_provider.g.dart';

@freezed
class ServiceRequestState with _$ServiceRequestState {
  const factory ServiceRequestState({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    @Default(ServiceDuration.eightHours) ServiceDuration duration,
    @Default([]) List<String> selectedTags,
  }) = _ServiceRequestState;
}

@riverpod
class ServiceRequestController extends _$ServiceRequestController {
  @override
  ServiceRequestState build() {
    return const ServiceRequestState();
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  void setDuration(ServiceDuration duration) {
    state = state.copyWith(duration: duration);
  }

  void toggleTag(String tag) {
    final currentTags = [...state.selectedTags];
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    state = state.copyWith(selectedTags: currentTags);
  }

  double get estimatedPrice {
    // Base setup
    double basePrice = 0.0;

    switch (state.duration) {
      case ServiceDuration.eightHours:
        basePrice = 120.00;
        break;
      case ServiceDuration.twelveHours:
        basePrice = 170.00;
        break;
      case ServiceDuration.twentyFourHours:
        basePrice = 320.00;
        break;
    }

    // Tag adjustments (Example: 'Acamado' adds complexity/cost)
    if (state.selectedTags.contains('Acamado')) {
      basePrice += 30.00;
    }
    if (state.selectedTags.contains('Exp. com Alzheimer')) {
      basePrice += 40.00;
    }

    return basePrice;
  }
}
