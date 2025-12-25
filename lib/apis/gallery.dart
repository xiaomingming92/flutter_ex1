/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 09:00:43
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 15:41:33
 * @FilePath: \studioProjects\ex1\lib\apis\gallary.dart
 * @Description   : 相册接口
 * 
 */
import '../network/dio.dart';
import '../network/request.dart';

class GalleryApi {
  /// 获取相册列表
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量，默认10
  static Future<ResponseData<GalleryRes>> getGalleryList({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await Request.get<GalleryRes>(
      '/waterfall',
      params: {'page': page, 'pageSize': pageSize},
      parseT: (data) => GalleryRes.fromMap(data),
    );
    // print(res);
    // return GalleryRes(
    //   code: res.code,
    //   message: res.message,
    //   items:
    //       res.data != null && res.data['items'] != null && res.data['items'] is List
    //           ? (res.data['items'] as List).map((x) => GalleryItem.fromMap(x)).toList()
    //           : []
    // );
  }
}

class GalleryRes {
  final int code;
  final String message;
  final List<GalleryItem> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  GalleryRes({required this.code, required this.message, required this.items, required this.total, required this.page, required this.pageSize, required this.totalPages});
  factory GalleryRes.fromMap(Map<String, dynamic> json) {
    return GalleryRes(
      code: json['code']?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List).map((x) => GalleryItem.fromMap(x)).toList()
          : [],
      total: json['total']?.toInt() ?? 0,
      page: json['page']?.toInt() ?? 0,
      pageSize: json['pageSize']?.toInt() ?? 0,
      totalPages: json['totalPages']?.toInt() ?? 0,
    );
  }
}

/// 相册数据模型
class GalleryItem {
  final String id;
  final String imageUrl;
  final double? width;
  final double? height;
  final String? title;
  final String? description;
  final String? articleId;
  final String? createdAt;
  final String? updatedAt;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    this.width,
    this.height,
    this.title,
    this.description,
    required this.articleId,
    this.createdAt,
    this.updatedAt,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      width: json['width']?.toDouble() ?? 0.0,
      height: json['height']?.toDouble() ?? 0.0,
      title: json['title'],
      description: json['description'],
      articleId: json['articleId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
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
