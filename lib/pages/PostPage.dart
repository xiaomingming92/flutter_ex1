/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2025-10-24 10:18:57
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2025-10-27 15:40:17
 * @FilePath: /ex1/lib/pages/PostPage.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  final int userId;
  const PostPage({
    super.key, 
    required this.userId
  });

  @override
  State<PostPage> createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  late int _userId;
  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("用户id：$_userId")),
      body: Center(
        child: Text("UGC CONTEXT: $_userId said what fancy day")
      )
    );
  }
}