import 'package:json_annotation/json_annotation.dart';

part 'memory.g.dart';

// Memory State Enum
enum MemoryState {
  draft,
  uploaded,
  transcribing,
  transcribed,
  polishing,
  polished,
  published,
  failed,
}

@JsonSerializable()
class Memory {
  final String id;
  final String familyId;
  final String authorId;
  final String title;
  final String? rawAudioUrl;
  final String? transcript;
  final String? polishedText;
  final String? bedtimeStoryText;
  final List<String> illustrationUrls;
  final String? ttsAudioUrl;
  final List<String> tags;
  final bool isChildFriendly;
  final String privacy; // private, family, public
  final MemoryState state;
  final DateTime createdAt;
  final DateTime? processedAt;

  const Memory({
    required this.id,
    required this.familyId,
    required this.authorId,
    required this.title,
    this.rawAudioUrl,
    this.transcript,
    this.polishedText,
    this.bedtimeStoryText,
    this.illustrationUrls = const [],
    this.ttsAudioUrl,
    this.tags = const [],
    this.isChildFriendly = false,
    this.privacy = 'family',
    this.state = MemoryState.draft,
    required this.createdAt,
    this.processedAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) => _$MemoryFromJson(json);
  Map<String, dynamic> toJson() => _$MemoryToJson(this);

  Memory copyWith({
    String? id,
    String? familyId,
    String? authorId,
    String? title,
    String? rawAudioUrl,
    String? transcript,
    String? polishedText,
    String? bedtimeStoryText,
    List<String>? illustrationUrls,
    String? ttsAudioUrl,
    List<String>? tags,
    bool? isChildFriendly,
    String? privacy,
    MemoryState? state,
    DateTime? createdAt,
    DateTime? processedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      rawAudioUrl: rawAudioUrl ?? this.rawAudioUrl,
      transcript: transcript ?? this.transcript,
      polishedText: polishedText ?? this.polishedText,
      bedtimeStoryText: bedtimeStoryText ?? this.bedtimeStoryText,
      illustrationUrls: illustrationUrls ?? this.illustrationUrls,
      ttsAudioUrl: ttsAudioUrl ?? this.ttsAudioUrl,
      tags: tags ?? this.tags,
      isChildFriendly: isChildFriendly ?? this.isChildFriendly,
      privacy: privacy ?? this.privacy,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  // Helper methods for state management
  bool get isDraft => state == MemoryState.draft;
  bool get isUploaded => state == MemoryState.uploaded;
  bool get isProcessing =>
      [MemoryState.transcribing, MemoryState.polishing].contains(state);
  bool get isComplete => state == MemoryState.published;
  bool get hasFailed => state == MemoryState.failed;

  double get progressPercentage {
    switch (state) {
      case MemoryState.draft:
        return 0.0;
      case MemoryState.uploaded:
        return 0.2;
      case MemoryState.transcribing:
        return 0.4;
      case MemoryState.transcribed:
        return 0.6;
      case MemoryState.polishing:
        return 0.8;
      case MemoryState.polished:
        return 0.9;
      case MemoryState.published:
        return 1.0;
      case MemoryState.failed:
        return 0.0;
    }
  }

  @override
  String toString() {
    return 'Memory(id: $id, title: $title, state: $state, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Memory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
