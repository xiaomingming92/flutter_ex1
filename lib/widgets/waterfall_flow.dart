/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-11-13 14:20:00
 * @LastEditors   : xmm wujixmm@gmail.com
 * @LastEditTime  : 2025-11-13 14:20:00
 * @FilePath      : /ex1/lib/widgets/waterfall_flow.dart
 * @Description   : 瀑布流组件
 * 
 */
import 'dart:async';
import 'package:flutter/material.dart';

/// 瀑布流组件
class WaterfallFlow<T> extends StatefulWidget {
  /// 数据列表
  final List<T> items;
  
  /// 构建每个item的widget
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// 获取item的高度（用于布局计算）
  /// 参数：item, columnWidth
  final double Function(T item, double columnWidth)? itemHeightGetter;
  
  /// 列数
  final int crossAxisCount;
  
  /// 列间距
  final double crossAxisSpacing;
  
  /// 行间距
  final double mainAxisSpacing;
  
  /// 滚动控制器
  final ScrollController? scrollController;
  
  /// 触底回调（距离底部多少px触发）
  final VoidCallback? onLoadMore;
  
  /// 触底距离阈值（px）
  final double loadMoreThreshold;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 是否还有更多数据
  final bool hasMore;
  
  /// 骨架屏widget
  final Widget? skeletonBuilder;
  
  /// 空状态widget
  final Widget? emptyBuilder;
  
  /// 错误状态widget
  final Widget? errorBuilder;
  
  /// 是否显示错误
  final bool hasError;

  const WaterfallFlow({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemHeightGetter,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.scrollController,
    this.onLoadMore,
    this.loadMoreThreshold = 100.0,
    this.isLoading = false,
    this.hasMore = true,
    this.skeletonBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.hasError = false,
  });

  @override
  State<WaterfallFlow<T>> createState() => _WaterfallFlowState<T>();
}

class _WaterfallFlowState<T> extends State<WaterfallFlow<T>> {
  late ScrollController _scrollController;
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(WaterfallFlow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController.removeListener(_onScroll);
      _scrollController = widget.scrollController ?? ScrollController();
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 滚动监听，带debounce
  void _onScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      
      final position = _scrollController.position;
      if (!position.hasContentDimensions) return;
      
      final maxScroll = position.maxScrollExtent;
      final currentScroll = position.pixels;
      
      // 检查是否接近底部
      if (currentScroll >= maxScroll - widget.loadMoreThreshold) {
        if (widget.onLoadMore != null && 
            !widget.isLoading && 
            widget.hasMore &&
            !widget.hasError) {
          widget.onLoadMore!();
        }
      }
    });
  }

  /// 分配items到各列
  List<List<T>> _distributeItems() {
    final columns = List.generate(
      widget.crossAxisCount,
      (_) => <T>[],
    );
    
    // 记录每列的总高度
    final columnHeights = List.filled(widget.crossAxisCount, 0.0);
    
    // 分配items到最短的列
    for (final item in widget.items) {
      // 找到最短的列
      int shortestColumn = 0;
      for (int j = 1; j < widget.crossAxisCount; j++) {
        if (columnHeights[j] < columnHeights[shortestColumn]) {
          shortestColumn = j;
        }
      }
      
      columns[shortestColumn].add(item);
      
      // 计算item高度
      double itemHeight = 200.0; // 默认高度
      if (widget.itemHeightGetter != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        final totalSpacing = widget.crossAxisSpacing * (widget.crossAxisCount - 1);
        final columnWidth = (screenWidth - totalSpacing) / widget.crossAxisCount;
        itemHeight = widget.itemHeightGetter!(item, columnWidth);
      }
      
      columnHeights[shortestColumn] += itemHeight + widget.mainAxisSpacing;
    }

    return columns;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasError && widget.items.isEmpty) {
      return widget.errorBuilder ?? 
        const Center(child: Text('加载失败，请重试'));
    }
    
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyBuilder ?? 
        const Center(child: Text('暂无数据'));
    }

    final columns = _distributeItems();
    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = widget.crossAxisSpacing * (widget.crossAxisCount - 1);
    final columnWidth = (screenWidth - totalSpacing) / widget.crossAxisCount;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: widget.crossAxisSpacing / 2),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.crossAxisCount, (columnIndex) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.crossAxisSpacing / 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...columns[columnIndex].asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          // 找到item在原始列表中的索引
                          final originalIndex = widget.items.indexOf(item);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < columns[columnIndex].length - 1
                                  ? widget.mainAxisSpacing
                                  : 0,
                            ),
                            child: widget.itemBuilder(context, item, originalIndex),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        if (widget.isLoading) _buildLoadingIndicator(),
        if (!widget.hasMore && widget.items.isNotEmpty) _buildNoMoreIndicator(),
      ],
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    if (widget.skeletonBuilder != null) {
      return SliverToBoxAdapter(child: widget.skeletonBuilder!);
    }
    
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// 构建没有更多数据指示器
  Widget _buildNoMoreIndicator() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '没有更多数据了',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
