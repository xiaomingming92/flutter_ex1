/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:40:00
 * @FilePath      : /ex1/lib/widgets/dialogs/VersionCheckDialog.dart
 * @Description   : 版本检查对话框
 * 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 版本信息模型
class VersionInfo {
  final String versionCode;
  final String versionName;
  final String updateDescription;
  final String downloadUrl;
  final int fileSize;
  final bool isForceUpdate;
  final String minSupportedVersion;

  VersionInfo({
    required this.versionCode,
    required this.versionName,
    required this.updateDescription,
    required this.downloadUrl,
    required this.fileSize,
    required this.isForceUpdate,
    required this.minSupportedVersion,
  });
}

class VersionCheckDialog extends StatefulWidget {
  const VersionCheckDialog({super.key});

  @override
  State<VersionCheckDialog> createState() => VersionCheckDialogState();
}

class VersionCheckDialogState extends State<VersionCheckDialog> {
  bool _isChecking = false;
  bool _hasUpdate = false;
  VersionInfo? _latestVersion;

  @override
  void initState() {
    super.initState();
    // 自动开始检查更新
    _checkForUpdates();
  }

  // 检查更新
  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // 模拟有更新的情况
      setState(() {
        _hasUpdate = true;
        _latestVersion = VersionInfo(
          versionCode: '10001',
          versionName: '1.0.1',
          updateDescription: '1. 修复了一些已知bug\n2. 优化了应用性能\n3. 新增了一些实用功能',
          downloadUrl: 'https://example.com/app-release.apk',
          fileSize: 15728640, // 15MB
          isForceUpdate: false,
          minSupportedVersion: '1.0.0',
        );
      });
    } catch (e) {
      Get.snackbar('错误', '检查更新失败，请稍后重试');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // 开始下载
  void _startDownload() {
    // 显示下载进度对话框
    Get.toNamed('/downloadProgress');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('检查版本更新'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isChecking)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在检查更新...'),
              ],
            )
          else if (_hasUpdate && _latestVersion != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '发现新版本：${_latestVersion!.versionName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '更新内容：',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(_latestVersion!.updateDescription),
                const SizedBox(height: 12),
                Text(
                  '文件大小：${(_latestVersion!.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            )
          else
            const Text('当前已是最新版本'),
        ],
      ),
      actions: [
        if (!_isChecking && _hasUpdate && _latestVersion != null)
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('稍后更新'),
          ),
        if (!_isChecking)
          ElevatedButton(
            onPressed: _isChecking
                ? null
                : _hasUpdate && _latestVersion != null
                    ? _startDownload
                    : () {
                        Get.back();
                      },
            child: Text(
              _isChecking
                  ? '检查中...'
                  : _hasUpdate && _latestVersion != null
                      ? '立即下载'
                      : '确定',
            ),
          ),
      ],
    );
  }
}