import 'package:flutter/foundation.dart';
import '../models/memory.dart';

class MemoryProvider extends ChangeNotifier {
  final List<Memory> _memories = [];
  Memory? _selectedMemory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Memory> get memories => List.unmodifiable(_memories);
  Memory? get selectedMemory => _selectedMemory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter memories by state
  List<Memory> get draftMemories => _memories.where((m) => m.isDraft).toList();
  List<Memory> get processingMemories =>
      _memories.where((m) => m.isProcessing).toList();
  List<Memory> get completedMemories =>
      _memories.where((m) => m.isComplete).toList();
  List<Memory> get recentMemories {
    final sorted = List<Memory>.from(_memories);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(6).toList();
  }

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

  // Load memories
  Future<void> loadMemories() async {
    try {
      _setLoading(true);
      clearError();

      // TODO: Load from Supabase
      // For now, add some mock data
      await Future.delayed(const Duration(seconds: 1));

      _memories.clear();
      _addMockMemories();

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Add mock memories for demo
  void _addMockMemories() {
    final now = DateTime.now();

    _memories.addAll([
      Memory(
        id: 'memory_1',
        familyId: 'family_123',
        authorId: 'user_123',
        title: 'My Childhood Hideout',
        transcript: 'I remember this special place behind the old oak tree...',
        polishedText:
            'In the gentle shade of the ancient oak tree that stood behind our family home, there existed a magical world that only I knew about...',
        bedtimeStoryText:
            'Once upon a time, there was a little girl who discovered the most wonderful secret place behind a big, friendly oak tree...',
        tags: ['childhood', 'adventure', 'nature'],
        isChildFriendly: true,
        state: MemoryState.published,
        createdAt: now.subtract(const Duration(days: 2)),
        processedAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      Memory(
        id: 'memory_2',
        familyId: 'family_123',
        authorId: 'user_123',
        title: 'First Day of School',
        transcript: 'I was so nervous walking to school with my mother...',
        polishedText:
            'The morning sun cast long shadows across the sidewalk as I took those first tentative steps toward my new adventure...',
        bedtimeStoryText:
            'There once was a brave little person who was about to start a grand new adventure called school...',
        tags: ['school', 'childhood', 'growth'],
        isChildFriendly: true,
        state: MemoryState.published,
        createdAt: now.subtract(const Duration(days: 7)),
        processedAt: now.subtract(const Duration(days: 7, hours: 2)),
      ),
      Memory(
        id: 'memory_3',
        familyId: 'family_123',
        authorId: 'user_123',
        title: 'Learning to Ride a Bike',
        transcript: 'My father held the back of my bike as I pedaled...',
        state: MemoryState.polishing,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Memory(
        id: 'memory_4',
        familyId: 'family_123',
        authorId: 'user_123',
        title: 'Summer at Grandma\'s',
        transcript: 'Those magical summers in the countryside...',
        polishedText:
            'The countryside summers at Grandma\'s house were filled with wonder and discovery...',
        state: MemoryState.transcribed,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ]);
  }

  // Create new memory
  Future<Memory> createMemory({
    required String title,
    required String familyId,
    required String authorId,
  }) async {
    try {
      clearError();

      final memory = Memory(
        id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
        familyId: familyId,
        authorId: authorId,
        title: title,
        state: MemoryState.draft,
        createdAt: DateTime.now(),
      );

      _memories.insert(0, memory);
      notifyListeners();

      return memory;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update memory
  void updateMemory(Memory updatedMemory) {
    final index = _memories.indexWhere((m) => m.id == updatedMemory.id);
    if (index != -1) {
      _memories[index] = updatedMemory;
      if (_selectedMemory?.id == updatedMemory.id) {
        _selectedMemory = updatedMemory;
      }
      notifyListeners();
    }
  }

  // Update memory state
  void updateMemoryState(String memoryId, MemoryState newState) {
    final memory = _memories.firstWhere((m) => m.id == memoryId);
    final updatedMemory = memory.copyWith(
      state: newState,
      processedAt: newState == MemoryState.published ? DateTime.now() : null,
    );
    updateMemory(updatedMemory);
  }

  // Simulate processing pipeline
  Future<void> processMemory(String memoryId) async {
    try {
      clearError();

      // Simulate state transitions
      updateMemoryState(memoryId, MemoryState.uploaded);
      await Future.delayed(const Duration(seconds: 1));

      updateMemoryState(memoryId, MemoryState.transcribing);
      await Future.delayed(const Duration(seconds: 1));

      updateMemoryState(memoryId, MemoryState.transcribed);
      await Future.delayed(const Duration(seconds: 1));

      updateMemoryState(memoryId, MemoryState.polishing);
      await Future.delayed(const Duration(seconds: 1));

      updateMemoryState(memoryId, MemoryState.polished);
      await Future.delayed(const Duration(milliseconds: 500));

      updateMemoryState(memoryId, MemoryState.published);
    } catch (e) {
      updateMemoryState(memoryId, MemoryState.failed);
      _error = e.toString();
      notifyListeners();
    }
  }

  // Select memory for viewing
  void selectMemory(String memoryId) {
    _selectedMemory = _memories.firstWhere((m) => m.id == memoryId);
    notifyListeners();
  }

  // Clear selected memory
  void clearSelectedMemory() {
    _selectedMemory = null;
    notifyListeners();
  }

  // Delete memory
  Future<void> deleteMemory(String memoryId) async {
    try {
      clearError();

      // TODO: Delete from Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      _memories.removeWhere((m) => m.id == memoryId);
      if (_selectedMemory?.id == memoryId) {
        _selectedMemory = null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Search memories
  List<Memory> searchMemories(String query) {
    if (query.isEmpty) return memories;

    final lowerQuery = query.toLowerCase();
    return _memories.where((memory) {
      return memory.title.toLowerCase().contains(lowerQuery) ||
          (memory.transcript?.toLowerCase().contains(lowerQuery) ?? false) ||
          (memory.polishedText?.toLowerCase().contains(lowerQuery) ?? false) ||
          memory.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get memories by tag
  List<Memory> getMemoriesByTag(String tag) {
    return _memories.where((memory) => memory.tags.contains(tag)).toList();
  }
}
