import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  FlutterSoundPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  final BackendApiService _apiService = BackendApiService();

  @override
  void initState() {
    super.initState();
    _currentStory = widget.story;
    _initializeAudioPlayer();
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
        audioPath = await _apiService.getStoryAudio(
          storyId: _currentStory.id,
          text: _currentStory.currentPageText,
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

  void _previousPage() {
    if (_currentStory.currentPage > 1) {
      setState(() {
        _currentStory = _currentStory.copyWith(
          currentPage: _currentStory.currentPage - 1,
        );
      });
      _stopAudio();
    }
  }

  void _nextPage() {
    if (_currentStory.currentPage < _currentStory.totalPages) {
      setState(() {
        _currentStory = _currentStory.copyWith(
          currentPage: _currentStory.currentPage + 1,
        );
      });
      _stopAudio();
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stopPlayer();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
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
              Expanded(
                child: _buildStoryContent(),
              ),
              
              // Page indicator
              _buildPageIndicator(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 95.993,
      padding: const EdgeInsets.symmetric(horizontal: 15.999),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 47.997,
              height: 47.997,
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
                size: 15.999,
                color: _StoryViewConstants.textPrimary,
              ),
            ),
          ),

          // Title section
          Expanded(
            child: Container(
              height: 43.997,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStory.title,
                    style: _StoryViewConstants.titleText,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentStory.subtitle,
                    style: _StoryViewConstants.subtitleText,
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
                  width: 39.997,
                  height: 39.997,
                  decoration: BoxDecoration(
                    color: _StoryViewConstants.buttonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    size: 15.999,
                    color: _StoryViewConstants.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 7.999),
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
                    size: 15.999,
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
        border: Border.all(
          color: _StoryViewConstants.cardBorder,
          width: 0.629,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Story image
            _buildStoryImage(),
            
            // Story text
            Expanded(
              child: _buildStoryText(),
            ),
            
            // Navigation and read aloud controls
            _buildControls(),
          ],
        ),
      ),
    );
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
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[100]!,
                      Colors.purple[100]!,
                    ],
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

  Widget _buildStoryText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        _currentStory.currentPageText,
        style: _StoryViewConstants.storyText,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              GestureDetector(
                onTap: _currentStory.currentPage > 1 ? _previousPage : null,
                child: Container(
                  width: 47.997,
                  height: 47.997,
                  decoration: BoxDecoration(
                    color: _currentStory.currentPage > 1 
                        ? Colors.grey[100] 
                        : Colors.grey[100]!.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 15.999,
                    color: _currentStory.currentPage > 1 
                        ? _StoryViewConstants.textPrimary 
                        : _StoryViewConstants.textSecondary,
                  ),
                ),
              ),

              // Page dots
              _buildPageDots(),

              // Next button
              GestureDetector(
                onTap: _currentStory.currentPage < _currentStory.totalPages ? _nextPage : null,
                child: Container(
                  width: 47.997,
                  height: 47.997,
                  decoration: BoxDecoration(
                    color: _currentStory.currentPage < _currentStory.totalPages 
                        ? Colors.grey[100] 
                        : Colors.grey[100]!.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 15.999,
                    color: _currentStory.currentPage < _currentStory.totalPages 
                        ? _StoryViewConstants.textPrimary 
                        : _StoryViewConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Read aloud button
          _buildReadAloudButton(),
        ],
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentStory.totalPages, (index) {
        final isActive = index + 1 == _currentStory.currentPage;
        return Container(
          width: isActive ? 23.998 : 7.999,
          height: 7.999,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive 
                ? _StoryViewConstants.progressActive 
                : _StoryViewConstants.progressInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildReadAloudButton() {
    return GestureDetector(
      onTap: _toggleReadAloud,
      child: Container(
        height: 55.996,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              _StoryViewConstants.readAloudGradientStart,
              _StoryViewConstants.readAloudGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Owl icon
            Container(
              width: 39.997,
              height: 39.997,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🦉',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            const SizedBox(width: 11.999),
            
            // Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoading 
                        ? 'Loading...' 
                        : _isPlaying && !_isPaused 
                            ? 'Playing...' 
                            : 'Read Aloud',
                    style: _StoryViewConstants.readAloudTitle,
                  ),
                  Text(
                    _isLoading
                        ? 'Preparing audio...'
                        : _isPlaying && _isPaused 
                            ? 'Tap to resume' 
                            : 'Let Echo tell the story',
                    style: _StoryViewConstants.readAloudSubtitle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 11.999),
            
            // Play/pause/loading icon
            _isLoading
                ? const SizedBox(
                    width: 15.999,
                    height: 15.999,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isPlaying && !_isPaused 
                        ? Icons.pause 
                        : Icons.play_arrow,
                    size: 15.999,
                    color: Colors.white,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Text(
      'Page ${_currentStory.currentPage} of ${_currentStory.totalPages}',
      style: _StoryViewConstants.pageText,
      textAlign: TextAlign.center,
    );
  }
}