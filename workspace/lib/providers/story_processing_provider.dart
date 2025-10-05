import 'package:flutter/foundation.dart';
import 'dart:async';
// TODO: Add http package for API calls
// import 'package:http/http.dart' as http;
// import 'dart:convert';

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

  // Generated content
  String? _generatedStoryText;
  String? _audioStoryUrl;
  String? _memoryTitle;
  Duration? _recordingDuration;

  // Progress tracking
  double _progress = 0.0;
  Timer? _progressTimer;

  // Getters
  ProcessingStep get currentStep => _currentStep;
  String? get error => _error;
  bool get isProcessing => _isProcessing;
  String? get generatedStoryText => _generatedStoryText;
  String? get audioStoryUrl => _audioStoryUrl;
  String? get memoryTitle => _memoryTitle;
  Duration? get recordingDuration => _recordingDuration;
  double get progress => _progress;

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
      notifyListeners();

      // Step 1: Analyzing recording
      await _stepAnalyzeRecording(audioFilePath);

      // Step 2: Creating story
      await _stepCreateStory();

      // Step 3: Adding illustrations (text-to-speech)
      await _stepAddIllustrations();

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

  // Step 1: Analyze recording (speech-to-text)
  Future<void> _stepAnalyzeRecording(String audioFilePath) async {
    _currentStep = ProcessingStep.analyzingRecording;
    _startProgressTimer(0.0, 0.33, Duration(seconds: 3));
    notifyListeners();

    // TODO: Implement actual backend API call
    // Example API call structure:
    /*
    try {
      // Upload audio file to backend
      var request = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/analyze-audio'));
      request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
      request.fields['memory_title'] = _memoryTitle!;
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (response.statusCode == 200) {
        // Store transcribed text for next step
        String transcribedText = jsonData['transcribed_text'];
        // Continue to next step
      } else {
        throw Exception('Failed to analyze recording: ${jsonData['error']}');
      }
    } catch (e) {
      throw Exception('Network error during audio analysis: $e');
    }
    */

    // Simulate API call for now
    await Future.delayed(const Duration(seconds: 3));

    // Simulate transcribed text
    _generatedStoryText =
        "Transcribed audio content..."; // This would be real transcription
  }

  // Step 2: Create story using Gemini API
  Future<void> _stepCreateStory() async {
    _currentStep = ProcessingStep.creatingStory;
    _startProgressTimer(0.33, 0.66, Duration(seconds: 4));
    notifyListeners();

    // TODO: Implement actual Gemini API call through backend
    // Example API call structure:
    /*
    try {
      var response = await http.post(
        Uri.parse('$backendUrl/api/generate-story'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transcribed_text': _generatedStoryText,
          'memory_title': _memoryTitle,
          'recording_duration': _recordingDuration?.inSeconds,
          'user_preferences': {
            'story_style': 'bedtime',
            'target_age': '5-8',
            'include_moral': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        _generatedStoryText = jsonData['generated_story'];
        // Continue to next step
      } else {
        var errorData = json.decode(response.body);
        throw Exception('Failed to generate story: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Network error during story generation: $e');
    }
    */

    // Simulate API call for now
    await Future.delayed(const Duration(seconds: 4));

    // Simulate generated story
    _generatedStoryText = """
Once upon a time, there was a magical memory that needed to be shared with the world. 
This memory was so special that it could bring families closer together and create 
beautiful bedtime stories for children to enjoy. The memory was full of love, 
laughter, and important life lessons that would be treasured for generations to come.
""";
  }

  // Step 3: Add illustrations (text-to-speech)
  Future<void> _stepAddIllustrations() async {
    _currentStep = ProcessingStep.addingIllustrations;
    _startProgressTimer(0.66, 1.0, Duration(seconds: 3));
    notifyListeners();

    // TODO: Implement actual text-to-speech API call through backend
    // Example API call structure:
    /*
    try {
      var response = await http.post(
        Uri.parse('$backendUrl/api/text-to-speech'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'story_text': _generatedStoryText,
          'voice_settings': {
            'voice_type': 'narrator',
            'speed': 'normal',
            'emotion': 'warm',
          },
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        _audioStoryUrl = jsonData['audio_url'];
        // Processing complete
      } else {
        var errorData = json.decode(response.body);
        throw Exception('Failed to generate audio: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Network error during audio generation: $e');
    }
    */

    // Simulate API call for now
    await Future.delayed(const Duration(seconds: 3));

    // Simulate generated audio URL
    _audioStoryUrl = "https://example.com/generated-story-audio.mp3";
  }

  // Progress timer helper
  void _startProgressTimer(
    double startProgress,
    double endProgress,
    Duration duration,
  ) {
    _stopProgressTimer();
    _progress = startProgress;

    const updateInterval = Duration(milliseconds: 100);
    final totalSteps = duration.inMilliseconds / updateInterval.inMilliseconds;
    final progressPerStep = (endProgress - startProgress) / totalSteps;

    _progressTimer = Timer.periodic(updateInterval, (timer) {
      _progress += progressPerStep;
      if (_progress >= endProgress) {
        _progress = endProgress;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  // Reset processing state
  void reset() {
    _currentStep = ProcessingStep.idle;
    _error = null;
    _isProcessing = false;
    _generatedStoryText = null;
    _audioStoryUrl = null;
    _memoryTitle = null;
    _recordingDuration = null;
    _progress = 0.0;
    _stopProgressTimer();
    notifyListeners();
  }

  // Get step display information
  Map<String, dynamic> getStepInfo(ProcessingStep step) {
    switch (step) {
      case ProcessingStep.analyzingRecording:
        return {
          'title': 'Analyzing your recording',
          'isCompleted':
              _currentStep.index > ProcessingStep.analyzingRecording.index,
          'isActive': _currentStep == ProcessingStep.analyzingRecording,
        };
      case ProcessingStep.creatingStory:
        return {
          'title': 'Creating magical story',
          'isCompleted':
              _currentStep.index > ProcessingStep.creatingStory.index,
          'isActive': _currentStep == ProcessingStep.creatingStory,
        };
      case ProcessingStep.addingIllustrations:
        return {
          'title': 'Adding illustrations',
          'isCompleted':
              _currentStep.index > ProcessingStep.addingIllustrations.index,
          'isActive': _currentStep == ProcessingStep.addingIllustrations,
        };
      default:
        return {'title': '', 'isCompleted': false, 'isActive': false};
    }
  }

  @override
  void dispose() {
    _stopProgressTimer();
    super.dispose();
  }
}
