package dev.serephus.template

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import dev.serephus.template.ui.theme.TemplateTheme

fun greetingText(): String = "Hello, Android!"

@Composable
fun Greeting(modifier: Modifier = Modifier) {
    Scaffold(modifier = modifier.fillMaxSize()) { innerPadding ->
        Text(
            text = greetingText(),
            modifier = Modifier.padding(innerPadding),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun GreetingPreview() {
    TemplateTheme {
        Greeting()
    }
}
