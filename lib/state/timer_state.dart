import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final Duration elapsed;
  final bool running;
  const TimerState({required this.elapsed, required this.running});

  TimerState copyWith({Duration? elapsed, bool? running}) =>
      TimerState(elapsed: elapsed ?? this.elapsed, running: running ?? this.running);
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(const TimerState(elapsed: Duration.zero, running: false));

  Timer? _ticker;

  void start() {
    if (state.running) return;
    state = state.copyWith(running: true);
    _ticker ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(elapsed: state.elapsed + const Duration(milliseconds: 100));
    });
  }

  void pause() {
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(running: false);
  }

  void reset() {
    pause();
    state = const TimerState(elapsed: Duration.zero, running: false);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier());


