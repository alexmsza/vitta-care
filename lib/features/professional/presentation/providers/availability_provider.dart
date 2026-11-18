import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

/// In-memory off-days for the logged-in caregiver.
/// Session-only until a backend endpoint for availability is exposed.
class UnavailableDaysNotifier extends StateNotifier<Set<DateTime>> {
  UnavailableDaysNotifier() : super(<DateTime>{});

  bool isOff(DateTime day) => state.contains(_dateKey(day));

  void toggle(DateTime day) {
    final key = _dateKey(day);
    final next = Set<DateTime>.from(state);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = next;
  }

  void setMany(Iterable<DateTime> days, {required bool off}) {
    final next = Set<DateTime>.from(state);
    for (final d in days) {
      final key = _dateKey(d);
      if (off) {
        next.add(key);
      } else {
        next.remove(key);
      }
    }
    state = next;
  }
}

final unavailableDaysProvider =
    StateNotifierProvider<UnavailableDaysNotifier, Set<DateTime>>(
  (ref) => UnavailableDaysNotifier(),
);
