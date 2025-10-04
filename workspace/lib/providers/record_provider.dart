import 'package:flutter/foundation.dart';
import 'dart:async';

enum RecordingState { idle, recording, paused, stopped, processing }

class RecordProvider extends ChangeNotifier {
  RecordingState _state = RecordingState.idle;
  Duration _duration = Duration.zero;
  String? _recordingPath;
  Timer? _timer;
  bool _isLoading = false;
  String? _error;

  // Getters
  RecordingState get state => _state;
  Duration get duration => _duration;
  String? get recordingPath => _recordingPath;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // State checks
  bool get isIdle => _state == RecordingState.idle;
  bool get isRecording => _state == RecordingState.recording;
  bool get isPaused => _state == RecordingState.paused;
  bool get isStopped => _state == RecordingState.stopped;
  bool get isProcessing => _state == RecordingState.processing;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Start recording
  Future<bool> startRecording() async {
    try {
      clearError();
      _setLoading(true);

      // TODO: Initialize flutter_sound recorder
      // TODO: Request microphone permissions
      // TODO: Start actual audio recording

      // For now, simulate recording
      await Future.delayed(const Duration(milliseconds: 500));

      _state = RecordingState.recording;
      _duration = Duration.zero;
      _recordingPath = null;

      // Start duration timer
      _startTimer();

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    try {
      clearError();
      _setLoading(true);

      // Stop the timer
      _stopTimer();

      // TODO: Stop flutter_sound recorder
      // TODO: Get the recorded file path

      // For now, simulate stopping recording
      await Future.delayed(const Duration(milliseconds: 500));

      _state = RecordingState.stopped;
      _recordingPath =
          'temp_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      _setLoading(false);
      return _recordingPath;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Pause recording
  Future<bool> pauseRecording() async {
    try {
      clearError();

      // TODO: Pause flutter_sound recorder
      await Future.delayed(const Duration(milliseconds: 200));

      _state = RecordingState.paused;
      _stopTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resume recording
  Future<bool> resumeRecording() async {
    try {
      clearError();

      // TODO: Resume flutter_sound recorder
      await Future.delayed(const Duration(milliseconds: 200));

      _state = RecordingState.recording;
      _startTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      clearError();

      // Stop timer
      _stopTimer();

      // TODO: Cancel flutter_sound recorder
      // TODO: Delete the temporary recording file
      await Future.delayed(const Duration(milliseconds: 200));

      _reset();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Start processing recorded audio
  Future<void> startProcessing() async {
    if (_recordingPath == null) return;

    try {
      clearError();
      _state = RecordingState.processing;
      notifyListeners();

      // TODO: Upload to Supabase storage
      // TODO: Trigger transcription pipeline
      await Future.delayed(const Duration(seconds: 2));

      // Reset after processing starts
      _reset();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Private methods
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: _duration.inSeconds + 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _reset() {
    _state = RecordingState.idle;
    _duration = Duration.zero;
    _recordingPath = null;
    _stopTimer();
    notifyListeners();
  }

  // Format duration for display
  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_duration.inMinutes);
    String seconds = twoDigits(_duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Check if recording is at maximum duration (e.g., 5 minutes)
  bool get isAtMaxDuration => _duration.inMinutes >= 5;

  // Get recording level (for waveform visualization)
  // TODO: Implement actual audio level detection
  double get currentLevel {
    if (!isRecording) return 0.0;
    // Simulate varying audio levels
    return (DateTime.now().millisecond % 100) / 100.0;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
