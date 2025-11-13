/*
 * @Author       : wujixmm
 * @Date         : 2025-11-12 08:40:06
 * @LastEditors  : wujixmm wujixmm@gmail.com
 * @LastEditTime : 2025-11-13 13:44:52
 * @FilePath     : /ex1/lib/pages/textfield_advanced.dart
 * @Description  : 
 * 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextfieldAdvanced extends StatefulWidget {
  const TextfieldAdvanced({super.key});

  @override
  State<TextfieldAdvanced> createState() => _TextfieldAdvancedState();
}

class _TextfieldAdvancedState extends State<TextfieldAdvanced> {
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _amountCtl = TextEditingController();
  final TextEditingController _firstCtl = TextEditingController();
  final TextEditingController _secCtl = TextEditingController();

  // 焦点控制
  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstFocusNode.addListener(() {
      if (!_firstFocusNode.hasFocus) {
        print("第一个输入框失去焦点");
      }
    });
    _secFocusNode.addListener(() {
      if (!_secFocusNode.hasFocus) {
        print("第二个输入框失去焦点");
      }
    });
  }

  @override
  void dispose() {
    // 释放控制器、聚焦节点的资源
    _phoneCtl.dispose();
    _amountCtl.dispose();
    _firstCtl.dispose();
    _secCtl.dispose();
    _firstFocusNode.dispose();
    _secFocusNode.dispose();
    super.dispose(); // 最后调
  }

  void _formatPhoneInput(String val) {
    // 正则匹配非数字进行替换
    final String digits = val.replaceAll(RegExp(r'\D'), '');
    String formated = '';

    if (digits.length >= 3) {
      formated += '${digits.substring(0, 3)}-';
    } else {
      formated += digits;
    }
    if (digits.length >= 7) {
      formated += '${digits.substring(3, 7)}-';
    } else {
      formated += digits;
    }
    if (digits.length > 7) {
      formated += digits.substring(7, digits.length.clamp(0, 11));
    }
    _phoneCtl.value = TextEditingValue(
      text: formated,
      selection: TextSelection.collapsed(offset: formated.length),
    );
  }

  void _formateAmountInput(String val) {
    final String digits = val.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _amountCtl.text = '';
    }
    final int amount = int.parse(digits);
    final String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    _amountCtl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TextField 高级功能")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "输入格式化",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountCtl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                labelText: '金额',
                hintText: "金额会自动格式化",
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
              onChanged: _formateAmountInput,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneCtl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "电话",
                hintText: '请输入电话号码',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              onChanged: _formatPhoneInput,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _firstCtl,
              focusNode: _firstFocusNode,
              decoration: InputDecoration(
                labelText: '第一个输入框',
                hintText: "输入完成后自动跳转第二个输入框",
                border: OutlineInputBorder(),
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_secFocusNode);
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _secCtl,
              focusNode: _secFocusNode,
              decoration: InputDecoration(
                labelText: '第二个输入框',
                hintText: "监听焦点变化",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(_firstFocusNode);
                  },
                  child: Text("聚焦第一个输入框"),
                ),
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(_secFocusNode);
                  },
                  child: Text("聚焦到第二个输入框"),
                ),
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Text('取消所有焦点'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
