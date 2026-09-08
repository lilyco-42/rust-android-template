<div align="center">
  <img src="docs/banner.svg" width="720" alt="banner">
</div>

# Rust + Kotlin Android 项目模板

[![Rust](https://img.shields.io/badge/Rust-1.96+-orange?logo=rust)](https://www.rust-lang.org/)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.x-purple?logo=kotlin)](https://kotlinlang.org/)
[![Compose](https://img.shields.io/badge/Jetpack%20Compose-latest-blue?logo=jetpackcompose)](https://developer.android.com/compose)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

开箱即用的 Rust + Kotlin Android 项目模板。Rust 编译为 `.so` 动态库，通过 JNI 桥接到 Jetpack Compose UI。

## 特性

- ✅ **零硬编码路径** — 使用 Gradle wrapper + cargo-ndk，无需配置绝对路径
- ✅ **JNI 容错** — Native 库加载失败自动降级 Kotlin fallback，应用不闪退
- ✅ **体积优化** — R8 + ABI 拆分 + Rust LTO 三件套，Release APK 仅 ~4MB
- ✅ **跨平台构建** — Windows/macOS/Linux 均可构建
- ✅ **即装即用** — clone → 替换包名 → `./gradlew assembleRelease`

## 快速开始

### 前置条件

```bash
# Rust + Android 目标
rustup target add aarch64-linux-android armv7-linux-androideabi
cargo install cargo-ndk

# JDK 17（不要用 21+）
# Windows: scoop install openjdk17
# macOS:   brew install openjdk@17

# Android SDK (确保 Build-Tools ≥36)
```

### 1. 创建你的项目

```bash
git clone https://github.com/lilyco-42/rust-android-template.git my-app
cd my-app
```

### 2. 替换包名

全局搜索替换 `com.example.app` → 你的包名：

```bash
# 文件系统中的目录
mv app/src/main/java/com/example/app app/src/main/java/com/<你的包名>

# 源码中的包名声明（Java/Kotlin）
# 搜索: com.example.app → 你的包名
```

Rust 侧的 JNI 函数名也需同步：
```rust
// native_lib/src/lib.rs
// com_example_app → 你的包名（. 换成 _）
Java_com_example_app_NativeLib_nativeGreet
```

ProGuard 规则：
```
# app/proguard-rules.pro
-keep class <你的包名>.NativeLib { native <methods>; }
```

`app/build.gradle.kts`：
```kotlin
namespace = "你的包名"
applicationId = "你的包名"
```

### 3. 编译 Rust → .so

```bash
cd native_lib
cargo ndk \
  --target aarch64-linux-android \
  --target armv7-linux-androideabi \
  --platform 24 \
  -- build --release

# .so 输出在 native_lib/target/<target>/release/libnative_lib.so
```

### 4. 构建 APK

```bash
# macOS/Linux
./gradlew assembleRelease

# Windows
gradlew.bat assembleRelease
```

### 5. 安装到设备

```bash
# Wi-Fi (Android 11+)
adb pair <ip>:<配对端口> <配对码>
adb connect <ip>:<连接端口>
adb install -r app/build/outputs/apk/release/app-arm64-v8a-release-unsigned.apk

# USB
adb install -r app/build/outputs/apk/release/app-arm64-v8a-release-unsigned.apk
```

## 项目结构

```
rust-android-template/
├── native_lib/                        # Rust 原生库
│   ├── Cargo.toml                     # cdylib + jni 0.22 + release profile
│   └── src/lib.rs                     # JNI 函数实现
├── app/                               # Android 应用
│   ├── build.gradle.kts               # AGP + Compose + R8 + ABI 拆分
│   ├── proguard-rules.pro             # JNI/Compose 保护规则
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/example/app/
│       │   ├── MainActivity.kt        # 入口
│       │   ├── NativeLib.kt           # JNI 桥接（含 fallback）
│       │   ├── Theme.kt               # Material3 主题
│       │   └── ui/MainScreen.kt       # Compose UI
│       ├── jniLibs/                   # .so 文件（编译后生成）
│       └── res/
├── gradle/
│   └── libs.versions.toml             # 版本目录
├── gradlew / gradlew.bat              # Gradle wrapper
├── build.gradle.kts                   # 根项目配置
└── .gitignore
```

## 添加你的 JNI 方法

### Kotlin 侧

```kotlin
// NativeLib.kt
fun yourMethod(input: Int): Int =
    if (loaded) nativeYourMethod(input)
    else input + 1  // fallback

@JvmStatic
private external fun nativeYourMethod(input: Int): Int
```

### Rust 侧

```rust
// lib.rs — 注意函数名严格按照 JNI 规则
#[unsafe(no_mangle)]
pub extern "system" fn Java_com_example_app_NativeLib_nativeYourMethod(
    _env: EnvUnowned,
    _class: JClass,
    input: jint,
) -> jint {
    input + 1
}
```

### JNI 类型映射

| Kotlin/Java | Rust (`jni::sys`) |
|---|---|
| `Int` | `jint` |
| `Long` | `jlong` |
| `Float` | `jfloat` |
| `Double` | `jdouble` |
| `Boolean` | `jboolean` |
| `String` | `JString` (需要 `env.get_string()`) |
| `Unit` | `()` |

## 常见问题

| 问题 | 解决 |
|---|---|
| `error: cannot find module jni` | 检查 `[dependencies]` 是独占一行 |
| `unsafe attribute used without unsafe` | 用 `#[unsafe(no_mangle)]`（Rust 2024） |
| `deprecated JNIEnv` | 改用 `EnvUnowned`（jni 0.22+） |
| `Activity class does not exist` | `namespace` 和 Kotlin `package` 必须一致 |
| `UnsatisfiedLinkError` | 检查 JNI 函数名是否完全匹配 |
| `Cannot find Java {languageVersion=17}` | 安装 JDK 17（不要用 21+） |
| `adb pair` protocol fault | `adb kill-server` 后重试 |

## 体积优化

Release APK 默认已配置：

| 措施 | 节省 |
|---|---|
| R8 代码裁剪 | DEX 减 65% |
| 资源裁剪 | ~40KB |
| ABI 拆分 (仅 arm) | ~20KB |
| Rust LTO + opt=z | ~3% .so |

## 环境要求

| 工具 | 最低版本 |
|---|---|
| Rust | 1.96+ |
| JDK | 17 |
| Android SDK Build-Tools | 36+ |
| NDK | (由 cargo-ndk 自动使用) |

## 参考

- [实战记录：从 0 到 1 开发 Rust Android 应用](https://github.com/lilyco-42/MyRustApp/blob/master/Rust-Kotlin-Android-%E4%BB%8E0%E5%88%B01.md)
- [APK 体积优化报告](https://github.com/lilyco-42/MyRustApp/blob/master/APK%E4%BD%93%E7%A7%AF%E4%BC%98%E5%8C%96%E6%8A%A5%E5%91%8A.md)
- [开发提示词速查表](https://github.com/lilyco-42/MyRustApp/blob/master/rust_kotlin_android_%E5%BC%80%E5%8F%91%E6%8F%90%E7%A4%BA%E8%AF%8D.md)

## License

MIT — 随意使用、修改、分发。
