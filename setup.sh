#!/usr/bin/env bash
# Rust Android Template — 一键替换包名
# 用法: bash setup.sh com.yourcompany.yourapp
# 跨平台: Git Bash (Windows) / Linux / macOS

set -e

if [ $# -ne 1 ]; then
    echo "用法: bash setup.sh <你的包名>"
    echo "示例: bash setup.sh com.mycompany.myapp"
    exit 1
fi

OLD_PKG="com.example.app"
NEW_PKG="$1"
OLD_PATH="com/example/app"
NEW_PATH="${NEW_PKG//.//}"
OLD_RUST="com_example_app"
NEW_RUST="${NEW_PKG//./_}"

echo "========================================"
echo " Rust Android Template — 包名替换"
echo "========================================"
echo "  旧包名: $OLD_PKG"
echo "  新包名: $NEW_PKG"
echo "  Rust:   $OLD_RUST → $NEW_RUST"
echo "  路径:   $OLD_PATH → $NEW_PATH"
echo "========================================"

# 1. 替换 Kotlin/Java 源码中的包名声明
echo ""
echo "[1/5] 替换源码中的包名..."
find app/src -name "*.kt" -type f | while read f; do
    if grep -q "$OLD_PKG" "$f" 2>/dev/null; then
        sed -i "s|$OLD_PKG|$NEW_PKG|g" "$f"
        echo "  ✓ $f"
    fi
done

# 2. 替换 Rust JNI 函数名中的包名
echo ""
echo "[2/5] 替换 Rust JNI 函数名..."
sed -i "s|$OLD_RUST|$NEW_RUST|g" native_lib/src/lib.rs
echo "  ✓ native_lib/src/lib.rs"

# 3. 替换 ProGuard 规则
echo ""
echo "[3/5] 替换 ProGuard 规则..."
sed -i "s|$OLD_PKG|$NEW_PKG|g" app/proguard-rules.pro
echo "  ✓ app/proguard-rules.pro"

# 4. 移动源码目录
echo ""
echo "[4/5] 移动源码目录..."
mkdir -p "app/src/main/java/$NEW_PATH"
# rsync 如果可用，否则用 cp
if command -v rsync &>/dev/null; then
    rsync -a --remove-source-files "app/src/main/java/$OLD_PATH/" "app/src/main/java/$NEW_PATH/"
else
    cp -r "app/src/main/java/$OLD_PATH/"* "app/src/main/java/$NEW_PATH/"
    rm -rf "app/src/main/java/$OLD_PATH"
fi
# 清理空目录
find app/src/main/java/com -type d -empty -delete 2>/dev/null || true
echo "  ✓ $OLD_PATH → $NEW_PATH"

# 5. 替换 build.gradle.kts 中的 namespace
echo ""
echo "[5/5] 替换 build.gradle.kts..."
sed -i "s|$OLD_PKG|$NEW_PKG|g" app/build.gradle.kts
echo "  ✓ app/build.gradle.kts"

# 验证
echo ""
echo "========================================"
echo " 验证..."
echo "========================================"
REMAINING=$(grep -r "$OLD_PKG" app/src app/build.gradle.kts app/proguard-rules.pro native_lib/src/lib.rs 2>/dev/null || true)
if [ -n "$REMAINING" ]; then
    echo "⚠ 仍有未替换的旧包名:"
    echo "$REMAINING"
else
    echo "✅ 全部替换完成！新包名: $NEW_PKG"
fi

echo ""
echo "下一步:"
echo "  cd native_lib && cargo ndk --target aarch64-linux-android --target armv7-linux-androideabi --platform 24 -- build --release"
echo "  cd .. && ./gradlew assembleRelease"
