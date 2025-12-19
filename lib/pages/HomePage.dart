/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2025-10-23 12:56:05
 * @LastEditors: xiaomingming wujixmm@gmail.com
 * @LastEditTime: 2025-12-05 08:43:20
 * @FilePath: /ex1/lib/pages/HomePage.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import "package:flutter/material.dart";
import 'FeedPage.dart';
import 'GallaryPage1.dart';
import 'Messages.dart';
import 'PostPage.dart';
import 'ProfilePage.dart';

/**
 * @description: tab基座
 * @return {*}
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  int _selTab = 0;

  final pages = const [
    FeedPage(),
    GallaryPage1(),
    PostPage(userId: 123),
    MessagePage(),
    ProfilePage(),
  ];

  void _onSelTab(int index) {
    setState(() => _selTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selTab,
        onTap: _onSelTab,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: "相册"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '发布',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
