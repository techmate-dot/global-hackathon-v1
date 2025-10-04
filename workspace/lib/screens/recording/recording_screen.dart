import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/design_tokens.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _micBounceController;
  Duration _recordingDuration = Duration.zero;
  List<double> _waveformData = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat();

    _micBounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _generateWaveformData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _micBounceController.dispose();
    super.dispose();
  }

  void _generateWaveformData() {
    _waveformData = List.generate(40, (index) => Random().nextDouble());
  }

  void _toggleRecording() async {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() async {
    await _micBounceController.forward();
    await _micBounceController.reverse();

    setState(() {
      _isRecording = true;
    });

    _pulseController.repeat();
    _simulateRecording();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });

    _pulseController.stop();

    // Navigate to processing screen after brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      const memoryId = 'temp_memory_id';
      context.goToProcessing(memoryId);
    });
  }

  void _simulateRecording() {
    Future.doWhile(() async {
      if (!_isRecording) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
          _generateWaveformData(); // Update waveform
        });
      }
      return _isRecording;
    });
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
      backgroundColor: EchoesColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),

                    // Prompt Card
                    _buildPromptCard(),

                    const Spacer(flex: 2),

                    // Recording Interface
                    _buildRecordingInterface(),

                    const SizedBox(height: 32),

                    // Duration and Status
                    _buildStatusInfo(),

                    const Spacer(),

                    // Waveform Visualization
                    if (_isRecording) _buildWaveform(),

                    const Spacer(),

                    // Control Buttons
                    _buildControlButtons(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.onBack(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: EchoesColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: EchoesColors.textTertiary.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.close,
                color: EchoesColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Record Memory',
            style: EchoesTypography.headlineSmall.copyWith(
              color: EchoesColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoesColors.storyBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EchoesColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EchoesColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: EchoesColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Today\'s Prompt',
            style: EchoesTypography.bodyLarge.copyWith(
              color: EchoesColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell me about your favorite childhood hideout. What made it so special?',
            textAlign: TextAlign.center,
            style: EchoesTypography.bodyLarge.copyWith(
              color: EchoesColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse rings
            if (_isRecording) ...[
              for (int i = 0; i < 3; i++)
                Container(
                  width: 200 + (i * 30) + (_pulseController.value * 60),
                  height: 200 + (i * 30) + (_pulseController.value * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: EchoesColors.recordingActive.withOpacity(
                        0.3 - (i * 0.1) - (_pulseController.value * 0.2),
                      ),
                      width: 2,
                    ),
                  ),
                ),
            ],

            // Main microphone button
            AnimatedBuilder(
              animation: _micBounceController,
              builder: (context, child) {
                final scale = 1.0 + (_micBounceController.value * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [
                                  EchoesColors.recordingActive,
                                  EchoesColors.recordingActive.withOpacity(0.8),
                                ]
                              : [
                                  EchoesColors.primary,
                                  EchoesColors.primary.withOpacity(0.8),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isRecording
                                        ? EchoesColors.recordingActive
                                        : EchoesColors.primary)
                                    .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      children: [
        Text(
          _formatDuration(_recordingDuration),
          style: EchoesTypography.headlineLarge.copyWith(
            color: _isRecording
                ? EchoesColors.recordingActive
                : EchoesColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: EchoesColors.recordingActive,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _isRecording
                  ? 'Recording... Tap to stop'
                  : 'Tap the microphone to start recording',
              style: EchoesTypography.bodyMedium.copyWith(
                color: EchoesColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_waveformData.length, (index) {
              final baseHeight = 8.0;
              final maxHeight = 60.0;
              final animatedMultiplier = 0.3 + (_waveformData[index] * 0.7);
              final height =
                  baseHeight + (maxHeight - baseHeight) * animatedMultiplier;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: EchoesColors.waveformActive,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    if (!_isRecording) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pause button (future feature)
        IconButton(
          onPressed: null, // Disabled for now
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EchoesColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: EchoesColors.textTertiary,
            ),
          ),
        ),

        // Stop and save button
        ElevatedButton.icon(
          onPressed: _stopRecording,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Save & Continue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EchoesColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        // Delete button
        IconButton(
          onPressed: () {
            setState(() {
              _isRecording = false;
              _recordingDuration = Duration.zero;
            });
            _pulseController.stop();
          },
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EchoesColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: EchoesColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
