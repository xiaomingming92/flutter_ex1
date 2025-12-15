#!/bin/bash

# 生成符合应用商城要求的签名证书
# 请替换以下变量为真实的开发者信息

KEYSTORE_PATH="android/app/distribution.keystore"
ALIAS_NAME="your_alias"
STORE_PASSWORD="your_store_password"
KEY_PASSWORD="your_key_password"

# 应用商城要求的DName信息
# CN: 公司名称/个人开发者名称
# OU: 部门名称（可选）
# O: 组织名称（必须与开发者账号一致）
# L: 城市名称
# ST: 省份/直辖市
# C: 国家代码（如CN代表中国）
DNAME="CN=Your Company Name, OU=Your Department, O=Your Organization Name, L=Your City, ST=Your Province, C=CN"

# 生成证书（RSA 2048位，有效期25年）
keytool -genkey -v -keystore $KEYSTORE_PATH -alias $ALIAS_NAME -keyalg RSA -keysize 2048 -validity 9125 -storepass $STORE_PASSWORD -keypass $KEY_PASSWORD -dname "$DNAME"

# 显示证书信息
keytool -list -v -keystore $KEYSTORE_PATH -alias $ALIAS_NAME -storepass $STORE_PASSWORD

echo "\n证书已生成，路径：$KEYSTORE_PATH"
echo "请将此证书用于应用商城发布！"