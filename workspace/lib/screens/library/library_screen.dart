import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date';
  bool _isGridView = true;

  // Mock data
  final List<Map<String, dynamic>> _memories = List.generate(
    12,
    (index) => {
      'id': 'memory_$index',
      'title': 'Childhood Memory ${index + 1}',
      'subtitle': 'A wonderful story from the past',
      'date': DateTime.now().subtract(Duration(days: index * 2)),
      'tags': ['childhood', 'family', 'adventure'][index % 3],
      'isStory': index % 2 == 0,
    },
  );

  List<Map<String, dynamic>> get _filteredMemories {
    var filtered = _memories.toList();

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((memory) {
        return memory['title'].toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b['date'].compareTo(a['date']));
        break;
      case 'title':
        filtered.sort((a, b) => a['title'].compareTo(b['title']));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.onBack(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search memories...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                  ],
                ),
              ],
            ),
          ),

          // Memory Grid/List
          Expanded(child: _isGridView ? _buildGridView() : _buildListView()),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = _filteredMemories[index];
        return _buildMemoryCard(memory);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMemories.length,
      itemBuilder: (context, index) {
        final memory = _filteredMemories[index];
        return _buildMemoryListTile(memory);
      },
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> memory) {
    return Card(
      child: InkWell(
        onTap: () => context.onSelectMemory(memory['id']),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: memory['isStory']
                      ? Colors.orange[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    memory['isStory'] ? Icons.auto_stories : Icons.mic,
                    size: 32,
                    color: memory['isStory'] ? Colors.orange : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                memory['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                _formatDate(memory['date']),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),

              // Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  memory['tags'],
                  style: TextStyle(color: Colors.green[700], fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryListTile(Map<String, dynamic> memory) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: memory['isStory']
              ? Colors.orange[100]
              : Colors.blue[100],
          child: Icon(
            memory['isStory'] ? Icons.auto_stories : Icons.mic,
            color: memory['isStory'] ? Colors.orange : Colors.blue,
          ),
        ),
        title: Text(memory['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memory['subtitle']),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    memory['tags'],
                    style: TextStyle(color: Colors.green[700], fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(memory['date']),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        onTap: () => context.onSelectMemory(memory['id']),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
