/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-04
 * @Description   : 相册 item 的骨架屏与加载状态处理
 * 负责在图片加载过程中显示占位/进度，加载完成后显示真实图片
 * 
 */
import 'package:flutter/material.dart';

/// 处理图片加载的骨架屏与过渡逻辑
///
/// 核心职责：
/// 1. 加载中（loadingProgress != null）→ 显示骨架 + 进度条
/// 2. 加载完毕（loadingProgress == null）→ 显示真实图片（带淡入）
/// 3. 加载失败 → 显示错误状态
class GalleryItemSkeleton extends StatelessWidget {
  /// 图片 URL
  final String imageUrl;

  /// 图片如何在容器内呈现（contain 保留完整、cover 填满等）
  final BoxFit fit;

  /// 加载完毕时的淡入动画时长
  final Duration fadeInDuration;

  /// 错误时的占位 widget
  final Widget? errorWidget;

  /// 缩略图或预览 URL（可选：加载大图前先显示）
  final String? thumbnailUrl;

  const GalleryItemSkeleton({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.errorWidget,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 可选：先显示缩略图或低分辨率预览（可加进度）
        if (thumbnailUrl != null) 
          Image.network(
            thumbnailUrl!,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),

        // 真实图片：处理加载过程
        Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            // 加载完毕：显示真实图片，带淡入动画
            if (loadingProgress == null) {
              return AnimatedOpacity(
                opacity: 1.0,
                duration: fadeInDuration,
                child: child,
              );
            }

            // 加载中：显示骨架 + 进度指示
            return _buildLoadingView(loadingProgress);
          },
          errorBuilder: (context, error, stackTrace) {
            // 加载失败：显示错误状态
            return errorWidget ??
                Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
          },
        ),
      ],
    );
  }

  /// 构建加载中的视图（骨架 + 进度）
  Widget _buildLoadingView(ImageChunkEvent loadingProgress) {
    final expectedBytes = loadingProgress.expectedTotalBytes;
    final loadedBytes = loadingProgress.cumulativeBytesLoaded;

    // 计算进度值（0.0 ~ 1.0）
    final progress = expectedBytes != null ? loadedBytes / expectedBytes : null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 进度指示器
          CircularProgressIndicator(value: progress, strokeWidth: 3),
          const SizedBox(height: 12),

          // 显示已加载字节数（可选）
          if (expectedBytes != null)
            Text(
              '${(loadedBytes / 1024).toStringAsFixed(1)} KB / ${(expectedBytes / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }
}
