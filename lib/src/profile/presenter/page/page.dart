import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/core/globals/publications/presenter/widgets/image_page.dart';
import 'package:mobile/src/profile/profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool isFeed;
  final String? userId;

  const ProfileScreen({super.key, required this.isFeed, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state when navigating back
  final GlobalKey<PublicationsListState> _publicationsKey =
      GlobalKey<PublicationsListState>();
  late final ScrollController _scrollController;
  int? _lastRefreshTimestamp;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Load profile data when the widget is initialized
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(ProfileLoad(userId: widget.userId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    final currentRefresh = extra is Map ? extra['refresh'] as int? : null;
    if (_lastRefreshTimestamp != currentRefresh && currentRefresh != null) {
      _lastRefreshTimestamp = currentRefresh;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          if (_publicationsKey.currentState != null) {
            ScrollStorage.setOffset("ownPosts", 0.0);
            await _publicationsKey.currentState!.refresh();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isOwnProfile = widget.userId == null;
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        if (_publicationsKey.currentState != null) {
          await _publicationsKey.currentState!.refresh();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const ProfileSkeleton();
                } else if (state is ProfileSuccess) {
                  final user = state.user;
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Row(
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
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  if (isOwnProfile) ...[
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: _buildModifyButton(user),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ImagePreviewScreen(
                                          imageUrl: user.image,
                                        ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: user.image,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(
                                    DEFAULT_PROFILE_PIC,
                                  ),
                                  foregroundImage: NetworkImage(user.image),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Divider(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ],
                        ),
                      ),

                      isOwnProfile
                          ? ShowOwnPublicationsPage(
                            isFeed: widget.isFeed,
                            publicationsKey: _publicationsKey,
                            scrollController: _scrollController,
                          )
                          : ShowPostFromOthersPage(
                            userId: widget.userId!,
                            isFeed: widget.isFeed,
                            scrollController: _scrollController,
                            publicationsKey: _publicationsKey,
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
      height: 36,
      width: 320,
    );
  }
}
