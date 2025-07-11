// lib/screens/student/profile/widgets/profile_header.dart
import 'package:brainboosters_app/screens/student/profile/widgets/profile_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileData profileData;

  const ProfileHeader({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[900]!, Colors.blue[700]!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth <= 768;
              return isMobile 
                ? _buildMobileHeader() 
                : _buildDesktopHeader();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: profileData.avatarUrl != null 
            ? NetworkImage(profileData.avatarUrl!) 
            : null,
          child: profileData.avatarUrl == null
            ? Text(
                profileData.fullName.isNotEmpty 
                  ? profileData.fullName[0].toUpperCase() 
                  : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              )
            : null,
        ),
        const SizedBox(height: 8),
        Text(
          profileData.fullName.isEmpty ? 'User' : profileData.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (profileData.gradeLevel != null) ...[
          const SizedBox(height: 4),
          Text(
            'Grade ${profileData.gradeLevel}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Level', '${profileData.level}', Icons.trending_up),
            _buildStatItem('Streak', '${profileData.currentStreak}', Icons.local_fire_department),
            _buildStatItem('Points', '${profileData.totalPoints}', Icons.stars),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: profileData.avatarUrl != null 
            ? NetworkImage(profileData.avatarUrl!) 
            : null,
          child: profileData.avatarUrl == null
            ? Text(
                profileData.fullName.isNotEmpty 
                  ? profileData.fullName[0].toUpperCase() 
                  : 'U',
                style: const TextStyle(fontSize: 28, color: Colors.white),
              )
            : null,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profileData.fullName.isEmpty ? 'User' : profileData.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (profileData.gradeLevel != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Grade ${profileData.gradeLevel}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            _buildStatItem('Level', '${profileData.level}', Icons.trending_up),
            const SizedBox(width: 24),
            _buildStatItem('Streak', '${profileData.currentStreak} days', Icons.local_fire_department),
            const SizedBox(width: 24),
            _buildStatItem('Points', '${profileData.totalPoints}', Icons.stars),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
