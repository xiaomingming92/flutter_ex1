#!/bin/bash

# Flutter 构建脚本 - 简化构建命令
# 用法: ./build.sh <env> [build_type]
# 示例: ./build.sh test debug
#      ./build.sh dev release
# 
# 注意: test 环境在代码中使用 test，但 Android flavor 使用 staging (因为 test 是 Flutter 保留字)

ENV=${1:-dev}
BUILD_TYPE=${2:-debug}

# 环境名到 Android flavor 的映射（test -> staging）
case $ENV in
  test)
    DART_DEFINE_FLAVOR="test"
    ANDROID_FLAVOR="staging"
    ;;
  dev|staging|uat|prod)
    DART_DEFINE_FLAVOR=$ENV
    ANDROID_FLAVOR=$ENV
    ;;
  *)
    echo "错误: 无效的环境 '$ENV'"
    echo "支持的环境: dev, test, staging, uat, prod"
    exit 1
    ;;
esac

# 验证 build_type 是否有效
case $BUILD_TYPE in
  debug|profile|release)
    ;;
  *)
    echo "错误: 无效的构建类型 '$BUILD_TYPE'"
    echo "支持的构建类型: debug, profile, release"
    exit 1
    ;;
esac

# 构建命令
echo "构建配置: env=$ENV (dart-define=$DART_DEFINE_FLAVOR, flavor=$ANDROID_FLAVOR), build_type=$BUILD_TYPE"
fvm flutter build apk \
  --$BUILD_TYPE \
  --dart-define=FLAVOR=$DART_DEFINE_FLAVOR \
  --flavor=$ANDROID_FLAVOR

