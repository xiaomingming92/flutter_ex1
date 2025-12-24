# ADB WiFi 连接完整指南

## 📋 当前环境状态

**ADB版本信息：**
- Android Debug Bridge version 1.0.41
- Version 36.0.0-13206524
- 安装路径：D:\Android\Sdk\platform-tools\adb.exe

**当前连接的设备：**
- 10AE7Y0G79001QG device (真机设备)
- emulator-5554 device (模拟器)

## 🔧 ADB WiFi连接方法

### 方法1：通过USB启用WiFi ADB（推荐）

#### 步骤1：USB连接并授权
```bash
# 1. 使用USB线连接手机到电脑
# 2. 检查设备连接状态
adb devices

# 应该显示类似：
# List of devices attached
# 10AE7Y0G79001QG    device
```

#### 步骤2：在手机上启用网络调试
**在Android设备上：**
1. 进入 **设置** → **开发者选项**
2. 找到 **网络调试** 或 **Wireless debugging**
3. 开启 **网络调试** 选项
4. 记录显示的 **IP和端口**（通常是手机IP:5555）

#### 步骤3：通过USB启用WiFi ADB
```bash
# 通过USB连接到设备
adb -s 10AE7Y0G79001QG tcpip 5555

# 成功输出：
# restarting in TCP mode port: 5555
```

#### 步骤4：连接到WiFi ADB
```bash
# 断开USB线后，连接WiFi ADB
adb connect 192.168.0.210:5555

# 验证连接
adb devices

# 应该显示：
# List of devices attached
# 192.168.0.210:5555    device
```

### 方法2：直接连接（如果已启用网络调试）

如果手机已经启用了网络调试（显示IP地址），可以直接连接：
```bash
# 直接连接
adb connect <手机IP地址>:5555

# 例如：
adb connect 192.168.1.100:5555

# 查看连接状态
adb devices -l
```

## 🔍 常用ADB WiFi命令

### 设备连接管理
```bash
# 查看所有连接的设备
adb devices

# 查看详细设备信息
adb devices -l

# 连接到特定设备的WiFi ADB
adb -s <设备ID> connect <IP地址>:5555

# 断开WiFi ADB连接
adb disconnect <IP地址>:5555

# 断开所有设备
adb disconnect
```

### 设备操作命令
```bash
# 安装应用到设备
adb -s <设备ID> install app.apk

# 卸载应用
adb -s <设备ID> uninstall com.example.app

# 推送文件到设备
adb -s <设备ID> push local_file.txt /sdcard/

# 从设备拉取文件
adb -s <设备ID> pull /sdcard/remote_file.txt ./

# 查看设备日志
adb -s <设备ID> logcat

# 进入设备shell
adb -s <设备ID> shell
```

### Flutter专用命令
```bash
# 列出可用设备（Flutter）
fvm flutter devices

# 在WiFi设备上运行Flutter应用
fvm flutter run -d 192.168.0.210:5555

# 在指定WiFi设备上调试
fvm flutter run -d 192.168.0.210:5555 --release
```

## 🚨 故障排除

### 常见问题及解决方案

#### 1. 无法连接到WiFi ADB
**问题现象：**
```
unable to connect to 192.168.0.210:5555: Connection refused
```

**解决方案：**
```bash
# 检查网络连接
ping 192.168.0.210

# 确保端口开放
telnet 192.168.0.210 5555

# 重启ADB服务
adb kill-server
adb start-server

# 重新连接USB并启用tcpip模式
adb tcpip 5555
```

#### 2. 设备授权问题
**问题现象：**
```
unauthorized
```

**解决方案：**
```bash
# 重新连接USB
adb usb

# 重新授权设备
adb tcpip 5555

# 重新连接WiFi
adb connect <设备IP>:5555
```

#### 3. 网络连接不稳定
**问题现象：**
```
device offline
```

**解决方案：**
```bash
# 检查WiFi连接状态
adb -s <设备ID> shell getprop sys.connected_network

# 重启网络调试
adb -s <设备ID> usb
adb -s <设备ID> tcpip 5555
adb connect <设备IP>:5555
```

#### 4. 端口被占用
**问题现象：**
```
cannot bind: Address already in use
```

**解决方案：**
```bash
# 查看端口占用
netstat -ano | findstr :5555

# 杀死占用进程
taskkill /PID <进程ID> /F

# 使用其他端口
adb tcpip 5556
adb connect <设备IP>:5556
```

## 🔐 安全设置

### 防火墙配置
```bash
# Windows防火墙设置
# 允许adb.exe通过防火墙

# 或者临时关闭防火墙（不推荐）
netsh advfirewall set allprofiles state off
```

### 网络安全建议
1. **仅在受信任网络中使用**
2. **调试完毕后及时断开**
3. **定期更改WiFi密码**
4. **不要在公共WiFi使用WiFi ADB**

## 📱 设备特定配置

### 华为设备特殊设置
```bash
# 华为设备需要额外授权
adb shell pm grant com.huawei.systemmanager android.permission.SYSTEM_ALERT_WINDOW
```

### 小米设备特殊设置
```bash
# 小米设备需要关闭优化
adb shell settings put global always_finish_activities 1
```

### OPPO/Vivo设备特殊设置
```bash
# 这些品牌需要关闭应用权限智能管理
adb shell settings put secure adaptive_brightness 0
```

## 🎯 高级技巧

### 多设备WiFi ADB管理
```bash
# 连接多台设备
adb connect 192.168.1.100:5555
adb connect 192.168.1.101:5555

# 指定设备执行命令
adb -s 192.168.1.100:5555 install app.apk

# 查看所有WiFi设备
adb devices | grep :5555
```

### 自动化脚本

**WiFi ADB连接脚本** (`wifi_adb_connect.bat`)：
```batch
@echo off
echo ADB WiFi Connection Tool
echo =======================

echo Current devices:
adb devices

echo.
set /p DEVICE_IP="Enter device IP: "
set /p PORT="Enter port (default 5555): "

if "%PORT%"=="" set PORT=5555

echo Connecting to %DEVICE_IP%:%PORT%...
adb connect %DEVICE_IP%:%PORT%

echo.
echo Updated device list:
adb devices

pause
```

### 性能优化
```bash
# 使用WiFi ADB时的优化选项
adb -s <设备ID> shell settings put global window_animation_scale 0
adb -s <设备ID> shell settings put global transition_animation_scale 0
adb -s <设备ID> shell settings put global animator_duration_scale 0
```

## 📊 连接状态监控

### 实时监控
```bash
# 实时查看设备连接状态
watch -n 1 adb devices

# 监控网络连接
ping -t 192.168.0.210

# 查看ADB连接日志
adb logcat | grep -i "adb\|connection"
```

### 连接质量测试
```bash
# 测试延迟
ping -c 10 192.168.0.210

# 测试传输速度
adb -s 192.168.0.210:5555 shell dd if=/dev/zero of=/dev/null bs=1M count=100
```

通过以上方法，你可以轻松实现ADB WiFi连接，特别适合无线调试和真机测试场景！