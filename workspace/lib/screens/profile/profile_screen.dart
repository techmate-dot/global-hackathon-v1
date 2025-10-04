import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.onBack(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.green[100],
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grandma Rose',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'rose@echoes.app',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Edit profile
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Memories Shared',
                            '12',
                            Icons.mic,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Stories Created',
                            '8',
                            Icons.auto_stories,
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Day Streak',
                            '5',
                            Icons.local_fire_department,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings
            Card(
              child: Column(
                children: [
                  _buildSettingsItem(
                    'Notifications',
                    'Daily prompts and reminders',
                    Icons.notifications,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'Privacy Settings',
                    'Control who can see your stories',
                    Icons.privacy_tip,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'Audio Quality',
                    'Recording and playback settings',
                    Icons.audio_file,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'Family Members',
                    'Manage family access',
                    Icons.family_restroom,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'Export Stories',
                    'Download your memories',
                    Icons.download,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Support & About
            Card(
              child: Column(
                children: [
                  _buildSettingsItem(
                    'Help & Support',
                    'Get help with the app',
                    Icons.help,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'About Echoes',
                    'Version 1.0.0',
                    Icons.info,
                    () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    'Terms & Privacy',
                    'Legal information',
                    Icons.gavel,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Sign out
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
