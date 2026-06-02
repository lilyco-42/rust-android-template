//! Rust JNI 模板
//!
//! ⚠️ 使用前替换所有 `com_example_app` 为你的包名（. 换成 _）
//!
//! JNI 函数命名: Java_<包名>_<类名>_<方法名>

use jni::objects::{JClass, JString};
use jni::sys::jstring;
use jni::EnvUnowned;

/// 示例: 返回 "Hello {name} from Rust!"
#[unsafe(no_mangle)]
pub extern "system" fn Java_com_example_app_NativeLib_nativeGreet(
    mut env: EnvUnowned,
    _class: JClass,
    name: JString,
) -> jstring {
    let input: String = env
        .get_string(&name)
        .expect("Failed to get string")
        .into();
    let output = format!("Hello {input} from Rust!");
    env.new_string(output)
        .expect("Failed to create string")
        .into_raw()
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_greet() {
        // 纯逻辑验证（不依赖 JNI）
        let s = "World";
        assert_eq!(format!("Hello {s} from Rust!"), "Hello World from Rust!");
    }
}
