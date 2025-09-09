import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class RunSample {
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  const RunSample({required this.timestamp, required this.latitude, required this.longitude});
}

class RunState {
  final bool running;
  final bool paused;
  final Duration elapsed;
  final double distanceMeters;
  final List<RunSample> path;
  final DateTime? startedAt;

  const RunState({
    required this.running,
    required this.paused,
    required this.elapsed,
    required this.distanceMeters,
    required this.path,
    this.startedAt,
  });

  RunState copyWith({
    bool? running,
    bool? paused,
    Duration? elapsed,
    double? distanceMeters,
    List<RunSample>? path,
    DateTime? startedAt,
  }) =>
      RunState(
        running: running ?? this.running,
        paused: paused ?? this.paused,
        elapsed: elapsed ?? this.elapsed,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        path: path ?? this.path,
        startedAt: startedAt ?? this.startedAt,
      );

  static const initial = RunState(
    running: false,
    paused: false,
    elapsed: Duration.zero,
    distanceMeters: 0.0,
    path: <RunSample>[],
    startedAt: null,
  );
}

class RunNotifier extends StateNotifier<RunState> {
  RunNotifier() : super(RunState.initial);

  StreamSubscription<Position>? _pos;
  Timer? _ticker;

  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<void> start() async {
    if (state.running) return;
    final ok = await ensurePermission();
    if (!ok) return;
    state = state.copyWith(running: true, paused: false, startedAt: DateTime.now());

    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.running && !state.paused) {
        state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
      }
    });

    _pos ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 3),
    ).listen((p) {
      if (!state.running || state.paused) return;
      final sample = RunSample(timestamp: DateTime.now(), latitude: p.latitude, longitude: p.longitude);
      double addMeters = 0.0;
      if (state.path.isNotEmpty) {
        final last = state.path.last;
        addMeters = _haversineMeters(last.latitude, last.longitude, sample.latitude, sample.longitude);
      }
      final nextPath = [...state.path, sample];
      state = state.copyWith(distanceMeters: state.distanceMeters + addMeters, path: nextPath);
    });
  }

  void pause() {
    if (!state.running || state.paused) return;
    state = state.copyWith(paused: true);
  }

  void resume() {
    if (!state.running || !state.paused) return;
    state = state.copyWith(paused: false);
  }

  void stop() {
    _pos?.cancel();
    _pos = null;
    _ticker?.cancel();
    _ticker = null;
    state = RunState.initial;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  @override
  void dispose() {
    _pos?.cancel();
    _ticker?.cancel();
    super.dispose();
  }
}

final runProvider = StateNotifierProvider<RunNotifier, RunState>((ref) => RunNotifier());


