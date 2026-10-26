package dev.serephus.template

import org.junit.Assert.assertEquals
import org.junit.Test

class GreetingTest {
    @Test
    fun greetingText_isStable() {
        assertEquals("Hello, Android!", greetingText())
    }
}
