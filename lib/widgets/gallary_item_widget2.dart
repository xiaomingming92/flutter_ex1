/*
 * @Author: xiaomingming wujixmm@gmail.com
 * @Date: 2025-12-04 08:53:23
 * @LastEditors: xiaomingming wujixmm@gmail.com
 * @LastEditTime: 2025-12-04 15:42:59
 * @FilePath: /ex1/lib/widgets/gallary_item_widget2.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import 'package:flutter/material.dart';

import '../apis/gallary.dart';
import 'gallary_item_skeleton.dart';

class GallaryItemWidget extends StatelessWidget {
  // 单个瀑布流内部元素
  final GalleryItem item;

  // 内部元素宽度
  final double? width;
  // 图片宽高比
  final double imageAspectRatio;

  const GallaryItemWidget({
    super.key,
    required this.item,
    this.width,
    this.imageAspectRatio = 0.75,
  });
  //

  @override
  Widget build(BuildContext context) {
    // 计算内部元素的高度
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = width ?? screenWidth;
    final aspectRatio =
        item.width != null && item.height != null && item.height! > 0
        ? item.width! / item.height!
        : imageAspectRatio;

    return SizedBox(
      width: itemWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 100, maxHeight: 400),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 图片加载：由 GalleryItemSkeleton 处理骨架屏和加载过程
                GalleryItemSkeleton(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.contain,
                ),

                // 标题覆盖层（可选）
                ...(item.title != null
                    ? [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              item.title!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ]
                    : []),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
