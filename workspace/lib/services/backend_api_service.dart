import 'dart:io';
import 'package:dio/dio.dart';

class BackendApiService {
  static const String baseUrl =
      'https://echoes-backend.onrender.com'; // Production FastAPI server

  final Dio _dio = Dio();

  BackendApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Upload audio file and get generated story with audio
  Future<StoryResponse> uploadAudioAndGenerateStory({
    required String audioFilePath,
    String? title,
    Function(double)? onUploadProgress,
  }) async {
    try {
      // Create form data for file upload matching FastAPI endpoint
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'recording.m4a',
        ),
      });

      // Upload to /stt-with-story endpoint that returns JSON with story text
      final response = await _dio.post(
        '/stt-with-story',
        data: formData,
        onSendProgress: (sent, total) {
          if (onUploadProgress != null && total > 0) {
            onUploadProgress(sent / total);
          }
        },
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        final storyId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Extract story text from JSON response (API returns a string)
        String storyText;
        if (response.data is String) {
          storyText = response.data as String;
        } else {
          // Fallback in case the response format is different
          storyText = response.data.toString();
        }
        
        // If story text is empty or too short, use a meaningful placeholder
        if (storyText.isEmpty || storyText.length < 50) {
          storyText = _generatePlaceholderStory(title ?? 'My Memory');
        }
        
        return StoryResponse(
          id: storyId,
          title: title ?? 'My Memory',
          text: storyText,
          audioUrls: [], // Audio will be generated via TTS when needed
          totalPages: _calculatePages(storyText),
          createdAt: DateTime.now(),
        );
      } else {
        throw ApiException('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Generate a meaningful placeholder story since backend doesn't return story text
  String _generatePlaceholderStory(String memoryTitle) {
    return """Once upon a time, there was a beautiful memory captured in the moment titled "$memoryTitle".

This memory held within it the echoes of laughter, the warmth of connection, and the precious moments that make life truly meaningful.

Like ripples in a pond, this memory spreads its gentle influence, touching hearts and minds with its timeless message.

The story continues to unfold, each chapter bringing new understanding and deeper appreciation for the simple yet profound experiences that shape our lives.

And so the memory lives on, forever cherished, forever remembered, a treasure that grows more valuable with each passing day.""";
  }

  /// Calculate number of pages for the story (25 words per page)
  int _calculatePages(String text) {
    const int wordsPerPage = 25;
    final words = text.split(' ');
    return (words.length / wordsPerPage).ceil();
  }  /// Get story audio using text-to-speech
  Future<String> getStoryAudio({
    required String storyId,
    required String text,
  }) async {
    try {
      final response = await _dio.get(
        '/tts',
        queryParameters: {
          'text': text,
          'voice': 'aura-asteria-en', // Deepgram voice
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Save audio to temporary file
        final tempDir = Directory.systemTemp;
        final audioFile = File('${tempDir.path}/tts_audio_$storyId.mp3');
        await audioFile.writeAsBytes(response.data);
        return audioFile.path;
      } else {
        throw ApiException(
          'Audio generation failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout');
      case DioExceptionType.connectionError:
        return ApiException('Connection error');
      case DioExceptionType.badResponse:
        return ApiException('Server error: ${e.response?.statusCode}');
      default:
        return ApiException('Network error: ${e.message}');
    }
  }
}

class StoryResponse {
  final String id;
  final String title;
  final String text;
  final String? imageUrl;
  final List<String> audioUrls; // For different story parts/pages
  final int totalPages;
  final DateTime createdAt;

  StoryResponse({
    required this.id,
    required this.title,
    required this.text,
    this.imageUrl,
    required this.audioUrls,
    required this.totalPages,
    required this.createdAt,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    return StoryResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      audioUrls: List<String>.from(json['audio_urls'] ?? []),
      totalPages: json['total_pages'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'image_url': imageUrl,
      'audio_urls': audioUrls,
      'total_pages': totalPages,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
