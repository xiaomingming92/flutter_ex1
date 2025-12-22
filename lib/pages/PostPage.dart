import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../apis/article.dart';

class PostPage extends StatefulWidget {
  final String userId;
  const PostPage({super.key, required this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  
  // 选中的图片列表（本地文件路径）
  final List<File> _selectedImages = [];
  
  // 上传后的图片ID列表（用于提交到后端）
  final List<String> _uploadedImageIds = [];
  
  bool _isUploading = false;
  bool _isPublishing = false;

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // ------------------- 选择图片 -------------------
  Future<void> _pickImages() async {
    try {
      // 计算还能选择多少张（最多9张）
      final remainingCount = 9 - _selectedImages.length;
      if (remainingCount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("最多只能选择9张图片")),
          );
        }
        return;
      }

      final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: remainingCount,
          requestType: RequestType.image,
          themeColor: const Color(0xFF07C160),
        ),
      );

      if (selectedAssets == null || selectedAssets.isEmpty) return;

      // 转换为 File 列表
      final List<File> newImages = [];
      for (final asset in selectedAssets) {
        final File? imageFile = await asset.file;
        if (imageFile != null) {
          newImages.add(imageFile);
        }
      }

      if (newImages.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("选择图片失败：${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ------------------- 删除图片 -------------------
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      // 如果删除的是已上传的图片，也要从上传列表中移除
      if (index < _uploadedImageIds.length) {
        _uploadedImageIds.removeAt(index);
      }
    });
  }

  // ------------------- 上传图片到服务器 -------------------
  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    setState(() {
      _isUploading = true;
    });

    final List<String> imageIds = [];

    try {
      for (final imageFile in _selectedImages) {
        final response = await ArticleApi.uploadImage(imageFile);
        if (response.isSuccess && response.data != null) {
          imageIds.add(response.data!.imageId);
        } else {
          throw Exception(response.message);
        }
      }

      return imageIds;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("图片上传失败：${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ------------------- 发布文章 -------------------
  Future<void> _publishArticle() async {
    final content = _textController.text.trim();
    
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入内容或添加图片")),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // 1. 先上传图片
      List<String> imageIds = [];
      if (_selectedImages.isNotEmpty) {
        imageIds = await _uploadImages();
      }

      // 2. 创建文章
      final response = await ArticleApi.createArticle(
        title: content.length > 50 ? content.substring(0, 50) : content,
        content: content,
        imageIds: imageIds.isNotEmpty ? imageIds : null,
      );

      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("发布成功")),
        );
        Navigator.of(context).pop(true); // 返回成功标识
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("发布失败：${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  // ------------------- 构建图片网格 -------------------
  Widget _buildImageGrid() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    final crossAxisCount = 3;
    final spacing = 8.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: _selectedImages.length + (_selectedImages.length < 9 ? 1 : 0),
        itemBuilder: (context, index) {
          // 添加按钮
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.grey, size: 32),
              ),
            );
          }

          // 图片项
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImages[index],
                  fit: BoxFit.cover,
                ),
              ),
              // 删除按钮
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发布动态"),
        actions: [
          if (_isPublishing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isUploading ? null : _publishArticle,
              child: const Text(
                "发布",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ------------------- 文本输入区 -------------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    focusNode: _textFocusNode,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "分享你的想法...",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // 图片网格
                  _buildImageGrid(),
                ],
              ),
            ),
          ),

          // ------------------- 底部操作栏 -------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // 添加图片按钮
                IconButton(
                  onPressed: _selectedImages.length >= 9 ? null : _pickImages,
                  icon: const Icon(Icons.photo_library),
                  tooltip: "添加图片",
                ),
                const SizedBox(width: 8),
                // 图片数量提示
                if (_selectedImages.isNotEmpty)
                  Text(
                    "${_selectedImages.length}/9",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                const Spacer(),
                // 上传状态提示
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
