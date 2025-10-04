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
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text('The page you are looking for does not exist.'),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Navigation Extension for easy access
extension AppNavigation on BuildContext {
  // Core Navigation Methods
  void goToOnboarding() => go(AppRouter.onboarding);
  void goToHome() => go(AppRouter.home);
  void goToRecording() => go(AppRouter.recording);
  void goToLibrary() => go(AppRouter.library);
  void goToProfile() => go(AppRouter.profile);
  void goToChat() => go(AppRouter.chat);

  // Navigation with Parameters
  void goToProcessing(String memoryId) {
    go('${AppRouter.processing}?memoryId=$memoryId');
  }

  void goToStoryView(String memoryId) {
    go('${AppRouter.storyView}?memoryId=$memoryId');
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
