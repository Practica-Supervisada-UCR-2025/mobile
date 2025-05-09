import 'package:flutter/material.dart';
import 'package:mobile/src/home/_children/news/news.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.background,
          child: TabBar(
            controller: _tabController,
            labelStyle: Theme.of(context).textTheme.titleMedium,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'News'),
              Tab(text: 'Posts'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              NewsPage(),
              PostsPage(),
            ],
          ),
        ),
      ],
    );
  }
}
