/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:43
 * @LastEditors: xiaomingming wujixmm@gmail.com
 * @LastEditTime: 2025-12-05 11:05:46
 * @FilePath: /ex1/lib/apis/gallary.dart
 * @Description   : 相册接口
 * 
 */
import '../network/request.dart';

class GallaryApi {
  /// 获取相册列表
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量，默认10
  static Future<List<GallaryItem>> getGallaryList({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await Request.get(
      '/gallery/list',
      params: {'page': page, 'pageSize': pageSize},
    );

    if (res.data != null && res.data is List) {
      return (res.data as List)
          .map((item) => GallaryItem.fromJson(item))
          .toList();
    }
    return [];
  }
}

/// 相册数据模型
class GallaryItem {
  final String id;
  final String imageUrl;
  final double? width;
  final double? height;
  final String? title;
  final String? description;

  GallaryItem({
    required this.id,
    required this.imageUrl,
    this.width,
    this.height,
    this.title,
    this.description,
  });

  factory GallaryItem.fromJson(Map<String, dynamic> json) {
    return GallaryItem(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      title: json['title'],
      description: json['description'],
    );
  }

  /// 计算图片宽高比
  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    // 默认宽高比
    return 1.0;
  }
}
