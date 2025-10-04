// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Memory _$MemoryFromJson(Map<String, dynamic> json) => Memory(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      rawAudioUrl: json['rawAudioUrl'] as String?,
      transcript: json['transcript'] as String?,
      polishedText: json['polishedText'] as String?,
      bedtimeStoryText: json['bedtimeStoryText'] as String?,
      illustrationUrls: (json['illustrationUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ttsAudioUrl: json['ttsAudioUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isChildFriendly: json['isChildFriendly'] as bool? ?? false,
      privacy: json['privacy'] as String? ?? 'family',
      state: $enumDecodeNullable(_$MemoryStateEnumMap, json['state']) ??
          MemoryState.draft,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
    );

Map<String, dynamic> _$MemoryToJson(Memory instance) => <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'authorId': instance.authorId,
      'title': instance.title,
      'rawAudioUrl': instance.rawAudioUrl,
      'transcript': instance.transcript,
      'polishedText': instance.polishedText,
      'bedtimeStoryText': instance.bedtimeStoryText,
      'illustrationUrls': instance.illustrationUrls,
      'ttsAudioUrl': instance.ttsAudioUrl,
      'tags': instance.tags,
      'isChildFriendly': instance.isChildFriendly,
      'privacy': instance.privacy,
      'state': _$MemoryStateEnumMap[instance.state]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
    };

const _$MemoryStateEnumMap = {
  MemoryState.draft: 'draft',
  MemoryState.uploaded: 'uploaded',
  MemoryState.transcribing: 'transcribing',
  MemoryState.transcribed: 'transcribed',
  MemoryState.polishing: 'polishing',
  MemoryState.polished: 'polished',
  MemoryState.published: 'published',
  MemoryState.failed: 'failed',
};
