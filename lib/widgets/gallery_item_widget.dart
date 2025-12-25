/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-11-13 14:30:00
 * @LastEditors: xiaomingming wujixmm@gmail.com
 * @LastEditTime: 2025-12-05 13:22:42
 * @FilePath: /ex1/lib/widgets/gallary_item_widget.dart
 * @Description   : 相册item组件，支持按比例contain显示
 * 
 */
import 'package:flutter/material.dart';
import '../apis/gallery.dart';

class GalleryItemWidget extends StatelessWidget {
  final GalleryItem item;
  final double? width;
  final double imageAspectRatio;

  const GalleryItemWidget({
    super.key,
    required this.item,
    this.width,
    this.imageAspectRatio = 0.75, // 默认宽高比
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = width ?? screenWidth;

    // 使用item的宽高比，如果没有则使用传入的默认值
    final aspectRatio =
        item.width != null && item.height != null && item.height! > 0
        ? item.width! / item.height!
        : imageAspectRatio;

    // 计算高度
    final itemHeight = itemWidth / aspectRatio;

    return Container(
      width: itemWidth,
      height: itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片，使用BoxFit.contain保持比例
          Image.network(
            item.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 48,
                ),
              );
            },
          ),
          // 标题覆盖层（可选）
          if (item.title != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Text(
                  item.title!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
