/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-25 09:58:02
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-25 10:31:31
 * @FilePath     : \ex1\lib\widgets\firstScreenStatic.dart
 * @Description  : 静态展示页
 */
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirstScreenStatic extends StatelessWidget {
  const FirstScreenStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 15, 10, 10),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/flutter_icon.svg',
          width: 200,
          fit: BoxFit.contain
        ),
      ),
    );
  }
}