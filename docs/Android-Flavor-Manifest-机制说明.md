# Android Flavor Manifest 合并机制说明

## 工作原理

Android Gradle Plugin 使用 **Source Sets (源码集)** 机制来管理不同 flavor 和 buildType 的资源文件。

### 1. 目录结构规则

当你在 `build.gradle.kts` 中定义了 productFlavors：

```kotlin
productFlavors {
    create("dev") { ... }
    create("staging") { ... }
    create("uat") { ... }
    create("prod") { ... }
}
```

Android Gradle Plugin 会自动识别以下目录结构：

```
android/app/src/
├── main/                          # 主源码集（所有 flavor 共享）
│   └── AndroidManifest.xml        # 基础 manifest
├── dev/                           # dev flavor 源码集
│   └── AndroidManifest.xml        # dev 特定配置
├── staging/                       # staging flavor 源码集
│   └── AndroidManifest.xml        # staging 特定配置
├── uat/                           # uat flavor 源码集
│   └── AndroidManifest.xml        # uat 特定配置
├── prod/                          # prod flavor 源码集
│   └── AndroidManifest.xml        # prod 特定配置
└── debug/                         # debug buildType 源码集
    └── AndroidManifest.xml        # debug 特定配置
```

### 2. Manifest 合并优先级（从低到高）

当执行构建时，Android Gradle Plugin 会按照以下顺序合并 manifest：

1. **main/AndroidManifest.xml** (基础 manifest)
2. **flavor/AndroidManifest.xml** (productFlavor 的 manifest，如 dev、staging)
3. **buildType/AndroidManifest.xml** (buildType 的 manifest，如 debug、release)
4. **flavorBuildType/AndroidManifest.xml** (如果存在，如 devDebug)

**重要：** 后加载的 manifest 会**覆盖**或**合并**前面加载的配置。

### 3. 合并规则

#### 覆盖规则：
- 如果同一属性在不同 manifest 中定义，**优先级高的会覆盖优先级低的**
- 例如：`main/AndroidManifest.xml` 没有 `usesCleartextTraffic`，而 `staging/AndroidManifest.xml` 有 `usesCleartextTraffic="true"`，最终会使用 `true`

#### 合并规则：
- 新的元素会被**添加**到结果中
- 例如：main 有 `<uses-permission android:name="android.permission.INTERNET" />`，flavor 也有其他权限，最终会包含所有权限

### 4. 实际构建示例

#### 示例 1：构建 `stagingDebug`
```
构建命令: flutter build apk --flavor=staging --debug

合并顺序:
1. main/AndroidManifest.xml          (基础配置)
   └── 包含所有权限、Activity 等基础配置
   
2. staging/AndroidManifest.xml       (staging flavor)
   └── <application android:usesCleartextTraffic="true" />
   
3. debug/AndroidManifest.xml         (debug buildType)
   └── (如果有 debug 特定配置)

最终结果:
- 包含 main 中的所有配置
- application 标签的 usesCleartextTraffic="true" (来自 staging)
```

#### 示例 2：构建 `prodRelease`
```
构建命令: flutter build apk --flavor=prod --release

合并顺序:
1. main/AndroidManifest.xml          (基础配置)
   └── 包含所有权限、Activity 等基础配置
   
2. prod/AndroidManifest.xml          (prod flavor)
   └── <application android:usesCleartextTraffic="false" />
   
3. release/AndroidManifest.xml       (release buildType，如果存在)

最终结果:
- 包含 main 中的所有配置
- application 标签的 usesCleartextTraffic="false" (来自 prod)
```

### 5. 为什么这样设计？

#### 优点：
1. **无需代码逻辑**：完全通过文件系统组织，不需要在代码中判断
2. **类型安全**：编译时就能发现配置错误
3. **易于维护**：每个环境的配置独立管理
4. **标准做法**：这是 Android 官方推荐的配置方式

#### 与传统方式对比：
```kotlin
// ❌ 不推荐：在代码中判断（硬编码）
if (BuildConfig.FLAVOR == "staging") {
    // 允许 HTTP
} else {
    // 不允许 HTTP
}

// ✅ 推荐：通过 manifest 配置（声明式）
// staging/AndroidManifest.xml
<application android:usesCleartextTraffic="true" />
```

### 6. Source Sets 自动识别

Android Gradle Plugin **自动**识别目录结构，**不需要手动配置** sourceSets（除非有特殊需求）。

Gradle 会根据以下规则自动创建 source sets：
- `src/{flavorName}/` → productFlavor source set
- `src/{buildType}/` → buildType source set
- `src/{flavorName}{buildType}/` → 组合 source set（如 devDebug）

### 7. 验证合并结果

如果想查看最终合并后的 manifest，可以在构建后查看：

```bash
# 构建后，在以下路径查看合并后的 manifest
app/build/intermediates/merged_manifests/{flavor}{buildType}/AndroidManifest.xml
```

例如：
- `app/build/intermediates/merged_manifests/stagingDebug/AndroidManifest.xml`
- `app/build/intermediates/merged_manifests/prodRelease/AndroidManifest.xml`

## 总结

1. **Android Gradle Plugin 自动处理**：你只需要按照目录结构放置文件
2. **合并是自动的**：按照优先级自动合并，无需手动干预
3. **声明式配置**：通过文件组织配置，而不是代码逻辑
4. **这是标准做法**：Android 官方推荐的配置管理方式

