/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-03
 * @Description   : 瀑布流组件 - 简化版（初学者友好）
 * 核心功能：
 * 1. 将数据分配到多列（最短的列优先）
 * 2. 使用 CustomScrollView 实现垂直滚动
 * 3. 支持触底自动加载更多
 * 
 */
import 'package:flutter/material.dart';

/// 瀑布流简化版 - 适合初学者
class WaterfallFlowSimple<T> extends StatefulWidget {
  /// 数据列表
  final List<T> items;

  /// 构建每个 item 的 widget
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 列数（默认2列）
  final int crossAxisCount;

  /// 列间距
  final double crossAxisSpacing;

  /// 行间距
  final double mainAxisSpacing;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 触底加载更多的回调
  final VoidCallback? onLoadMore;

  /// 触底阈值（距离底部多少 px 时触发加载）
  final double loadMoreThreshold;

  /// 是否正在加载
  final bool isLoading;

  const WaterfallFlowSimple({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.scrollController,
    this.onLoadMore,
    this.loadMoreThreshold = 100.0,
    this.isLoading = false,
  });

  @override
  State<WaterfallFlowSimple<T>> createState() => _WaterfallFlowSimpleState<T>();
}

class _WaterfallFlowSimpleState<T> extends State<WaterfallFlowSimple<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 使用传入的滚动控制器，或创建一个新的
    _scrollController = widget.scrollController ?? ScrollController();
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 移除监听
    _scrollController.removeListener(_onScroll);
    // 如果是自己创建的控制器，需要释放资源
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// 滚动监听函数
  /// 检查是否滚动到了底部附近，如果是则触发加载更多
  void _onScroll() {
    // 获取滚动位置信息
    final position = _scrollController.position;

    // maxScrollExtent: 最大可滚动距离（内容总高度 - 视口高度）
    // pixels: 当前滚动距离
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // 判断是否接近底部：当前滚动距离 >= (最大距离 - 阈值)
    if (currentScroll >= maxScroll - widget.loadMoreThreshold) {
      // 触发加载更多，且确保不在加载中
      if (widget.onLoadMore != null && !widget.isLoading) {
        widget.onLoadMore!();
      }
    }
  }

  /// 将 items 分配到各列
  /// 返回一个二维列表，每个子列表代表一列的数据
  List<List<T>> _distributeItems() {
    // 创建多个空列表，数量等于列数
    final columns = List.generate(widget.crossAxisCount, (_) => <T>[]);

    // 记录每列已有的 items 数量（用于分配）
    final columnItemCounts = List.filled(widget.crossAxisCount, 0);

    // 遍历所有 items，分配到最少的列
    for (final item in widget.items) {
      // 找到 items 数量最少的列
      int shortestColumn = 0;
      for (int j = 1; j < widget.crossAxisCount; j++) {
        if (columnItemCounts[j] < columnItemCounts[shortestColumn]) {
          shortestColumn = j;
        }
      }

      // 将 item 添加到最短的列
      columns[shortestColumn].add(item);
      columnItemCounts[shortestColumn]++;
    }

    return columns;
  }

  @override
  Widget build(BuildContext context) {
    // 如果数据为空，显示空状态
    if (widget.items.isEmpty && !widget.isLoading) {
      return const Center(child: Text('暂无数据'));
    }

    // 分配 items 到各列
    final columns = _distributeItems();

    // 使用 CustomScrollView 实现复杂滚动效果
    // 对比 ListView：更灵活，支持 sliver 组件（SliverAppBar、SliverPadding 等）
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // SliverPadding: 给所有 sliver 子组件添加外边距
        SliverPadding(
          padding: EdgeInsets.all(widget.crossAxisSpacing / 2),
          sliver: SliverToBoxAdapter(
            // 使用 Row 并排放置多个 Column（每个代表一列瀑布流）
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.crossAxisCount, (columnIndex) {
                // Expanded 使每列占据相等的宽度
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.crossAxisSpacing / 2,
                    ),
                    // 每列都是一个 Column，包含该列的所有 items
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 遍历该列的所有 items，构建 UI
                        ...columns[columnIndex].asMap().entries.map((entry) {
                          final itemIndex = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(
                              // 非最后一个 item 才添加下边距
                              bottom:
                                  itemIndex < columns[columnIndex].length - 1
                                  ? widget.mainAxisSpacing
                                  : 0,
                            ),
                            child: widget.itemBuilder(
                              context,
                              item,
                              widget.items.indexOf(item), // 原始列表中的索引
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // 加载中时显示加载指示器
        if (widget.isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
