import 'package:flutter/material.dart';
import 'package:mobile/src/home/_children/news/news.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelStyle: Theme.of(context).textTheme.titleMedium,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
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
