/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-12-26 10:50:00
 * @FilePath      : /ex1/lib/widgets/dialogs/DownloadProgressDialog.dart
 * @Description   : 下载进度对话框
 * 
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadProgressDialog extends StatefulWidget {
  const DownloadProgressDialog({super.key});

  @override
  State<DownloadProgressDialog> createState() => DownloadProgressDialogState();
}

class DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _downloadProgress = 0.0;
  bool _isDownloading = true;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    // 模拟下载过程
    _simulateDownload();
  }

  // 模拟下载过程
  void _simulateDownload() {
    const totalSteps = 100;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = 0; i <= totalSteps; i++) {
      Future.delayed(stepDuration * i, () {
        if (mounted) {
          setState(() {
            _downloadProgress = i / totalSteps;
            if (_downloadProgress >= 1.0) {
              _isDownloading = false;
              _startInstall();
            }
          });
        }
      });
    }
  }

  // 开始安装
  void _startInstall() {
    setState(() {
      _isInstalling = true;
    });

    // 模拟安装过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isInstalling = false;
        });
        // 安装完成，关闭对话框
        Get.back();
        Get.snackbar('提示', '应用已更新完成');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('下载更新'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading)
            Column(
              children: [
                // 下载进度条
                LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                // 下载进度百分比
                Text(
                  '下载进度：${(_downloadProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          else if (_isInstalling)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在安装更新...'),
              ],
            )
          else
            const Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text('下载完成，正在准备安装...'),
              ],
            ),
        ],
      ),
      actions: [
        if (_isDownloading)
          TextButton(
            onPressed: () {
              // 取消下载
              Get.back();
            },
            child: const Text('取消'),
          )
        else
          const SizedBox(),
      ],
    );
  }
}