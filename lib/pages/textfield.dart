/*
 * @Author       : wujixmm
 * @Date         : 2025-11-10 22:05:00
 * @LastEditors  : wujixmm wujixmm@gmail.com
 * @LastEditTime : 2025-11-12 15:18:45
 * @FilePath     : /ex1/lib/pages/textfield.dart
 * @Description  : 测试textfield
 * 
 */
import "package:flutter/material.dart";

class TextFieldPr extends StatefulWidget {
  const TextFieldPr({super.key});

  @override
  State<TextFieldPr> createState() => _TextFieldPrState();
}

class _TextFieldPrState extends State<TextFieldPr> {
  // 控制器
  final TextEditingController _userNameCtler = TextEditingController();
  final TextEditingController _passwdCtler = TextEditingController();
  final TextEditingController _emailCtler = TextEditingController();
  final TextEditingController _phoneCtler = TextEditingController();

  // textField change 回调展示
  String _inputSummary = '';
  // init
  @override
  void initState() {
    super.initState();
    _userNameCtler.text = 'user';
    _userNameCtler.addListener(_userNameChange);
  }

  @override
  void dispose() {
    super.dispose();
    _userNameCtler.removeListener(_userNameChange);
    _userNameCtler.dispose();
    _passwdCtler.dispose();
    _emailCtler.dispose();
    _phoneCtler.dispose();
  }

  // 监听用户名输入框的输入
  _userNameChange() {
    setState(() {
      _inputSummary = "用户名：${_userNameCtler.text}";
    });
    setState(() => _inputSummary = "用户名：${_userNameCtler.text}");
  }

  // 提交
  _submit() {
    final String username = _userNameCtler.text;
    final String passwd = _passwdCtler.text;
    final String email = _emailCtler.text;
    final String phone = _phoneCtler.text;
    setState(() {
      _inputSummary = '用户名：$username\n密码：$passwd\n邮箱：$email\n电话：$phone';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Textfield")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userNameCtler,
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwdCtler,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "密码",
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailCtler,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "邮箱",
                hintText: "请输入邮箱地址",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneCtler,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '电话',
                hintText: "请输入电话号码",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            ElevatedButton(onPressed: _submit, child: Text("提交")),
            SizedBox(height: 24),
            Text(_inputSummary, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
