import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/navigation/app_router.dart';
import '../../providers/story_processing_provider.dart';

// Figma-derived design constants for processing screen
class _ProcessingConstants {
  // Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color yellowAccent = Color(0xFFFDC700);
  static const Color textPrimary = Color(0xFF1E2939);
  static const Color textSecondary = Color(0xFF4A5565);
  static const Color textTertiary = Color(0xFF364153);
  static const Color cardBackground = Color(0xFFFEFCE8);
  static const Color cardBorder = Color(0xFFFFF085);
  
  // Typography
  static const TextStyle heroText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.07,
    height: 32 / 24,
  );
  static const TextStyle descriptionText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.31,
    height: 26 / 16,
  );
  static const TextStyle stepText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle tipTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle tipContent = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 16 / 12,
  );
}

class ProcessingScreen extends StatefulWidget {
  final String? memoryId;

  const ProcessingScreen({super.key, this.memoryId});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _owlBounceController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _owlBounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Listen for completion and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoryProcessingProvider>();
      if (provider.isCompleted) {
        _navigateToStoryOrHome(provider);
      }
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _owlBounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateToStoryOrHome(StoryProcessingProvider provider) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (provider.generatedStory != null) {
          context.goToStoryView(provider.generatedStory!.id);
        } else {
          context.goToHome();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProcessingConstants.backgroundColor,
      body: Consumer<StoryProcessingProvider>(
        builder: (context, provider, child) {
          // Navigate to story view when processing is complete
          if (provider.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToStoryOrHome(provider);
            });
          }

          return Stack(
            children: [
              // Background sparkles
              _buildBackgroundSparkles(),
              
              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      
                      // Animated owl icon
                      _buildAnimatedOwl(),
                      
                      const SizedBox(height: 40),
                      
                      // Main title and description
                      _buildTitleSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Animated progress dots
                      _buildProgressDots(),
                      
                      const SizedBox(height: 48),
                      
                      // Processing steps
                      _buildProcessingSteps(provider),
                      
                      const Spacer(),
                      
                      // Did you know card
                      _buildDidYouKnowCard(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundSparkles() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Various positioned sparkles with different opacities and sizes
            _buildSparkle(153.15, 209.34, 0.487, 0.029),
            _buildSparkle(196.55, 460.47, 0.196, 0.012),
            _buildSparkle(235.96, 540.56, 2.608, 0.135),
            _buildSparkle(153.5, 470.87, 5.587, 0.355),
            _buildSparkle(233.99, 436.41, 8.009, 0.65),
            _buildSparkle(149, 581.99, 9.153, 0.997),
            _buildSparkle(266.36, 299.79, 5.036, 0.592),
            _buildSparkle(100.53, 353.51, 1.417, 0.137),
          ],
        );
      },
    );
  }

  Widget _buildSparkle(double left, double top, double size, double opacity) {
    final animatedOpacity = opacity * (0.5 + 0.5 * math.sin(_sparkleController.value * 2 * math.pi));
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _ProcessingConstants.yellowAccent.withOpacity(animatedOpacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildAnimatedOwl() {
    return AnimatedBuilder(
      animation: _owlBounceController,
      builder: (context, child) {
        final bounceOffset = math.sin(_owlBounceController.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, -bounceOffset),
          child: Container(
            width: 130.782,
            height: 130.782,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: _ProcessingConstants.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🦉',
                  style: TextStyle(
                    fontSize: 48,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Echo is polishing your story...',
          style: _ProcessingConstants.heroText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Our AI is transforming your precious memory\ninto a magical bedtime story that kids will love',
          style: _ProcessingConstants.descriptionText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressDots() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final animationOffset = (index * 0.3) % 1.0;
            final animatedValue = (_progressController.value + animationOffset) % 1.0;
            final scale = 0.7 + 0.3 * math.sin(animatedValue * 2 * math.pi);
            final opacity = 0.7 + 0.3 * math.sin(animatedValue * 2 * math.pi);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 17.694,
                  height: 17.694,
                  decoration: BoxDecoration(
                    color: _ProcessingConstants.primaryGreen.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProcessingSteps(StoryProcessingProvider provider) {
    return Column(
      children: [
        _buildStepItem(
          icon: '✓',
          title: 'Analyzing your recording',
          isCompleted: provider.isAnalyzing || provider.isCreatingStory || 
                       provider.isAddingIllustrations || provider.isCompleted,
          isActive: provider.isAnalyzing,
        ),
        const SizedBox(height: 12),
        _buildStepItem(
          icon: null,
          title: 'Creating magical story',
          isCompleted: provider.isCreatingStory || provider.isAddingIllustrations || provider.isCompleted,
          isActive: provider.isCreatingStory,
        ),
        const SizedBox(height: 12),
        _buildStepItem(
          icon: null,
          title: 'Adding illustrations',
          isCompleted: provider.isCompleted,
          isActive: provider.isAddingIllustrations,
          isDisabled: !provider.isAddingIllustrations && !provider.isCompleted,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    String? icon,
    required String title,
    required bool isCompleted,
    required bool isActive,
    bool isDisabled = false,
  }) {
    Widget buildIcon() {
      if (isCompleted && icon != null) {
        // Completed with checkmark
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: _ProcessingConstants.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '✓',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      } else if (isActive) {
        // Active with animated dot
        return AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return Container(
              width: 31.71,
              height: 31.71,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _ProcessingConstants.primaryGreen,
                  width: 1.887,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 10.57,
                  height: 10.57,
                  decoration: BoxDecoration(
                    color: _ProcessingConstants.primaryGreen.withOpacity(
                      0.7 + 0.3 * math.sin(_progressController.value * 2 * math.pi)
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        // Inactive or disabled
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled ? const Color(0xFFD1D5DC) : _ProcessingConstants.primaryGreen,
              width: 1.887,
            ),
            shape: BoxShape.circle,
          ),
        );
      }
    }

    return Row(
      children: [
        buildIcon(),
        const SizedBox(width: 12),
        Text(
          title,
          style: _ProcessingConstants.stepText.copyWith(
            color: isDisabled ? const Color(0xFF6A7282) : _ProcessingConstants.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildDidYouKnowCard() {
    return Container(
      padding: const EdgeInsets.all(16.628),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_ProcessingConstants.cardBackground, Color(0xFFFFFBEB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: _ProcessingConstants.cardBorder,
          width: 0.629,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '✨',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Did you know?',
                  style: _ProcessingConstants.tipTitle,
                ),
                SizedBox(height: 2),
                Text(
                  'Family stories help children develop empathy and understand their heritage',
                  style: _ProcessingConstants.tipContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}