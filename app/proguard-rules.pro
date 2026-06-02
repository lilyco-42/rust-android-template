# Rust JNI 保护 — 防止 R8 移除 native 方法
-keep class REPLACE_WITH_YOUR_PACKAGE.NativeLib {
    native <methods>;
}

# Compose 保护
-dontwarn androidx.compose.**
-keep class androidx.compose.** { *; }

# 保留行号信息
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
