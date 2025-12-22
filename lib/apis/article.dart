/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-19
 * @FilePath     : \ex1\lib\apis\article.dart
 * @Description   : 文章相关 API
 */

import 'dart:io';
import 'package:dio/dio.dart';
import '../network/dio.dart';
import '../network/request.dart';

class ArticleApi {
  /// 上传图片
  static Future<ResponseData<UploadImageRes>> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'folder': 'article_images',
    });

    final response = await DioClient.instance.post<dynamic>(
      '/oss/upload',
      data: formData,
    );

    return ResponseData.parse(response.data, (json) {
      if (json is Map<String, dynamic>) {
        return UploadImageRes.fromMap(json);
      }
      return UploadImageRes(
        code: json['code'] as int? ?? 0,
        message: json['message'] as String? ?? '',
        url: json['url'] as String? ?? '',
        imageId: json['imageId'] as String? ?? '',
      );
    });
  }

  /// 创建文章
  static Future<ResponseData<ArticleRes>> createArticle({
    required String title,
    required String content,
    List<String>? imageIds,
  }) async {
    return await Request.post<ArticleRes>(
      '/article',
      data: {
        'title': title,
        'content': content,
        if (imageIds != null && imageIds.isNotEmpty) 'imageIds': imageIds,
      },
      parseT: (json) => ArticleRes.fromMap(json as Map<String, dynamic>),
    );
  }

  /// 获取文章详情
  static Future<ResponseData<ArticleRes>> getArticleById(String id) async {
    return await Request.get<ArticleRes>(
      '/article/$id',
      parseT: (json) => ArticleRes.fromMap(json as Map<String, dynamic>),
    );
  }
}

class UploadImageRes {
  final int code;
  final String message;
  final String url;
  final String imageId;
  final String? fileName;

  UploadImageRes({
    required this.code,
    required this.message,
    required this.url,
    required this.imageId,
    this.fileName,
  });

  factory UploadImageRes.fromMap(Map<String, dynamic> json) {
    return UploadImageRes(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageId: json['imageId'] as String? ?? '',
      fileName: json['fileName'] as String?,
    );
  }
}

class ArticleRes {
  final int code;
  final String message;
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleRes({
    required this.code,
    required this.message,
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleRes.fromMap(Map<String, dynamic> json) {
    return ArticleRes(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

