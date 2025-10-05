import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/backend_api_service.dart';
import '../models/story.dart';

enum ProcessingStep {
  idle,
  analyzingRecording,
  creatingStory,
  addingIllustrations,
  completed,
  error,
}

class StoryProcessingProvider extends ChangeNotifier {
  ProcessingStep _currentStep = ProcessingStep.idle;
  String? _error;
  bool _isProcessing = false;

  // Backend service
  final BackendApiService _apiService = BackendApiService();

  // Generated content
  Story? _generatedStory;
  String? _memoryTitle;
  Duration? _recordingDuration;

  // Progress tracking
  double _progress = 0.0;
  double _uploadProgress = 0.0;
  Timer? _progressTimer;

  // Getters
  ProcessingStep get currentStep => _currentStep;
  String? get error => _error;
  bool get isProcessing => _isProcessing;
  Story? get generatedStory => _generatedStory;
  String? get memoryTitle => _memoryTitle;
  Duration? get recordingDuration => _recordingDuration;
  double get progress => _progress;
  double get uploadProgress => _uploadProgress;

  // State checks
  bool get isIdle => _currentStep == ProcessingStep.idle;
  bool get isAnalyzing => _currentStep == ProcessingStep.analyzingRecording;
  bool get isCreatingStory => _currentStep == ProcessingStep.creatingStory;
  bool get isAddingIllustrations =>
      _currentStep == ProcessingStep.addingIllustrations;
  bool get isCompleted => _currentStep == ProcessingStep.completed;
  bool get hasError => _currentStep == ProcessingStep.error;

  // Clear error
  void clearError() {
    _error = null;
    if (_currentStep == ProcessingStep.error) {
      _currentStep = ProcessingStep.idle;
    }
    notifyListeners();
  }

  // Start processing the recorded audio
  Future<void> processRecording({
    required String audioFilePath,
    required String memoryTitle,
    required Duration recordingDuration,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _memoryTitle = memoryTitle;
      _recordingDuration = recordingDuration;
      _progress = 0.0;
      _uploadProgress = 0.0;
      notifyListeners();

      // Call backend API to process audio and generate story
      await _processWithBackend(audioFilePath, memoryTitle);

      // Complete
      _currentStep = ProcessingStep.completed;
      _isProcessing = false;
      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _currentStep = ProcessingStep.error;
      _isProcessing = false;
      _stopProgressTimer();
      notifyListeners();
    }
  }

  // Process with actual backend API
  Future<void> _processWithBackend(
    String audioFilePath,
    String memoryTitle,
  ) async {
    // Step 1: Analyzing recording
    _currentStep = ProcessingStep.analyzingRecording;
    _progress = 0.0;
    notifyListeners();

    try {
      // Add timeout to prevent infinite waiting
      final storyResponse = await _apiService
          .uploadAudioAndGenerateStory(
            audioFilePath: audioFilePath,
            title: memoryTitle,
            onUploadProgress: (progress) {
              _uploadProgress = progress;
              _progress = progress * 0.3; // 30% for upload
              notifyListeners();
            },
          )
          .timeout(
            const Duration(minutes: 3), // 3 minute timeout
            onTimeout: () {
              throw Exception('Request timed out. Please try again.');
            },
          );

      // Step 2: Creating story (this happens on backend)
      _currentStep = ProcessingStep.creatingStory;
      _progress = 0.4;
      notifyListeners();

      // Step 3: Adding illustrations (final processing)
      _currentStep = ProcessingStep.addingIllustrations;
      _progress = 0.8;
      notifyListeners();

      // Create story object from response
      _generatedStory = Story(
        id: storyResponse.id,
        title: storyResponse.title,
        subtitle: memoryTitle,
        text: storyResponse.text,
        imageUrl: storyResponse.imageUrl,
        audioUrls: storyResponse.audioUrls,
        totalPages: storyResponse.totalPages,
        createdAt: storyResponse.createdAt,
        originalAudioPath: audioFilePath,
      );

      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      print('Backend processing failed: $e');
      // Fallback to mock data for development/testing
      try {
        await _processMockData(audioFilePath, memoryTitle);
      } catch (mockError) {
        print('Mock processing also failed: $mockError');
        _error = 'Processing failed: ${e.toString()}';
        _currentStep = ProcessingStep.error;
        _isProcessing = false;
        _stopProgressTimer();
        notifyListeners();
      }
    }
  }

  // Mock processing for development (when backend is not available)
  Future<void> _processMockData(
    String audioFilePath,
    String memoryTitle,
  ) async {
    // Step 1: Analyzing recording
    _currentStep = ProcessingStep.analyzingRecording;
    _startProgressTimer(0.0, 0.33, const Duration(seconds: 2));
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));

    // Step 2: Creating story
    _currentStep = ProcessingStep.creatingStory;
    _startProgressTimer(0.33, 0.66, const Duration(seconds: 3));
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));

    // Step 3: Adding illustrations
    _currentStep = ProcessingStep.addingIllustrations;
    _startProgressTimer(0.66, 1.0, const Duration(seconds: 2));
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));

    // Create mock story
    _generatedStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "The Brave Little Soldier",
      subtitle: "From $memoryTitle",
      text:
          """Once upon a time, there was a very brave little soldier who went on amazing adventures across distant lands.

The little soldier carried with him the wisdom and courage that had been passed down through generations. Every step he took was filled with purpose, and every challenge he faced made him stronger.

Through mountains high and valleys low, the brave little soldier continued his journey, knowing that the memories of his family would always guide him home.""",
      imageUrl:
          "https://via.placeholder.com/400x300/4F46E5/FFFFFF?text=Story+Image",
      audioUrls: [],
      totalPages: 3,
      createdAt: DateTime.now(),
      originalAudioPath: audioFilePath,
    );

    _stopProgressTimer();
    _progress = 1.0;
    notifyListeners();
  }

  // Progress timer helper
  void _startProgressTimer(double start, double end, Duration duration) {
    _stopProgressTimer();
    _progress = start;

    const tickDuration = Duration(milliseconds: 100);
    final totalTicks = duration.inMilliseconds / tickDuration.inMilliseconds;
    final progressPerTick = (end - start) / totalTicks;

    _progressTimer = Timer.periodic(tickDuration, (timer) {
      _progress += progressPerTick;
      if (_progress >= end) {
        _progress = end;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  // Reset state
  void reset() {
    _currentStep = ProcessingStep.idle;
    _error = null;
    _isProcessing = false;
    _generatedStory = null;
    _memoryTitle = null;
    _recordingDuration = null;
    _progress = 0.0;
    _uploadProgress = 0.0;
    _stopProgressTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopProgressTimer();
    super.dispose();
  }
}
