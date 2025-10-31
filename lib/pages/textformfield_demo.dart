import 'package:flutter/material.dart';

class TextFormFieldDemo extends StatefulWidget {
  const TextFormFieldDemo({super.key});

  @override
  State<TextFormFieldDemo> createState() => _TextFormFieldDemoState();
}

class _TextFormFieldDemoState extends State<TextFormFieldDemo> {
  // 创建全局键用于表单验证
  final _formKey = GlobalKey<FormState>();
  
  // 控制器用于获取/设置文本框内容
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    // 释放控制器资源
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 用户名验证函数
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少需要3个字符';
    }
    return null; // 验证通过
  }

  // 密码验证函数
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    return null; // 验证通过
  }

  // 邮箱验证函数
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }
    // 简单的邮箱格式验证
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null; // 验证通过
  }

  // 提交表单
  void _submitForm() {
    // 验证表单
    if (_formKey.currentState!.validate()) {
      // 验证通过，获取输入值
      final String username = _usernameController.text;
      final String password = _passwordController.text;
      final String email = _emailController.text;
      
      // 显示输入内容（实际项目中这里会调用API）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交成功:\n用户名: $username\n邮箱: $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextFormField 与表单验证演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 将表单与全局键关联
          key: _formKey,
          child: Column(
            children: [
              // 用户名输入框（带验证）
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名（至少3个字符）',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                // 设置验证器
                validator: _validateUsername,
              ),
              const SizedBox(height: 16),
              
              // 密码输入框（带验证）
              TextFormField(
                controller: _passwordController,
                obscureText: true, // 隐藏输入
                decoration: const InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码（至少6个字符）',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                // 设置验证器
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              
              // 邮箱输入框（带验证）
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '请输入邮箱地址',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                // 设置验证器
                validator: _validateEmail,
              ),
              const SizedBox(height: 24),
              
              // 提交按钮
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}