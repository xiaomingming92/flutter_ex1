import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldAdvancedDemo extends StatefulWidget {
  const TextFieldAdvancedDemo({super.key});

  @override
  State<TextFieldAdvancedDemo> createState() => _TextFieldAdvancedDemoState();
}

class _TextFieldAdvancedDemoState extends State<TextFieldAdvancedDemo> {
  // 控制器用于获取/设置文本框内容
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _firstFieldController = TextEditingController();
  final TextEditingController _secondFieldController = TextEditingController();
  
  // 焦点节点用于控制焦点
  final FocusNode _firstFieldFocusNode = FocusNode();
  final FocusNode _secondFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // 监听第一个输入框的焦点变化
    _firstFieldFocusNode.addListener(() {
      if (!_firstFieldFocusNode.hasFocus) {
        // 失去焦点时执行操作
        print('第一个输入框失去焦点');
      }
    });
    
    // 监听第二个输入框的焦点变化
    _secondFieldFocusNode.addListener(() {
      if (_secondFieldFocusNode.hasFocus) {
        // 获得焦点时执行操作
        print('第二个输入框获得焦点');
      }
    });
  }

  @override
  void dispose() {
    // 释放控制器和焦点节点资源
    _phoneController.dispose();
    _amountController.dispose();
    _firstFieldController.dispose();
    _secondFieldController.dispose();
    _firstFieldFocusNode.dispose();
    _secondFieldFocusNode.dispose();
    super.dispose();
  }

  // 格式化电话号码输入 (例如: 123-4567-8901)
  void _formatPhoneInput(String value) {
    // 移除所有非数字字符
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // 根据长度添加分隔符
    String formatted = '';
    if (digits.length >= 3) {
      formatted += '${digits.substring(0, 3)}-';
    } else {
      formatted += digits;
    }
    
    if (digits.length >= 7) {
      formatted += '${digits.substring(3, 7)}-';
    } else if (digits.length > 3) {
      formatted += digits.substring(3);
    }
    
    if (digits.length > 7) {
      formatted += digits.substring(7, digits.length.clamp(0, 11));
    }
    
    // 更新控制器文本，同时保持光标位置
    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // 格式化金额输入 (例如: 1,000.00)
  void _formatAmountInput(String value) {
    // 移除所有非数字字符
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // 转换为数字并格式化
    if (digits.isEmpty) {
      _amountController.text = '';
      return;
    }
    
    final int amount = int.parse(digits);
    final String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    // 更新控制器文本，同时保持光标位置
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField 高级功能演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '输入格式限制示例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 电话号码输入框（带格式化）
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                // 限制只能输入数字
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: '电话号码',
                hintText: '请输入电话号码，自动格式化为 XXX-XXXX-XXXX',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              onChanged: _formatPhoneInput,
            ),
            const SizedBox(height: 16),
            
            // 金额输入框（带格式化）
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // 限制只能输入数字和小数点
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: '金额',
                hintText: '请输入金额，自动格式化为 1,000.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              onChanged: _formatAmountInput,
            ),
            const SizedBox(height: 32),
            
            const Text(
              '焦点控制示例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 第一个输入框
            TextField(
              controller: _firstFieldController,
              focusNode: _firstFieldFocusNode,
              decoration: const InputDecoration(
                labelText: '第一个输入框',
                hintText: '输入完成后自动跳转到第二个输入框',
                border: OutlineInputBorder(),
              ),
              onEditingComplete: () {
                // 当用户点击键盘的完成按钮时，将焦点转移到第二个输入框
                FocusScope.of(context).requestFocus(_secondFieldFocusNode);
              },
            ),
            const SizedBox(height: 16),
            
            // 第二个输入框
            TextField(
              controller: _secondFieldController,
              focusNode: _secondFieldFocusNode,
              decoration: const InputDecoration(
                labelText: '第二个输入框',
                hintText: '监听焦点变化',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            
            // 按钮用于手动控制焦点
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 将焦点设置到第一个输入框
                    FocusScope.of(context).requestFocus(_firstFieldFocusNode);
                  },
                  child: const Text('聚焦第一个输入框'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 将焦点设置到第二个输入框
                    FocusScope.of(context).requestFocus(_secondFieldFocusNode);
                  },
                  child: const Text('聚焦第二个输入框'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 取消所有焦点
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('取消焦点'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}