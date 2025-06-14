import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state when navigating back
  bool shouldRefresh = false; // Flag to trigger publications refresh

  @override
  void initState() {
    super.initState();
    // Load profile data when the widget is initialized
    _loadProfile();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(ProfileLoad());
  }

  // Refresh publications after creating a new post
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['refresh'] == true) {
      setState(() {
        shouldRefresh = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          shouldRefresh = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.username}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(child: _buildCreatePostButton()),
                                  const SizedBox(width: 8),
                                  Flexible(child: _buildModifyButton(user)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(DEFAULT_PROFILE_PIC),
                          foregroundImage: NetworkImage(user.image),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Theme.of(context).colorScheme.outline),
                    Expanded(
                      child: ShowOwnPublicationsPage(
                        key: ValueKey(shouldRefresh),
                        refresh: shouldRefresh,
                      ),
                    ),
                  ],
                );
              } else if (state is ProfileFailure) {
                return Center(
                  child: Text(
                    state.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModifyButton(User user) {
    return SecondaryButton(
      onPressed: () async {
        final result = await context.push(Paths.editProfile, extra: user);
        // Reload profile when returning from edit page to fresh data

        if (result == true) {
          _loadProfile();
        }
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
        context.push(Paths.create);
      },
      isLoading: false,
      text: 'New Post',
      isEnabled: true,
      height: 32,
      width: 160,
    );
  }
}
