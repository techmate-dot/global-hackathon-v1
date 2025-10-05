import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';

// Figma-derived design constants (rounded to 3 decimals where applicable)
class _HSizes {
  static const double headerHeight = 79.994; // ~80
  static const double cardRadius = 14.0;
  static const double memoryCardHeight = 105.25;
  static const double memoryImageSize = 63.995; // ~64
  static const double quickActionHeight = 177.245; // ~177
  static const double chatCardHeight = 117.25; // ~117
  static const double gap = 16.0; // between cards
}

class _HTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1E2939),
    letterSpacing: -0.45,
    height: 28 / 20,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1E2939),
    letterSpacing: -0.44,
    height: 28 / 18,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1E2939),
    letterSpacing: -0.31,
    height: 24 / 16,
  );
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    letterSpacing: -0.15,
    height: 20 / 14,
  );
  static const TextStyle meta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6A7282),
    height: 16 / 12,
  );
  static const TextStyle viewAll = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF00A63E),
    letterSpacing: -0.15,
    height: 20 / 14,
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Echoes logo and profile
                  _buildHeader(context),
                  const SizedBox(height: 32),

                  // My Memories Section
                  _buildMyMemoriesSection(context),
                  const SizedBox(height: 32),

                  // Quick Actions Section
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),

            // Floating Action Button
            _buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: _HSizes.headerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Echoes Logo with Owl
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🦉', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Echoes', style: _HTypography.h1),
                  const Text('AI Memory Keeper', style: _HTypography.subtitle),
                ],
              ),
            ],
          ),

          // Profile Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => context.goToProfile(),
              icon: Icon(Icons.person, size: 16, color: Color(0xFF364153)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMemoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Memories', style: _HTypography.sectionTitle),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              child: Row(
                children: const [
                  Icon(Icons.arrow_forward, size: 16, color: Color(0xFF00A63E)),
                  SizedBox(width: 4),
                  Text('View All', style: _HTypography.viewAll),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMemoryCard(
          context,
          title: 'The Brave Little Soldier',
          subtitle: 'Grandpa\'s War Stories',
          date: '15/01/2024',
        ),
        const SizedBox(height: 16),
        _buildMemoryCard(
          context,
          title: 'The Magic Kitchen',
          subtitle: 'Grandma\'s Cooking Adventures',
          date: '20/01/2024',
        ),
      ],
    );
  }

  Widget _buildMemoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String date,
  }) {
    return SizedBox(
      height: _HSizes.memoryCardHeight,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.628, 16.628, 0.629, 0.629),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 0.629,
          ),
          borderRadius: BorderRadius.circular(_HSizes.cardRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _HSizes.memoryImageSize,
              height: _HSizes.memoryImageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_HSizes.cardRadius),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_HSizes.cardRadius),
                child: const ColoredBox(
                  color: Colors.white,
                  child: Center(
                    child: Text('📘', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: _HTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: _HTypography.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C950),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(date, style: _HTypography.meta),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        // width formula from figma: (totalWidth - gap) / 2
        final double cardWidth = (totalWidth - _HSizes.gap) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: _HTypography.sectionTitle),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  height: _HSizes.quickActionHeight,
                  child: _buildActionCard(
                    context,
                    title: 'New Recording',
                    subtitle: 'Capture a new memory',
                    icon: Icons.mic,
                    backgroundColor: const Color(0xFF00C950),
                    borderColor: const Color(0xFFB9F8CF),
                    onTap: () => context.goToRecording(),
                  ),
                ),
                const SizedBox(width: _HSizes.gap),
                SizedBox(
                  width: cardWidth,
                  height: _HSizes.quickActionHeight,
                  child: _buildActionCard(
                    context,
                    title: 'Story Library',
                    subtitle: 'Browse all stories',
                    icon: Icons.library_books,
                    backgroundColor: const Color(0xFF2B7FFF),
                    borderColor: const Color(0xFFBEDBFF),
                    onTap: () => context.goToLibrary(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: _HSizes.chatCardHeight,
              child: _buildChatCard(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(
            0.12,
          ), // Card background (subtle tint)
          border: Border.all(color: borderColor, width: 0.629),
          borderRadius: BorderRadius.circular(_HSizes.cardRadius),
        ),
        child: Stack(
          children: [
            // Content column centered
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: _HTypography.cardTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: _HTypography.cardSubtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goToChat(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.627, 24.627, 24.627, 0.629),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8FF), // Figma chat card background
          border: Border.all(color: const Color(0xFFE9D4FF), width: 0.629),
          borderRadius: BorderRadius.circular(_HSizes.cardRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFAD46FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Chat with Memories', style: _HTypography.cardTitle),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 206,
                    child: Text(
                      'Ask questions about your family stories',
                      style: _HTypography.cardSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Text('🧠', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      right: 24, // visually matches figma (approx 305.73 left for 394 width)
      bottom: 24, // align with design proportionally
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Color(0xFF00C950),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => context.goToRecording(),
          icon: Icon(Icons.add, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
