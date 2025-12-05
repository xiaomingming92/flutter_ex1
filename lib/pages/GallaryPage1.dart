import 'package:ex1/apis/gallary.dart';
import 'package:ex1/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import "package:ex1/widgets/gallary_operate_banner.dart";

class GallaryPage1 extends StatefulWidget {
  const GallaryPage1({super.key});

  @override
  State<GallaryPage1> createState() => GallaryPage1State();
}

class GallaryPage1State extends State<GallaryPage1> {
  // 这个页面功能:
  // 1. 瀑布流展示,那就是要
  // 1.1 滚动控制
  final ScrollController _scrollerCtl = ScrollController();
  bool _isLoading = false;
  // 1.2 瀑布流单元,能够展示图片, 标题, 点赞数, 评论数, 发布时间,点击可以进入详情页面
  // 1.3 分页加载
  int _currentPage = 1;
  // 2.顶部的非瀑布流展示区,默认有常驻的运营banner, 可以在页面启动后发情网络请求更新数据
  // 2.1 搜索框
  final TextEditingController _searchController = TextEditingController();
  // 2.2 筛选区域
  // 2.3 运营banner
  List activityData = [];
  List<GallaryItem> _items = [];

  static const int _pageSize = 10;
  bool _hasMore = true;
  bool _hasError = false;
  int _crossAxisCount = 2;
  double _imageAspectRatio = 1.5;

  Future<void> _LoadData({bool isLoadMore = false}) async {
    if (!_hasMore || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final int page = isLoadMore ? _currentPage + 1 : 1;
      final newItems = await GallaryApi.getGallaryList(
        page: page,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        if (isLoadMore) {
          _items.addAll(newItems);
          _currentPage = page;
        } else {
          _items = newItems;
          _currentPage = 1;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            action: SnackBarAction(
              label: '重试',
              onPressed: () => _LoadData(isLoadMore: isLoadMore),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchHandler() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片展示')),
      // TODO 规划一个运营banner区域

      // TODO 搜索框
      // TODO 筛选区域
      // TODO 瀑布流展示区域
      body: Column(
        children: [
          // 运营banner区域, 感觉可以新增个组件,2个图片占一行,下面再来个文字描述
          Container(
            height: 100,
            color: Colors.grey[300],
            child: GallaryOperateBannerWidget(),
          ),
          // 搜索框区域
          Container(
            height: 50,
            color: Colors.grey[300],
            child: Row(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "搜索",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchHandler,
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          // 筛选区域
          Container(
            height: 50,
            color: Colors.grey[300],
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_alt),
                        onPressed: _searchHandler,
                      ),
                      Text('筛选'),
                    ],
                  ),
                ),
                FilterWidget(
                  field: 'time',
                  label: '时间',
                  sortStatus: {},
                  onSortChanged: (field) {},
                ),
                FilterWidget(
                  field: 'like',
                  label: '点赞数',
                  sortStatus: {},
                  onSortChanged: (field) {},
                ),
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _searchHandler,
                      ),
                      Text('重置'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 瀑布流展示区域
          Expanded(child: Text('瀑布流展示区域')),
        ],
      ),
    );
  }
}
