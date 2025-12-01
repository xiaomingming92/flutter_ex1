/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2025-10-24 10:18:45
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-11-13 14:40:00
 * @FilePath: /ex1/lib/pages/GalleryPage.dart
 * @Description: 瀑布流页面
 */
import 'package:flutter/material.dart';
import '../apis/gallary.dart';
import '../widgets/waterfall_flow.dart';
import '../widgets/gallery_item_widget.dart';
import '../widgets/gallery_skeleton.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();
  
  // 数据列表
  List<GalleryItem> _items = [];
  
  // 分页相关
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  
  // 列数控制
  int _crossAxisCount = 2;
  
  // 图片宽高比（用于contain显示）
  double _imageAspectRatio = 0.75;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData({bool isLoadMore = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final page = isLoadMore ? _currentPage + 1 : 1;
      final newItems = await GalleryApi.getGalleryList(
        page: page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          _items.addAll(newItems);
          _currentPage = page;
        } else {
          _items = newItems;
          _currentPage = 1;
        }
        
        // 判断是否还有更多数据
        _hasMore = newItems.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            action: SnackBarAction(
              label: '重试',
              onPressed: () => _loadData(isLoadMore: isLoadMore),
            ),
          ),
        );
      }
    }
  }

  /// 加载更多
  void _loadMore() {
    if (_isLoading || !_hasMore) return;
    _loadData(isLoadMore: true);
  }

  /// 计算item高度（用于瀑布流布局）
  double _getItemHeight(GalleryItem item, double columnWidth) {
    // 使用item的宽高比，如果没有则使用默认值
    final aspectRatio = item.width != null && item.height != null && item.height! > 0
        ? item.width! / item.height!
        : _imageAspectRatio;
    
    return columnWidth / aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = 8.0 * (_crossAxisCount - 1);
    final columnWidth = (screenWidth - totalSpacing) / _crossAxisCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
        actions: [
          // 列数控制按钮
          PopupMenuButton<int>(
            icon: const Icon(Icons.view_column),
            onSelected: (value) {
              setState(() {
                _crossAxisCount = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 2, child: Text('2列')),
              const PopupMenuItem(value: 3, child: Text('3列')),
              const PopupMenuItem(value: 4, child: Text('4列')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(isLoadMore: false),
        child: WaterfallFlow<GalleryItem>(
          items: _items,
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          scrollController: _scrollController,
          onLoadMore: _loadMore,
          loadMoreThreshold: 100.0,
          isLoading: _isLoading,
          hasMore: _hasMore,
          hasError: _hasError,
          itemHeightGetter: _getItemHeight,
          skeletonBuilder: GallerySkeleton(
            crossAxisCount: _crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, item, index) {
            return GalleryItemWidget(
              item: item,
              width: columnWidth,
              imageAspectRatio: _imageAspectRatio,
            );
          },
          emptyBuilder: const Center(
            child: Text('暂无数据'),
          ),
          errorBuilder: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('加载失败'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadData(isLoadMore: false),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
