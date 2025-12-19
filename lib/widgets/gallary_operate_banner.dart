/*
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 15:21:35
 * @FilePath: \studioProjects\ex1\lib\widgets\gallary_operate_banner.dart
 * @Description: 
 */
import 'package:flutter/material.dart';

class GallaryOperateBannerWidget extends StatelessWidget {
  const GallaryOperateBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // 左侧大图
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // image: const DecorationImage(
                //   image: AssetImage('assets/images/banner1.jpg'),
                //   fit: BoxFit.contain,
                // ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 右侧小图
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      // image: DecorationImage(
                      //   image: AssetImage('assets/images/banner1.jpg'),
                      //   fit: BoxFit.contain,
                      // ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '活动标题1',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
