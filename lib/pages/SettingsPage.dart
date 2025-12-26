/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:20:00
 * @FilePath     : \ex1\lib\pages\SettingsPage.dart
 * @Description   : 设置页面
 * 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../intent_controller/personal_center_intent_controller.dart';

// 设置项类型枚举
enum SettingType {
  navigation, // 导航到其他页面
  toggle,     // 开关切换
  action,     // 执行动作
  info        // 信息展示
}

// 设置项模型
class SettingItem {
  final String title;
  final String? subtitle;
  final SettingType type;
  final Function()? onTap;
  final Widget? trailing;

  SettingItem({
    required this.title,
    this.subtitle,
    required this.type,
    this.onTap,
    this.trailing,
  });
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PersonalCenterController controller = Get.find<PersonalCenterController>();
  void _handleLogout(){
    controller.handleLogoutIntent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 账号与安全
          _buildSettingSection(
            title: '账号与安全',
            items: [
              SettingItem(
                title: '修改密码',
                subtitle: '修改登录密码',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/accountSecurity'),
              ),
              SettingItem(
                title: '绑定手机',
                subtitle: '绑定或更换手机号',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/accountSecurity'),
              ),
              SettingItem(
                title: '第三方账号绑定',
                subtitle: '绑定微信、QQ等',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/accountSecurity'),
              ),
            ],
          ),
          
          // 通用设置
          _buildSettingSection(
            title: '通用设置',
            items: [
              SettingItem(
                title: '语言设置',
                subtitle: '选择应用语言',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/generalSettings'),
              ),
              SettingItem(
                title: '主题设置',
                subtitle: '切换深色/浅色主题',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/generalSettings'),
              ),
              SettingItem(
                title: '清除缓存',
                subtitle: '清除应用缓存数据',
                type: SettingType.action,
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),
          
          // 通知设置
          _buildSettingSection(
            title: '通知设置',
            items: [
              SettingItem(
                title: '消息通知',
                subtitle: '接收新消息通知',
                type: SettingType.toggle,
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              SettingItem(
                title: '推送通知',
                subtitle: '接收系统推送通知',
                type: SettingType.toggle,
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              SettingItem(
                title: '声音提醒',
                subtitle: '通知时播放声音',
                type: SettingType.toggle,
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          
          // 隐私设置
          _buildSettingSection(
            title: '隐私设置',
            items: [
              SettingItem(
                title: '隐私政策',
                subtitle: '查看隐私政策',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/privacySettings'),
              ),
              SettingItem(
                title: '权限管理',
                subtitle: '管理应用权限',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/privacySettings'),
              ),
              SettingItem(
                title: '清除浏览记录',
                subtitle: '清除应用浏览记录',
                type: SettingType.action,
                onTap: () => _showClearHistoryDialog(context),
              ),
            ],
          ),
          
          // 帮助
          _buildSettingSection(
            title: '帮助',
            items: [
              SettingItem(
                title: '常见问题',
                subtitle: '查看常见问题解答',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/help'),
              ),
              SettingItem(
                title: '联系客服',
                subtitle: '获取在线客服帮助',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/help'),
              ),
              SettingItem(
                title: '意见反馈',
                subtitle: '提交您的意见和建议',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/help'),
              ),
            ],
          ),
          
          // 关于
          _buildSettingSection(
            title: '关于',
            items: [
              SettingItem(
                title: '关于我们',
                subtitle: '了解应用信息',
                type: SettingType.navigation,
                onTap: () => Get.toNamed('/about'),
              ),
              SettingItem(
                title: '版本信息',
                subtitle: '当前版本：1.0.0',
                type: SettingType.info,
              ),
              SettingItem(
                title: '检测版本更新',
                type: SettingType.action,
                onTap: () => Get.toNamed('/about'),
              ),
            ],
          ),
          _buildSettingSection(
            title: '账户操作',
            items: [
              SettingItem(
                title: '退出登录',
                subtitle: '退出当前账户',
                type: SettingType.action,
                onTap: () => _handleLogout(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建设置分组
  Widget _buildSettingSection({
    required String title,
    required List<SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: items
                .map((item) => _buildSettingItem(item))
                .toList()
                .asMap()
                .entries
                .map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == items.length - 1;
                  return Column(
                    children: [
                      item,
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.grey,
                        ),
                    ],
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }

  // 构建单个设置项
  Widget _buildSettingItem(SettingItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (item.trailing != null)
              item.trailing!
            else if (item.type == SettingType.navigation)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  // 显示清除缓存对话框
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？这将删除所有临时数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行清除缓存操作
              Get.snackbar('提示', '缓存清除成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示清除浏览记录对话框
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除浏览记录'),
        content: const Text('确定要清除浏览记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行清除浏览记录操作
              Get.snackbar('提示', '浏览记录清除成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}