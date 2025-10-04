import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/navigation/app_router.dart';

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
  int _currentStep = 0;

  final List<String> _processingSteps = [
    'Saving your memory...',
    'Whispering to the cloud...',
    'Crafting your story...',
    'Adding magical touches...',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _startProcessing();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _startProcessing() {
    // Simulate processing steps
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
      // Auto-navigate to story view after processing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.goToStoryView(widget.memoryId ?? 'default_memory');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Processing Animation
              AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner circle with mascot
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      // Sparkles
                      ...List.generate(6, (index) {
                        final angle =
                            (index * 60.0) + (_sparkleController.value * 360);
                        final radian = angle * 3.14159 / 180;
                        final radius = 80.0;
                        final x = radius * math.cos(radian);
                        final y = radius * math.sin(radian);

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellow,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // Progress Indicator
              LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),

              const SizedBox(height: 24),

              // Current Step
              Text(
                _currentStep < _processingSteps.length
                    ? _processingSteps[_currentStep]
                    : 'Almost done!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Encouraging Message
              const Text(
                'We\'re creating something magical from your memory! ✨',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Cancel Button
              TextButton(
                onPressed: () => context.onBack(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
