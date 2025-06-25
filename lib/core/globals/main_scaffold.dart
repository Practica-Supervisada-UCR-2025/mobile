import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/paths.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Paths.home);
        break;
      case 1:
        context.go(Paths.search);
        break;
      case 2:
        context.push(Paths.create);
        break;
      case 3:
        context.go(Paths.notifications);
        break;
      case 4:
        context.go(Paths.profile);
        break;
    }
  }

  bool _shouldShowFab(BuildContext context) {
    // Show FAB in every route except for Create and Settings
    final location = GoRouterState.of(context).uri.toString();
    return !(
      location.startsWith(Paths.login) || 
      location.startsWith(Paths.register) || 
      location.startsWith(Paths.forgot_password) ||
      location.startsWith(Paths.create) || 
      location.startsWith(Paths.settings) || 
      location.startsWith(Paths.editProfile) ||
      location.startsWith(Paths.comments));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'UCR Connect',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.outline,
            ),
            onPressed: () => context.push(Paths.settings),
          ),
        ],
        automaticallyImplyLeading: false,
        shape: const Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      body: child,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _shouldShowFab(context)
            ? Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: FloatingActionButton(
                  key: const ValueKey('fab-visible'),
                  onPressed: () => context.push(Paths.create),
                  tooltip: 'Create new post',
                  child: const Icon(Icons.add),
                ),
              )
            : const SizedBox.shrink(key: ValueKey('fab-hidden')),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => _onTap(context, i),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.outline,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined, size: 30),
                activeIcon: Icon(Icons.add_box, size: 30),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none),
                activeIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
