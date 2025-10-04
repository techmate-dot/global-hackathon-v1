import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/navigation/app_router.dart';
import '../../core/theme/design_tokens.dart';

class ProcessingScreen extends StatefulWidget {
  final String? memoryId;

  const ProcessingScreen({super.key, this.memoryId});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  int _currentStep = 0;

  final List<ProcessingStep> _processingSteps = [
    ProcessingStep(
      title: 'Capturing Magic',
      subtitle: 'Saving your precious memory...',
      icon: Icons.mic_rounded,
      color: EchoesColors.primary,
    ),
    ProcessingStep(
      title: 'Understanding Context',
      subtitle: 'Listening to every detail...',
      icon: Icons.hearing_rounded,
      color: EchoesColors.accent,
    ),
    ProcessingStep(
      title: 'Weaving Story',
      subtitle: 'Crafting your magical tale...',
      icon: Icons.auto_stories_rounded,
      color: EchoesColors.secondary,
    ),
    ProcessingStep(
      title: 'Adding Sparkles',
      subtitle: 'Polishing the final touches...',
      icon: Icons.auto_awesome,
      color: EchoesColors.streakGold,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _startProcessing();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startProcessing() {
    _progressController.addListener(() {
      final progress = _progressController.value;
      final stepIndex = (progress * _processingSteps.length).floor();
      if (stepIndex != _currentStep && stepIndex < _processingSteps.length) {
        setState(() {
          _currentStep = stepIndex;
        });
      }
    });

    _progressController.forward().then((_) {
      // Brief celebration animation
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.goToStoryView(widget.memoryId ?? 'default_memory');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EchoesColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Main animation area
              _buildMainAnimation(),

              const SizedBox(height: 48),

              // Progress section
              _buildProgressSection(),

              const SizedBox(height: 32),

              // Current step info
              _buildCurrentStepInfo(),

              const Spacer(),

              // Encouraging message
              _buildEncouragingMessage(),

              const SizedBox(height: 32),

              // Cancel button
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _sparkleController,
        _bounceController,
        _rotationController,
      ]),
      builder: (context, child) {
        final currentStepData = _currentStep < _processingSteps.length
            ? _processingSteps[_currentStep]
            : _processingSteps.last;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer magical rings
            for (int i = 0; i < 3; i++)
              Transform.rotate(
                angle:
                    _rotationController.value *
                    2 *
                    math.pi *
                    (i % 2 == 0 ? 1 : -1),
                child: Container(
                  width: 200 + (i * 40),
                  height: 200 + (i * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentStepData.color.withOpacity(
                        0.2 - (i * 0.05),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),

            // Floating sparkles
            ...List.generate(8, (index) {
              final angle = (index * 45.0) + (_sparkleController.value * 360);
              final radian = angle * math.pi / 180;
              final radius =
                  120.0 +
                  (math.sin(_sparkleController.value * 2 * math.pi) * 20);
              final x = radius * math.cos(radian);
              final y = radius * math.sin(radian);

              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [
                      EchoesColors.streakGold,
                      EchoesColors.accent,
                      EchoesColors.primary,
                      EchoesColors.secondary,
                    ][index % 4].withOpacity(0.8),
                  ),
                ),
              );
            }),

            // Central mascot container
            Transform.scale(
              scale: 1.0 + (_bounceController.value * 0.1),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      currentStepData.color,
                      currentStepData.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentStepData.color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  currentStepData.icon,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_processingSteps.length, (index) {
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;

            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? EchoesColors.success
                        : isCurrent
                        ? _processingSteps[index].color
                        : EchoesColors.textTertiary.withOpacity(0.3),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (index < _processingSteps.length - 1)
                  Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: index < _currentStep
                          ? EchoesColors.success
                          : EchoesColors.textTertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            );
          }),
        ),

        const SizedBox(height: 24),

        // Overall progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: EchoesColors.textTertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [EchoesColors.primary, EchoesColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepInfo() {
    final currentStepData = _currentStep < _processingSteps.length
        ? _processingSteps[_currentStep]
        : ProcessingStep(
            title: 'Complete!',
            subtitle: 'Your story is ready!',
            icon: Icons.celebration,
            color: EchoesColors.success,
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Column(
        key: ValueKey(_currentStep),
        children: [
          Text(
            currentStepData.title,
            style: EchoesTypography.headlineMedium.copyWith(
              color: EchoesColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            currentStepData.subtitle,
            style: EchoesTypography.bodyLarge.copyWith(
              color: EchoesColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEncouragingMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoesColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoesColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: EchoesColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: EchoesColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'We\'re weaving your memory into a beautiful story that your family will treasure forever! ✨',
              style: EchoesTypography.bodyMedium.copyWith(
                color: EchoesColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => context.onBack(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        'Cancel',
        style: EchoesTypography.bodyMedium.copyWith(
          color: EchoesColors.textSecondary,
        ),
      ),
    );
  }
}

class ProcessingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  ProcessingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
