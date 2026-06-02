package com.example.app  // ⚠️ 换成你的包名（必须与 Rust JNI 函数名中的包名一致）

import android.util.Log

/**
 * Rust JNI 桥接层。
 * 使用 object 单例 + try-catch 保证 Native 库加载失败时应用不崩溃。
 *
 * 用法：
 *   val result = NativeLib.yourMethod(args)
 *   // 如果 .so 未加载，自动使用 Kotlin fallback
 */
object NativeLib {
    private var loaded = false

    init {
        try {
            System.loadLibrary("native_lib")
            loaded = true
            Log.d("NativeLib", "✓ native_lib loaded")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("NativeLib", "✗ failed to load native_lib: ${e.message}")
            loaded = false
        }
    }

    fun isLoaded(): Boolean = loaded

    // ──── 你的 JNI 方法 ────
    // ⚠️ 替换为你自己的业务方法，Rust 侧需要同步修改函数名

    /** 示例：返回问候语 */
    fun greet(name: String): String =
        if (loaded) nativeGreet(name)
        else "Hello $name! (Kotlin fallback)"

    @JvmStatic
    private external fun nativeGreet(name: String): String
}
