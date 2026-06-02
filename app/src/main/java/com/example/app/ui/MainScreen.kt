package com.example.app.ui  // ⚠️ 换成你的包名

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.app.NativeLib  // ⚠️ 换成你的包名
import com.example.app.RustAppTheme

@Composable
fun MainScreen(modifier: Modifier = Modifier) {
    var greeting by remember { mutableStateOf("") }

    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = greeting.ifEmpty { "点击按钮调用 Rust JNI" },
            fontSize = 24.sp,
            textAlign = TextAlign.Center,
        )

        Spacer(Modifier.height(8.dp))

        // Rust JNI 状态指示器
        Text(
            text = if (NativeLib.isLoaded()) "✓ Rust JNI 已加载"
            else "✗ 使用 Kotlin fallback",
            fontSize = 12.sp,
            color = if (NativeLib.isLoaded()) Color(0xFF4CAF50) else Color(0xFFFF5722),
        )

        Spacer(Modifier.height(24.dp))

        Button(
            onClick = { greeting = NativeLib.greet("Rust") },
            modifier = Modifier.size(width = 200.dp, height = 56.dp),
        ) {
            Text("Greet", fontSize = 20.sp)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun MainScreenPreview() {
    RustAppTheme { MainScreen() }
}
