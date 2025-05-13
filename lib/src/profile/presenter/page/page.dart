import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/widgets/secondary_button.dart';
import 'package:mobile/src/profile/domain/domain.dart';
import 'package:mobile/src/profile/presenter/presenter.dart';
import 'package:mobile/src/profile/presenter/widgets/widgets.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
void initState() {
  super.initState();
  context.read<ProfileBloc>().add(ProfileLoad());
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const ProfileSkeleton();
                } else if (state is ProfileSuccess) {
                  final user = state.user;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '@${user.username}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.email,
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
                            backgroundImage: NetworkImage(user.image),
                            backgroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      Expanded(
                        child: BlocProvider(
                          create: (context) => PublicationBloc(
                            publicationRepository: context.read<PublicationRepository>(),
                          )..add(LoadPublications()),
                          child: const PublicationsList(),
                        ),
                      ),
                    ],
                  );
                } else if (state is ProfileFailure) {
                  return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                } else {
                  return const SizedBox();
                }
              },
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
  



