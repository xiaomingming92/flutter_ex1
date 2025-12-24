# ADB WiFi 连接错误解决指南

## 🚨 错误分析

**错误信息：**
```
cannot connect to 192.168.0.209:5555: No connection could be made because the target machine actively refused it. (10061)
```

**问题原因：**
- 手机没有启用WiFi ADB模式
- 手机没有在5555端口监听ADB服务
- 需要先通过USB连接启用tcpip模式

## ✅ 解决步骤

### 步骤1：USB连接手机
```bash
# 使用USB线连接手机到电脑
# 确保在开发者选项中已开启USB调试

adb devices
# 应该显示：
# List of devices attached
# 10AE7Y0G79001QG    device
```

### 步骤2：在手机上启用网络调试
**在Android手机上操作：**
1. 打开 **设置** → **关于手机**
2. 连续点击 **版本号** 7次（启用开发者选项）
3. 返回设置 → **开发者选项**
4. 开启 **USB调试**
5. 开启 **通过网络调试** 或 **Wireless debugging**
6. 记录显示的IP地址和端口

### 步骤3：通过USB启用WiFi ADB
```bash
# 通过USB连接到设备并启用tcpip模式
adb -s 10AE7Y0G79001QG tcpip 5555

# 成功输出应该是：
# restarting in TCP mode port: 5555
```

### 步骤4：断开USB线并连接WiFi ADB
```bash
# 断开USB线
# 然后连接WiFi ADB
adb connect 192.168.0.209:5555

# 成功输出应该是：
# connected to 192.168.0.209:5555
```

### 步骤5：验证连接
```bash
# 查看连接状态
adb devices

# 应该显示：
# List of devices attached
# 192.168.0.209:5555    device
```

## 🔧 详细命令序列

```bash
# 完整的连接序列
adb kill-server
adb start-server
adb devices

# 如果显示设备，进行tcpip模式切换
adb -s 10AE7Y0G79001QG tcpip 5555

# 等待几秒钟，然后断开USB线
sleep 5

# 连接WiFi ADB
adb connect 192.168.0.209:5555

# 验证
adb devices
```

## 🎯 替代方法：使用手机显示的IP

如果手机已经在开发者选项中显示了网络调试IP，可以直接使用：

```bash
# 假设手机显示的IP是192.168.0.209:35515
adb connect 192.168.0.209:35515

# 或者手机显示的端口不同，使用显示的端口
adb connect <手机显示的完整地址>
```

## 🚨 故障排除

### 1. 无法通过USB连接
```bash
# 重启ADB服务
adb kill-server
adb start-server

# 检查USB连接
adb devices -l

# 如果仍然无法识别，检查USB线、驱动等
```

### 2. tcpip命令失败
```bash
# 确保设备ID正确
adb devices

# 使用正确的设备ID
adb -s <设备ID> tcpip 5555

# 或者不使用设备ID（仅连接一个设备时）
adb tcpip 5555
```

### 3. 网络连接问题
```bash
# 测试网络连通性
ping 192.168.0.209

# 检查端口是否开放
telnet 192.168.0.209 5555

# 如果telnet不可用，使用PowerShell
Test-NetConnection -ComputerName 192.168.0.209 -Port 5555
```

### 4. 防火墙阻止
```bash
# 临时关闭防火墙（谨慎使用）
netsh advfirewall set allprofiles state off

# 重新尝试连接
adb connect 192.168.0.209:5555

# 重新启用防火墙
netsh advfirewall set allprofiles state on
```

### 5. 端口被占用
```bash
# 查看端口占用情况
netstat -ano | findstr :5555

# 如果有进程占用，结束该进程
taskkill /PID <进程ID> /F
```

## 🔍 验证工具

### 创建验证脚本 (`check_adb_connection.bat`)
```batch
@echo off
echo ADB Connection Checker
echo ====================

echo 1. Checking ADB server...
adb kill-server
adb start-server
timeout /t 2

echo.
echo 2. Checking USB devices...
adb devices

echo.
echo 3. Testing network connectivity to device...
ping -n 1 192.168.0.209

echo.
echo 4. Attempting WiFi ADB connection...
adb connect 192.168.0.209:5555

echo.
echo 5. Final device list:
adb devices

pause
```

### 实时监控脚本
```bash
# 监控连接状态
watch -n 2 'adb devices'

# 监控网络连接
watch -n 5 'ping -c 1 192.168.0.209'
```

## 📱 不同品牌手机特殊设置

### 华为设备
```bash
# 可能需要额外授权
adb shell pm grant com.android.settings android.permission.WRITE_SECURE_SETTINGS
```

### 小米设备
```bash
# 关闭MIUI优化
adb shell settings put global always_finish_activities 1
```

### OPPO/Vivo设备
```bash
# 关闭应用权限智能管理
adb shell settings put secure adaptive_brightness 0
```

## 🎯 成功标准

连接成功后，你应该看到：
```bash
adb devices
# List of devices attached
# 192.168.0.209:5555    device
```

然后可以正常使用Flutter调试：
```bash
fvm flutter run -d 192.168.0.209:5555
```

## 💡 最佳实践

1. **首次连接必须使用USB**
2. **启用tcpip模式后再断开USB**
3. **确保手机和电脑在同一WiFi网络**
4. **调试完毕后及时断开连接**
5. **定期检查网络稳定性**

按照以上步骤，你应该能够成功建立ADB WiFi连接！