import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePageTabController extends StatefulWidget {
  const HomePageTabController({super.key});

  @override
  State<HomePageTabController> createState() => _HomePageTabControllerState();
}

class _HomePageTabControllerState extends State<HomePageTabController>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _pages = [
    const Center(child: Text('首页')),
    const Center(child: Text('发现')),
    const Center(child: Text('消息')),
    const Center(child: Text('我的')),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
          setState(() {});
        },
      ),
    );
  }
}
