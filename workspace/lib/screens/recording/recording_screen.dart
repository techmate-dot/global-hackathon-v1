import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../providers/story_processing_provider.dart';

// Figma-derived design constants for recording screen
class _RecordingConstants {
  // Colors
  static const Color backgroundGradientStart = Color(0xFFEFF6FF);
  static const Color backgroundGradientEnd = Color(0xFFF0FDF4);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color recordingRed = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFF1E2939);
  static const Color textSecondary = Color(0xFF4A5565);
  static const Color textTertiary = Color(0xFF364153);
  static const Color cardBackground = Color(0xFFFEFCE8);
  static const Color cardBorder = Color(0xFFFFF085);
  static const Color tipIconBackground = Color(0xFFFDC700);

  // Sizes
  static const double headerHeight = 79.994;
  static const double smallButtonSize = 79.994;
  static const double pauseStopButtonSize = 63.995;
  static const double cardRadius = 14.0;
  static const double waveformBarWidth = 2.997;
  static const double waveformMaxHeight = 63.995;

  // Typography
  static const TextStyle headerTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.44,
    height: 28 / 18,
  );
  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle timerText = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 40 / 36,
  );
  static const TextStyle statusText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: -0.44,
    height: 28 / 18,
  );
  static const TextStyle descriptionText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle tipTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: -0.31,
    height: 24 / 16,
  );
  static const TextStyle tipContent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.15,
    height: 20 / 14,
  );
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPaused = false;
  late AnimationController _waveformController;
  late Timer _timer;
  Duration _recordingDuration = Duration.zero;
  List<double> _waveformHeights = [];
  final TextEditingController _titleController = TextEditingController();
  
  // Audio recording
  FlutterSoundRecorder? _recorder;
  String? _recordingPath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _generateWaveformData();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required for recording')),
          );
        }
        return;
      }

      // Initialize recorder
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing recorder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize recorder: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _titleController.dispose();
    if (_isRecording) {
      _timer.cancel();
    }
    _recorder?.closeRecorder();
    super.dispose();
  }

  void _generateWaveformData() {
    _waveformHeights = List.generate(
      20,
      (index) => Random().nextDouble() * _RecordingConstants.waveformMaxHeight,
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_isInitialized || _recorder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recorder not initialized')),
      );
      return;
    }

    try {
      // Create unique recording file path
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${recordingsDir.path}/recording_$timestamp.aac';

      // Start recording
      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordingDuration = Duration.zero;
      });

      _waveformController.repeat();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          setState(() {
            _recordingDuration = Duration(
              seconds: _recordingDuration.inSeconds + 1,
            );
            _generateWaveformData(); // Update waveform animation
          });
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recorder == null) return;

    try {
      // Stop the actual recording
      await _recorder!.stopRecorder();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      _waveformController.stop();
      _timer.cancel();

      // Show save dialog
      _showSaveDialog();
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSaveDialog(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.35, -1.0),
            end: Alignment(0.35, 1.0),
            colors: [
              _RecordingConstants.backgroundGradientStart,
              _RecordingConstants.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Timer
                      _buildTimer(),

                      const SizedBox(height: 24),

                      // Status text
                      _buildStatusText(),

                      const SizedBox(height: 32),

                      // Waveform or recording controls
                      if (_isRecording) ...[
                        _buildWaveform(),
                        const SizedBox(height: 32),
                        _buildRecordingControls(),
                      ] else ...[
                        const SizedBox(height: 40),
                        _buildRecordButton(),
                      ],

                      const Spacer(),

                      // Recording tips card (only show when not recording)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: !_isRecording ? _buildRecordingTipsCard() : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: _RecordingConstants.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            width: 47.997,
            height: 47.997,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => context.goToHome(),
              icon: const Icon(
                Icons.arrow_back,
                size: 16,
                color: _RecordingConstants.textTertiary,
              ),
            ),
          ),

          // Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Record Memory',
                style: _RecordingConstants.headerTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2),
              Text(
                'Share your family story',
                style: _RecordingConstants.headerSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),

          // Spacer to balance layout
          const SizedBox(width: 47.997),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Text(
      _formatDuration(_recordingDuration),
      style: _RecordingConstants.timerText,
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          _isRecording ? 'Recording...' : 'Ready to record',
          style: _RecordingConstants.statusText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _isRecording
              ? 'Share your memories and stories for the\nnext generation'
              : 'Tap the microphone to start recording your family story',
          style: _RecordingConstants.descriptionText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Container(
        width: _RecordingConstants.smallButtonSize,
        height: _RecordingConstants.smallButtonSize,
        decoration: BoxDecoration(
          color: _RecordingConstants.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.mic, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveformController,
      builder: (context, child) {
        return Container(
          height: _RecordingConstants.waveformMaxHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_waveformHeights.length, (index) {
              return Container(
                width: _RecordingConstants.waveformBarWidth,
                height: _waveformHeights[index],
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _RecordingConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRecordingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause button
        Container(
          width: _RecordingConstants.pauseStopButtonSize,
          height: _RecordingConstants.pauseStopButtonSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1.887,
            ),
          ),
          child: IconButton(
            onPressed: _pauseRecording,
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              size: 16,
              color: _RecordingConstants.textTertiary,
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Stop button
        Container(
          width: _RecordingConstants.pauseStopButtonSize,
          height: _RecordingConstants.pauseStopButtonSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFA2A2), width: 1.887),
          ),
          child: IconButton(
            onPressed: _stopRecording,
            icon: const Icon(
              Icons.stop,
              size: 16,
              color: _RecordingConstants.recordingRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16.628),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_RecordingConstants.cardBackground, Color(0xFFFFFBEB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: _RecordingConstants.cardBorder, width: 0.629),
        borderRadius: BorderRadius.circular(_RecordingConstants.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _RecordingConstants.tipIconBackground,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 14)),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Recording Tips', style: _RecordingConstants.tipTitle),
                SizedBox(height: 4),
                Text(
                  'Find a quiet space and speak clearly. Share specific details, names, and emotions to make the story more engaging for kids.',
                  style: _RecordingConstants.tipContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 0.629,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and header
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.save_outlined,
                size: 32,
                color: _RecordingConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Save Your Memory',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _RecordingConstants.textPrimary,
                letterSpacing: -0.45,
                height: 28 / 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Give your recording a meaningful title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: _RecordingConstants.textSecondary,
                letterSpacing: -0.31,
                height: 24 / 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Form
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Memory Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: -0.15,
                    height: 14 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent, width: 0.629),
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: -0.31,
                    ),
                    decoration: const InputDecoration(
                      hintText: "e.g., Grandpa's War Stories",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF717182),
                        letterSpacing: -0.31,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Duration: ${_formatDuration(_recordingDuration)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _RecordingConstants.textSecondary,
                      letterSpacing: -0.15,
                      height: 20 / 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.1),
                            width: 0.629,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Reset recording state
                            setState(() {
                              _recordingDuration = Duration.zero;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: _RecordingConstants.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();

                            // Get the story processing provider
                            final storyProvider = context
                                .read<StoryProcessingProvider>();

                            // Start processing with the recording data
                            final title = _titleController.text.trim().isEmpty
                                ? "My Memory"
                                : _titleController.text.trim();

                            // Navigate to processing screen
                            context.goToProcessing('temp_memory_id');

                            // Start processing in background with actual recording path
                            await storyProvider.processRecording(
                              audioFilePath: _recordingPath ?? '',
                              memoryTitle: title,
                              recordingDuration: _recordingDuration,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save & Process',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
