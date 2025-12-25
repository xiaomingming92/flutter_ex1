/*
 * @Author: xiaomingming wujixmm@gmail.com
 * @Date: 2025-12-03 15:56:57
 * @LastEditors: xiaomingming wujixmm@gmail.com
 * @LastEditTime: 2025-12-05 13:23:00
 * @FilePath: /ex1/lib/widgets/gallery_item_widget1.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
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
    this.imageAspectRatio = .77,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = width ?? screenWidth;
    final aspectRatio = item.height != null && item.height! > 0
        ? item.width! / item.height!
        : imageAspectRatio;
    final itemHeight = itemWidth / aspectRatio;
    return Container(
      width: itemWidth,
      height: itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
                child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
              );
            },
          ),
          if (item.title != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  item.title!,
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
