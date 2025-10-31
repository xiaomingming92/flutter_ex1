import 'package:flutter/material.dart';

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  // 控制器用于获取/设置文本框内容
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 用于显示输入内容
  String _inputSummary = '';

  @override
  void initState() {
    super.initState();
    // 可以设置初始值
    _usernameController.text = '默认用户名';
    
    // 监听文本变化
    _usernameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 释放控制器资源
    _usernameController.removeListener(_onTextChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _inputSummary = '用户名: ${_usernameController.text}';
    });
  }

  void _submitForm() {
    // 获取所有输入框的值
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    
    // 显示输入内容
    setState(() {
      _inputSummary = '用户名: $username\n密码: $password\n邮箱: $email\n电话: $phone';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField 基础用法演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 基础文本输入框
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            // 密码输入框
            TextField(
              controller: _passwordController,
              obscureText: true, // 隐藏输入
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            
            // 邮箱输入框（指定键盘类型）
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱地址',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            // 电话输入框（指定键盘类型）
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '电话',
                hintText: '请输入电话号码',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),
            
            // 提交按钮
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('提交'),
            ),
            const SizedBox(height: 24),
            
            // 显示输入内容
            Text(
              _inputSummary,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}