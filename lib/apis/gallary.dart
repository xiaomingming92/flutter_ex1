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

class GallaryApi {
  /// 获取相册列表
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量，默认10
  static Future<ResponseData<GallaryRes>> getGallaryList({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await Request.get<GallaryRes>(
      '/waterfall',
      params: {'page': page, 'pageSize': pageSize},
      parseT: (data) => GallaryRes.fromMap(data),
    );
    // print(res);
    // return GallaryRes(
    //   code: res.code,
    //   message: res.message,
    //   items:
    //       res.data != null && res.data['items'] != null && res.data['items'] is List
    //           ? (res.data['items'] as List).map((x) => GallaryItem.fromMap(x)).toList()
    //           : []
    // );
  }
}

class GallaryRes {
  final int code;
  final String message;
  final List<GallaryItem> items;

  GallaryRes({required this.code, required this.message, required this.items});
  factory GallaryRes.fromMap(Map<String, dynamic> json) {
    return GallaryRes(
      code: json['code']?.toInt() ?? 0,
      message: json['message']?.toString() ?? '',
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List).map((x) => GallaryItem.fromMap(x)).toList()
          : [],
    );
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
  final String? articleId;
  final String? createdAt;
  final String? updatedAt;

  GallaryItem({
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

  factory GallaryItem.fromMap(Map<String, dynamic> json) {
    return GallaryItem(
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
