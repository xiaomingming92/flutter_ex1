/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-06 16:21:07
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-22 09:07:28
 * @FilePath     : \ex1\lib\pages\HomePage.custom.dart
 * @Description  : 首页
 */
import 'package:flutter/material.dart';

import 'FeedPage.dart';
import "GallaryPage1.dart";
import "Messages.dart";
import "PostPage1.dart";
import 'ProfilePage.dart';

// 自定义底部导航栏边框绘制器，实现闲鱼式的边框效果
class BottomNavBarBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final buttonRadius = 30.0; // 圆形按钮半径
    final borderRadius = 30.0; // 边框弧线半径

    // 计算路径
    final path = Path();

    // 左上角起点
    path.moveTo(0, 0);

    // 左侧直线到曲线起点
    path.lineTo(centerX - borderRadius - 20, 0);

    // 左侧弧线
    path.quadraticBezierTo(
      centerX - buttonRadius -10, 0,   // 控制点（贴边）
      centerX - buttonRadius, -10,      // 终点
    );
    // 底部弧线（凸起按钮）
    path.arcToPoint(
      Offset(centerX + buttonRadius , -10),
      radius: Radius.circular(40),
      clockwise: true,
    );

    // 右侧弧线
    path.quadraticBezierTo(
      centerX + buttonRadius + 10, 0,   // 控制点（贴边）
      centerX + buttonRadius + 20, 0, 
    );

    // 右侧直线到终点
    path.lineTo(size.width + 20, 0);
    // 闭合路径以填充
    path.lineTo(size.width + 20, size.height);
    path.lineTo(0, size.height);
    path.close();

    // 绘制填充
    final fillPaint = Paint()
      ..color = Colors.white // 填充色
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 绘制边框
    // final strokePaint = Paint()
    //   ..color = Colors.transparent
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0
    //   ..strokeCap = StrokeCap.round
    //   ..strokeJoin = StrokeJoin.round;
    // canvas.drawPath(path, strokePaint);
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
          SizedBox(
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
                  size: Size(MediaQuery.of(context).size.width, 60),
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
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: -15,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PostPage1(),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
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
