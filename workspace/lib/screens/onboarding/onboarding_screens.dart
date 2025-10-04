import 'package:flutter/material.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // Light blue
              Color(0xFFF0FDF4), // Light green
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background blur effects
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                right: 40,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(64),
                  ),
                ),
              ),

              // Back button (only show on pages 2 and 3)
              if (_currentPage > 0)
                Positioned(
                  top: 32,
                  left: 24,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Color(0xFF364153),
                      ),
                    ),
                  ),
                ),

              // Main content
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingPage(
                    imageUrl:
                        'https://www.figma.com/api/mcp/asset/c1dba9d6-722c-4dfa-8089-49562ed7b47c',
                    title: 'Capture Family Stories',
                    description:
                        'Record precious memories and stories from your loved ones with just a tap',
                    pageIndex: 0,
                    buttonText: 'Next',
                    onButtonPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  OnboardingPage(
                    imageUrl:
                        'https://www.figma.com/api/mcp/asset/be05547d-39e8-4368-9add-bf45ff491507',
                    title: 'Transform into Bedtime Adventures',
                    description:
                        'Our AI turns family memories into magical bedtime stories your kids will love',
                    pageIndex: 1,
                    buttonText: 'Next',
                    onButtonPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  OnboardingPage(
                    imageUrl:
                        'https://www.figma.com/api/mcp/asset/75e429d2-c122-4f3e-b923-0ac9b0aa2c1e',
                    title: 'Preserve Memories Forever',
                    description:
                        'Build a beautiful library of family stories that will be treasured for generations',
                    pageIndex: 2,
                    buttonText: 'Start Recording',
                    onButtonPressed: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final int pageIndex;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const OnboardingPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.pageIndex,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // Light blue
              Color(0xFFF0FDF4), // Light green
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, pageIndex == 1 ? 100 : 116, 24, 24),
            child: Column(
              children: [
                // Logo section
                _buildLogoSection(),
                const SizedBox(height: 24),
                
                // Image section
                Flexible(child: _buildImageSection()),
                const SizedBox(height: 24),
                
                // Title and description
                _buildContent(),
                const SizedBox(height: 24),
                
                // Page indicators
                _buildPageIndicators(),
                const SizedBox(height: 24),
                
                // Next button
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('🦉', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Echoes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF364153),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageWidth = constraints.maxWidth > 256
            ? 256
            : constraints.maxWidth * 0.8;
        double imageHeight = imageWidth * 0.75; // Maintain aspect ratio

        return Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    pageIndex == 0
                        ? Icons.family_restroom
                        : pageIndex == 1
                        ? Icons.auto_stories
                        : Icons.library_books,
                    size: imageHeight * 0.4,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double titleFontSize = constraints.maxWidth < 300 ? 20 : 24;
        double descriptionFontSize = constraints.maxWidth < 300 ? 14 : 16;

        return Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E2939),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: descriptionFontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A5565),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = index == pageIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00C950) : const Color(0xFFD1D5DC),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C950),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (buttonText != 'Start Recording') ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
