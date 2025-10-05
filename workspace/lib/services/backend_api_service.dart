import 'dart:io';
import 'package:dio/dio.dart';

class BackendApiService {
  static const String baseUrl =
      'https://your-backend-api.com/api'; // Replace with actual endpoint

  final Dio _dio = Dio();

  BackendApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Upload audio file and get generated story
  Future<StoryResponse> uploadAudioAndGenerateStory({
    required String audioFilePath,
    String? title,
    Function(double)? onUploadProgress,
  }) async {
    try {
      // Create form data for file upload
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'recording.aac',
        ),
        if (title != null) 'title': title,
        'format': 'aac',
        'language': 'en', // Can be made configurable
      });

      // Upload with progress tracking
      final response = await _dio.post(
        '/upload-audio-generate-story',
        data: formData,
        onSendProgress: (sent, total) {
          if (onUploadProgress != null && total > 0) {
            onUploadProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        return StoryResponse.fromJson(response.data);
      } else {
        throw ApiException('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Get story audio (text-to-speech)
  Future<String> getStoryAudio({
    required String storyId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/generate-audio',
        data: {
          'story_id': storyId,
          'text': text,
          'voice': 'narrator', // Can be made configurable
          'speed': 1.0,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Save audio to temporary file
        final tempDir = Directory.systemTemp;
        final audioFile = File('${tempDir.path}/story_audio_$storyId.mp3');
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
