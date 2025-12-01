/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-11-13 14:35:00
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-11-13 14:35:00
 * @FilePath      : /ex1/lib/widgets/gallery_skeleton.dart
 * @Description   : 相册骨架屏
 * 
 */
import 'package:flutter/material.dart';

class GallerySkeleton extends StatelessWidget {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const GallerySkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
    final columnWidth = (screenWidth - totalSpacing) / crossAxisCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: crossAxisSpacing / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(crossAxisCount, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: crossAxisSpacing / 2),
              child: Column(
                children: List.generate(3, (i) {
                  // 随机高度，模拟真实瀑布流
                  final heights = [180.0, 220.0, 160.0, 200.0, 190.0];
                  final height = heights[i % heights.length];
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < 2 ? mainAxisSpacing : 0,
                    ),
                    child: _SkeletonItem(
                      width: columnWidth,
                      height: height,
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SkeletonItem extends StatefulWidget {
  final double width;
  final double height;

  const _SkeletonItem({
    required this.width,
    required this.height,
  });

  @override
  State<_SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<_SkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300]!.withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}

