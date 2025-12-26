/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:10:00
 * @FilePath     : \ex1\lib\pages\PersonalCenterPage.dart
 * @Description   : 个人中心页面
 * 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../intent_controller/personal_center_intent_controller.dart';

class PersonalCenterPage extends StatefulWidget {
  const PersonalCenterPage({super.key});

  @override
  State<PersonalCenterPage> createState() => PersonalCenterPageState();
}

class PersonalCenterPageState extends State<PersonalCenterPage> {
  final PersonalCenterController _controller = Get.put(PersonalCenterController());

  @override
  void initState() {
    super.initState();
    // 加载用户信息
    _controller.handleLoadProfileIntent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.handleRefreshProfileIntent(),
        child: Column(
          children: [
            // 个人信息区域 (200dp高度)
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 头像
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      image: _controller.currentUser?.avatar != null
                          ? DecorationImage(
                              image: NetworkImage(_controller.currentUser!.avatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _controller.currentUser?.avatar == null
                        ? const Center(
                            child: Text(
                              '头像',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  // 用户信息 + 统计数据
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _controller.currentUser?.name ?? _controller.currentUser?.username ?? '未知用户',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controller.currentUser?.maskedPhone ?? '未绑定手机',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 统计数据
                        Row(
                          children: [
                            _buildStatItem('帖子', _controller.currentUser?.postCount ?? 0),
                            const SizedBox(width: 24),
                            _buildStatItem('关注', _controller.currentUser?.followingCount ?? 0),
                            const SizedBox(width: 24),
                            _buildStatItem('粉丝', _controller.currentUser?.followerCount ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 操作按钮区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _controller.handleNavigateToEditProfileIntent(),
                      child: const Text('编辑资料'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _controller.handleNavigateToSettingsIntent(),
                      child: const Text('设置'),
                    ),
                  ),
                ],
              ),
            ),
            // UGC 内容列表
            Expanded(
              child: ListView.builder(
                itemCount: _controller.currentUser?.ugcContents?.length ?? 0,
                itemBuilder: (context, index) {
                  final content = _controller.currentUser?.ugcContents?[index];
                  if (content == null) return Container();
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                content.createdAt.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    content.likeCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.comment, size: 16, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    content.commentCount.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}