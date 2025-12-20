/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-06 16:21:07
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-20 18:52:25
 * @FilePath     : \ex1\lib\pages\HomePage.custom.dart
 * @Description  : 首页
 */
import 'package:flutter/material.dart';

import 'FeedPage.dart';
import "GallaryPage1.dart";
import "Messages.dart";
import "PostPage.dart";
import 'ProfilePage.dart';

// 自定义底部导航栏边框绘制器，实现闲鱼式的边框效果
class BottomNavBarBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final buttonRadius = 35.0; // 圆形按钮半径
    final borderRadius = 39.0; // 边框弧线半径，只比圆形按钮半径大4px左右，接近闲鱼效果

    // 计算路径
    final path = Path();

    // 左上角起点
    path.moveTo(0, 0);

    // 左侧直线到曲线起点
    path.lineTo(centerX - borderRadius - 10, 0);

    // 左侧弧线（包裹按钮的差集部分）
    // 设计思路：从导航栏左侧直线终点平滑过渡到按钮左侧顶部边缘，形成包裹效果
    // 实现意图：创建一个比按钮半径大4px的逆时针弧线，使边框自然包裹按钮差集部分
    // 左侧弧线
    path.arcToPoint(
      Offset(centerX - buttonRadius - 4, -6),
      radius: Radius.circular(8),
      clockwise: false,
    );

    // 底部弧线（凸起按钮）
    path.arcToPoint(
      Offset(centerX + buttonRadius + 4, -6),
      radius: Radius.circular(43),
      clockwise: true,
    );

    // 右侧弧线
    path.arcToPoint(
      Offset(centerX + borderRadius + 10, 0),
      radius: Radius.circular(8),
      clockwise: false,
    );

    // 右侧直线到终点
    path.lineTo(size.width + 10, 0);

    // 绘制路径
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selTabIdx = 0;
  final _pages = [FeedPage(), GallaryPage1(), MessagePage(), ProfilePage()];

  void _onSelTab(int index) {
    switch (index) {
      // case 2: {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(builder: (_) => const PostPage(userId: 123,))
      //   );
      //   break;
      // }
      default:
        {
          setState(() => _selTabIdx = index);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selTabIdx],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // 底部导航栏主体 - 使用CustomPaint绘制自定义边框
          Container(
            height: 70,
            child: Stack(
              children: [
                // 背景白色容器
                Container(
                  width: double.infinity,
                  height: 70,
                  color: Colors.white,
                ),
                // 自定义边框绘制
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 70),
                  painter: BottomNavBarBorderPainter(),
                ),
                // 导航项
                Row(
                  children: [
                    Expanded(child: _tabItem(Icons.home, "首页", 0)),
                    Expanded(child: _tabItem(Icons.photo_library, "相册", 1)),
                    Expanded(child: Center(child: SizedBox(height: 50))),
                    Expanded(child: _tabItem(Icons.message, "消息", 2)),
                    Expanded(child: _tabItem(Icons.person, "我的", 3)),
                  ],
                ),
              ],
            ),
          ),
          // 内部圆形按钮（不被裁切）
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            top: -25,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PostPage(userId: 123),
                  ),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                  // border: Border.all(
                  //   color: const Color.fromARGB(255, 13, 13, 13),
                  //   width: 4,
                  // ),
                ),
                child: Icon(Icons.add, size: 32, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(IconData icon, String label, int index) {
    final isSeled = _selTabIdx == index;

    return GestureDetector(
      onTap: () => _onSelTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSeled ? Colors.orange : Colors.black),
          Text(
            label,
            style: TextStyle(
              color: isSeled ? Colors.orange : Colors.black,
              fontSize: 14,
              // backgroundColor: index == 2 ? Colors.greenAccent : Colors.white
            ),
          ),
        ],
      ),
    );
  }
}
