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
