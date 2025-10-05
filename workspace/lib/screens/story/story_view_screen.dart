import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:go_router/go_router.dart';
import '../../models/story.dart';
import '../../services/backend_api_service.dart';

// Figma-derived design constants for story view
class _StoryViewConstants {
  // Colors
  static const Color backgroundGradientStart = Color(0xFFEFF6FF);
  static const Color backgroundGradientEnd = Color(0xFFF0FDF4);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0x1A000000);
  static const Color textPrimary = Color(0xFF1E2939);
  static const Color textSecondary = Color(0xFF4A5565);
  static const Color buttonBackground = Color(0x66FFFFFF);
  static const Color progressActive = Color(0xFFAD46FF);
  static const Color progressInactive = Color(0xFFD1D5DC);
  static const Color readAloudGradientStart = Color(0xFFAD46FF);
  static const Color readAloudGradientEnd = Color(0xFFF6339A);

  // Typography
  static const TextStyle titleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3125,
    height: 24 / 16,
  );
  static const TextStyle subtitleText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.1504,
    height: 20 / 14,
  );
  static const TextStyle storyText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: -0.4395,
    height: 29.25 / 18,
  );
  static const TextStyle pageText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.1504,
    height: 20 / 14,
  );
  // Read aloud button text styles
  static const TextStyle readAloudTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: -0.1504,
    height: 20 / 14,
  );
  static const TextStyle readAloudSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: -0.1504,
    height: 20 / 14,
  );
}

class StoryViewScreen extends StatefulWidget {
  final Story story;

  const StoryViewScreen({super.key, required this.story});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late Story _currentStory;
  PageController _pageController = PageController();
  List<String> _storyPages = [];
  int _currentPage = 0;

  FlutterSoundPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  final BackendApiService _apiService = BackendApiService();

  @override
  void initState() {
    super.initState();
    _currentStory = widget.story;
    _pageController = PageController();
    _splitStoryIntoPages();
    _initializeAudioPlayer();
  }

