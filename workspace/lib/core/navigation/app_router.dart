import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/onboarding/onboarding_screens.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/recording/recording_screen.dart';
import '../../screens/processing/processing_screen.dart';
import '../../screens/story/story_view.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/chat/chat_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String recording = '/recording';
  static const String processing = '/processing';
  static const String storyView = '/story';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String chat = '/chat';

  static final GoRouter _router = GoRouter(
    initialLocation: onboarding,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding Flow
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreens(),
      ),

      // Home Dashboard - Central Hub
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Recording Flow
      GoRoute(
        path: recording,
        name: 'recording',
        builder: (context, state) => const RecordingScreen(),
      ),

      // Processing Screen
      GoRoute(
        path: processing,
        name: 'processing',
        builder: (context, state) {
          final memoryId = state.uri.queryParameters['memoryId'];
          return ProcessingScreen(memoryId: memoryId);
        },
      ),

      // Story View
      GoRoute(
        path: storyView,
        name: 'story',
        builder: (context, state) {
          final memoryId = state.uri.queryParameters['memoryId'];
          return StoryView(memoryId: memoryId);
        },
      ),

      // Library Catalog
      GoRoute(
        path: library,
        name: 'library',
        builder: (context, state) => const LibraryScreen(),
      ),

      // User Profile
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Chat Assistant
      GoRoute(
        path: chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${state.uri}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(onboarding),
              child: const Text('Go to Onboarding'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Navigation Extension for easy access
extension AppNavigation on BuildContext {
  // Core Navigation Methods
  void goToOnboarding() => GoRouter.of(this).go(AppRouter.onboarding);
  void goToHome() => GoRouter.of(this).go(AppRouter.home);
  void goToRecording() => GoRouter.of(this).go(AppRouter.recording);
  void goToLibrary() => GoRouter.of(this).go(AppRouter.library);
  void goToProfile() => GoRouter.of(this).go(AppRouter.profile);
  void goToChat() => GoRouter.of(this).go(AppRouter.chat);

  // Navigation with Parameters
  void goToProcessing(String memoryId) {
    GoRouter.of(this).go('${AppRouter.processing}?memoryId=$memoryId');
  }

  void goToStoryView(String memoryId) {
    GoRouter.of(this).go('${AppRouter.storyView}?memoryId=$memoryId');
  }

  // Navigation Flow Methods (matching PRD requirements)
  void onComplete() => goToHome(); // Onboarding completion
  void onStartRecording() => goToRecording(); // New Recording action
  void onSelectMemory(String memoryId) =>
      goToStoryView(memoryId); // Memory selection
  void onNavigate(String destination) {
    switch (destination) {
      case 'chat':
        goToChat();
        break;
      case 'library':
        goToLibrary();
        break;
      case 'profile':
        goToProfile();
        break;
      default:
        goToHome();
    }
  }

  void onBack() => goToHome(); // Always return to home as central hub
}
