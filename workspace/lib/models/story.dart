class Story {
  final String id;
  final String title;
  final String subtitle;
  final String text;
  final String? imageUrl;
  final String? audioPath; // Local audio file path
  final List<String> audioUrls; // Remote audio URLs for each page
  final int totalPages;
  final int currentPage;
  final DateTime createdAt;
  final String originalAudioPath; // Path to original recording

  Story({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.text,
    this.imageUrl,
    this.audioPath,
    this.audioUrls = const [],
    this.totalPages = 1,
    this.currentPage = 1,
    required this.createdAt,
    required this.originalAudioPath,
  });

  Story copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? text,
    String? imageUrl,
    String? audioPath,
    List<String>? audioUrls,
    int? totalPages,
    int? currentPage,
    DateTime? createdAt,
    String? originalAudioPath,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      audioPath: audioPath ?? this.audioPath,
      audioUrls: audioUrls ?? this.audioUrls,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      createdAt: createdAt ?? this.createdAt,
      originalAudioPath: originalAudioPath ?? this.originalAudioPath,
    );
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      text: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      audioPath: json['audio_path'] as String?,
      audioUrls: List<String>.from(json['audio_urls'] ?? []),
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      originalAudioPath: json['original_audio_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'text': text,
      'image_url': imageUrl,
      'audio_path': audioPath,
      'audio_urls': audioUrls,
      'total_pages': totalPages,
      'current_page': currentPage,
      'created_at': createdAt.toIso8601String(),
      'original_audio_path': originalAudioPath,
    };
  }

  // Split story text into pages (for pagination)
  List<String> get pages {
    // Simple implementation - can be enhanced based on content
    const wordsPerPage = 50;
    final words = text.split(' ');
    
    if (words.length <= wordsPerPage) {
      return [text];
    }

    final pages = <String>[];
    for (int i = 0; i < words.length; i += wordsPerPage) {
      final endIndex = (i + wordsPerPage < words.length) 
          ? i + wordsPerPage 
          : words.length;
      pages.add(words.sublist(i, endIndex).join(' '));
    }
    
    return pages;
  }

  // Get current page text
  String get currentPageText {
    final storyPages = pages;
    if (currentPage <= storyPages.length) {
      return storyPages[currentPage - 1];
    }
    return text;
  }
}