  /// Split the story text into pages like a children's book
  void _splitStoryIntoPages() {
    const int wordsPerPage = 25; // Adjust this to control page length

    // Clean and validate story text
    String storyText = _currentStory.text.trim();
    if (storyText.isEmpty) {
      storyText =
          'Once upon a time, there was a beautiful memory waiting to be told...';
    }

    final words = storyText.split(RegExp(r'\s+'));
    words.removeWhere((word) => word.isEmpty);

    _storyPages.clear();

    for (int i = 0; i < words.length; i += wordsPerPage) {
      final endIndex = (i + wordsPerPage < words.length)
          ? i + wordsPerPage
          : words.length;

      final pageText = words.sublist(i, endIndex).join(' ');
      if (pageText.isNotEmpty) {
        _storyPages.add(pageText);
      }
    }

    // Ensure at least one page
    if (_storyPages.isEmpty) {
      _storyPages.add(storyText);
    }
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();

    _audioPlayer!.setSubscriptionDuration(const Duration(milliseconds: 100));

    // Set up completion handler
    _audioPlayer!.onProgress!.listen((event) {
      if (event.position >= event.duration) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  Future<void> _toggleReadAloud() async {
    if (_isPlaying) {
      if (_isPaused) {
        // Resume playback
        await _audioPlayer!.resumePlayer();
        setState(() {
          _isPaused = false;
        });
      } else {
        // Pause playback
        await _audioPlayer!.pausePlayer();
        setState(() {
          _isPaused = true;
        });
      }
    } else {
      // Start playback
      await _startAudioPlayback();
    }
  }

  Future<void> _startAudioPlayback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if we have a local audio file first
      String? audioPath;

      // Check for page-specific audio URL
      if (_currentStory.audioUrls.isNotEmpty &&
          _currentStory.currentPage <= _currentStory.audioUrls.length) {
        final audioUrl = _currentStory.audioUrls[_currentStory.currentPage - 1];
        if (audioUrl.isNotEmpty) {
          // For remote URLs, you might want to download and cache first
          audioPath = audioUrl;
        }
      }

      // Fallback: Generate audio from backend if no pre-generated audio exists
      if (audioPath == null || audioPath.isEmpty) {
        final currentPageText =
            _storyPages.isNotEmpty && _currentPage < _storyPages.length
            ? _storyPages[_currentPage]
            : _currentStory.text;

        audioPath = await _apiService.getStoryAudio(
          storyId: _currentStory.id,
          text: currentPageText,
        );
      }

      // Play the audio
      if (audioPath.isNotEmpty) {
        await _audioPlayer!.startPlayer(
          fromURI: audioPath,
          codec: audioPath.startsWith('http') ? Codec.mp3 : Codec.aacADTS,
        );

        setState(() {
          _isPlaying = true;
          _isPaused = false;
          _isLoading = false;
        });
      } else {
        throw Exception('No audio available for this story page');
      }
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _isPaused = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.2, -1.0),
            end: Alignment(0.2, 1.0),
            colors: [
              _StoryViewConstants.backgroundGradientStart,
              _StoryViewConstants.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Story content
              Expanded(child: _buildStoryContent()),

              // Page controls (navigation arrows)
              _buildPageControls(),

              // Page indicator dots
              _buildPageIndicator(),

              // Read aloud button
              _buildReadAloudButton(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              // Use go_router navigation to go back to home
              context.go('/home');
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _StoryViewConstants.buttonBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 14,
                color: _StoryViewConstants.textPrimary,
              ),
            ),
          ),

          // Title section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStory.title,
                    style: _StoryViewConstants.titleText.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentStory.subtitle,
                    style: _StoryViewConstants.subtitleText.copyWith(
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Share button
              GestureDetector(
                onTap: () {
                  // TODO: Implement share functionality
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _StoryViewConstants.buttonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    size: 14,
                    color: _StoryViewConstants.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // More options button
              GestureDetector(
                onTap: () {
                  // TODO: Implement more options
                },
                child: Container(
                  width: 39.997,
                  height: 39.997,
                  decoration: BoxDecoration(
                    color: _StoryViewConstants.buttonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    size: 14,
                    color: _StoryViewConstants.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _StoryViewConstants.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _StoryViewConstants.cardBorder, width: 0.629),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _storyPages.length,
          itemBuilder: (context, index) {
            return _buildStoryPage(index);
          },
        ),
      ),
    );
  }

  Widget _buildStoryPage(int pageIndex) {
    return Column(
      children: [
        // Story image (same for all pages)
        _buildStoryImage(),

        // Page-specific text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: Text(
                _storyPages[pageIndex],
                style: _StoryViewConstants.storyText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _currentPage > 0
                  ? _StoryViewConstants.buttonBackground
                  : _StoryViewConstants.buttonBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: _currentPage > 0
                    ? _StoryViewConstants.textPrimary
                    : _StoryViewConstants.textSecondary,
              ),
            ),
          ),

          // Page info
          Text(
            'Page ${_currentPage + 1} of ${_storyPages.length}',
            style: _StoryViewConstants.pageText,
          ),

          // Next button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _currentPage < _storyPages.length - 1
                  ? _StoryViewConstants.buttonBackground
                  : _StoryViewConstants.buttonBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _currentPage < _storyPages.length - 1
                  ? _nextPage
                  : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _currentPage < _storyPages.length - 1
                    ? _StoryViewConstants.textPrimary
                    : _StoryViewConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadAloudButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _StoryViewConstants.readAloudGradientStart,
            _StoryViewConstants.readAloudGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _toggleReadAloud,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying
                      ? (_isPaused ? Icons.play_arrow : Icons.pause)
                      : Icons.volume_up,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLoading
                      ? 'Loading...'
                      : _isPlaying
                      ? (_isPaused ? 'Resume' : 'Pause')
                      : 'Read Aloud',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _storyPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStoryImage() {
    return Container(
      height: 255.991,
      margin: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _currentStory.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: _currentStory.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[100]!, Colors.purple[100]!],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Text(
      'Page ${_currentPage + 1} of ${_storyPages.length}',
      style: _StoryViewConstants.pageText,
      textAlign: TextAlign.center,
    );
  }
}
