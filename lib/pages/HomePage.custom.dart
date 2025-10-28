/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2025-10-27 14:57:48
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-10-27 15:44:33
 * @FilePath: /ex1/lib/pages/HomePage.custom.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:flutter/material.dart';

import 'FeedPage.dart';
import "GalleryPage.dart";
import "Messages.dart";
import "PostPage.dart";
import 'ProfilePage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selTabIdx = 0;
  final _pages = [
    FeedPage(),
    GalleryPage(),
    MessagePage(),
    ProfilePage()
  ];

  void _onSelTab(int index) {
    switch(index) {
      // case 2: {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(builder: (_) => const PostPage(userId: 123,))
      //   );
      //   break;
      // }
      default: {
        setState(() => _selTabIdx = index);
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selTabIdx],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostPage(userId: 123))
          );
        },
        backgroundColor: Colors.yellow,
        shape: CircleBorder(side: BorderSide.none),
        child: Icon(Icons.add, size: 32)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(child: _tabItem(Icons.home, "首页", 0)),
              Expanded(child: _tabItem(Icons.photo_library, "相册", 1)),
              const SizedBox(width: 48),
              Expanded(child: _tabItem(Icons.message, "消息", 2)),
              Expanded(child: _tabItem(Icons.person, "我的", 3)),
            ],
          )
        )
      ),
    );
  }
  Widget _tabItem(IconData icon, String label, int index) {
    final isSeled = _selTabIdx == index;

    return GestureDetector(
      onTap:() => _onSelTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSeled ? Colors.orange: Colors.black),
          Text(
            label,
            style: TextStyle(
              color: isSeled ? Colors.orange : Colors.black,
              fontSize: 14,
              // backgroundColor: index == 2 ? Colors.greenAccent : Colors.white
            ),
          )
        ],
      )
    );
  }
}