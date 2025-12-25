/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2025-12-06 16:21:07
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-25 09:16:40
 * @FilePath     : \ex1\lib\widgets\gallery_item_widget2.dart
 * @Description  : 
 */
import 'package:flutter/material.dart';

import '../apis/gallery.dart';
import 'gallery_item_skeleton.dart';

class GalleryItemWidget extends StatelessWidget {
  // 单个瀑布流内部元素
  final GalleryItem item;

  // 内部元素宽度
  final double? width;
  // 图片宽高比
  final double imageAspectRatio;

  const GalleryItemWidget({
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
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片部分：占满可用宽度
                Expanded(
                  child: GalleryItemSkeleton(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // 文字部分
                Container(
                  width: double.infinity,
                  color: Colors.white, // 设置背景色
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.description != null) 
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
