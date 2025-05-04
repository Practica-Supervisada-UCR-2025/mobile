import 'package:flutter/material.dart';
import 'package:mobile/core/globals/widgets/secondary_button.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fernando Arce',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@ferac',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'fernando.arcecastillo@ucr.ac.cr',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(child: _buildCreatePostButton()),
                          const SizedBox(width: 8),
                          Flexible(child: _buildModifyButton()),
                        ],
                      ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  CircleAvatar(
                    radius: 35,
                    // backgroundImage: AssetImage('assets/profile.jpg'),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(color: Theme.of(context).colorScheme.outline),

              // TODO: Implement posts section
              Expanded(
                child: Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModifyButton() {
    return SecondaryButton(
      onPressed: () {
        // TODO: Implement modify profile functionality
      },
      isLoading: false,
      text: 'Edit Profile',
      isEnabled: true,
      height: 32,
      width: 160,
    );
  }

  Widget _buildCreatePostButton() {
    return SecondaryButton(
      onPressed: () {
        // TODO: Implement create post functionality
      },
      isLoading: false,
      text: 'New Post',
      isEnabled: true,
      height: 32,
      width: 160,
    );
  }
}
