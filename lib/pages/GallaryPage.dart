/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2025-10-24 10:18:45
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-19 15:48:51
 * @FilePath: \studioProjects\ex1\lib\pages\GallaryPage.dart
 * @Description: 瀑布流页面
 */
import 'package:ex1/widgets/gallary_item_widget2.dart';
import 'package:flutter/material.dart';
import '../apis/gallary.dart';
import '../widgets/waterfall_flow_simple.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();

  // 数据列表
  List<GallaryItem> _items = [];

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
      final newItems = await GallaryApi.getGallaryList(
        page: page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        if (isLoadMore) {
          _items.addAll(newItems.data!.items);
          _currentPage = page;
        } else {
          _items = newItems.data!.items;
          _currentPage = 1;
        }

        // 判断是否还有更多数据
        _hasMore = newItems.data!.items.length >= _pageSize;
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
  double _getItemHeight(GallaryItem item, double columnWidth) {
    // 使用item的宽高比，如果没有则使用默认值
    final aspectRatio =
        item.width != null && item.height != null && item.height! > 0
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
        child: WaterfallFlowSimple(
          items: _items,
          crossAxisCount: _crossAxisCount,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          itemBuilder: (context, item, index) => GallaryItemWidget(
            item: item,
            width: columnWidth,
            imageAspectRatio: _getItemHeight(item, columnWidth),
          ),
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
