/*
 * @Author        : xmm wujixmm@gmail.com
 * @Date          : 2025-10-28 15:24:07
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2025-12-26 16:56:37
 * @FilePath     : \ex1\lib\pages\LoginPage.dart
 * @Description   : 登录页
 * 
 */

import 'package:flutter/material.dart';
import '../apis/index.dart';
import 'package:get/get.dart';
import '../intent_controller/auth_intent_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static Future doLogin() async {
    await UserApi.getUserInfo();
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordLogin = false;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authIntentController = Get.find<AuthIntentController>();
  bool _isLoading = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_countdown <= 0) return false;
      setState(() {
        _countdown--;
      });
      return _countdown > 0;
    });
  }

  Future<void> _handleSendCode() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar('提示', '请输入手机号');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authIntentController.handleSendCodeIntent(_phoneController.text);
      _startCountdown();
      Get.snackbar('成功', '验证码已发送');
    } catch (e) {
      Get.snackbar('错误', '发送验证码失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar('提示', '请输入手机号');
      return;
    }
    
    if (_isPasswordLogin) {
      if (_passwordController.text.isEmpty) {
        Get.snackbar('提示', '请输入密码');
        return;
      }
    } else {
      if (_codeController.text.isEmpty) {
        Get.snackbar('提示', '请输入验证码');
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isPasswordLogin) {
        await _authIntentController.handleLoginIntent(
          _phoneController.text,
          _passwordController.text,
        );
      } else {
        await _authIntentController.handleSmsLoginIntent(
          _phoneController.text,
          _codeController.text,
        );
      }
    } catch (e) {
      Get.snackbar('错误', '登录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('欢迎来到', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('ex1', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isPasswordLogin ? '密码登录' : '短信登录',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isPasswordLogin)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '验证码',
                          hintText: '请输入验证码',
                          prefixIcon: Icon(Icons.verified_user),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _countdown > 0 || _isLoading ? null : _handleSendCode,
                        child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.sync_alt_outlined),
                  label: Text(
                    _isPasswordLogin ? '切换到短信登录' : '切换到密码登录',
                    style: const TextStyle(color: Colors.blue),
                  ),
                   onPressed: () {
                    setState(() {
                      _isPasswordLogin = !_isPasswordLogin;
                    });
                  },
                )
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_isPasswordLogin ? '登录' : '登录/注册'),
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                '首次登录将自动注册',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
