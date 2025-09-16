package com.mochasmindlab.mlhealth.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// ML Health Colors - Matching iOS
val MindLabsPurple = Color(0xFF7B68EE)
val MindfulTeal = Color(0xFF4A9B9B)
val WellnessGreen = Color(0xFF7FB069)
val SoftCream = Color(0xFFF9F7F4)
val DeepCharcoal = Color(0xFF2C2C2C)
val ErrorRed = Color(0xFFD32F2F)

// Additional colors for metrics
val EnergeticOrange = Color(0xFFFFA500)
val HydrationBlue = Color(0xFF4ECDC4)
val ExerciseGreen = Color(0xFF7FB069)
val BalancedPurple = Color(0xFF6C5CE7)
val MochaBrown = Color(0xFF6F4E37)
val CalmingBlue = Color(0xFF4A90E2)
val EnergeticYellow = Color(0xFFFFC107)
val NutritionGreen = Color(0xFF4CAF50)
val CalorieRed = Color(0xFFFF6B6B)
val SupplementPurple = Color(0xFF9C27B0)
val FastingOrange = Color(0xFFFF9800)
val SleepBlue = Color(0xFF3F51B5)
val GoldStar = Color(0xFFFFD700)

private val LightColorScheme = lightColorScheme(
    primary = MindLabsPurple,
    onPrimary = Color.White,
    secondary = MindfulTeal,
    onSecondary = Color.White,
    tertiary = WellnessGreen,
    background = SoftCream,
    surface = Color.White,
    error = ErrorRed,
    onBackground = DeepCharcoal,
    onSurface = DeepCharcoal
)

private val DarkColorScheme = darkColorScheme(
    primary = MindLabsPurple,
    onPrimary = Color.White,
    secondary = MindfulTeal,
    onSecondary = Color.White,
    tertiary = WellnessGreen,
    background = Color(0xFF1C1C1E),
    surface = Color(0xFF2C2C2E),
    error = ErrorRed,
    onBackground = Color.White,
    onSurface = Color.White
)

@Composable
fun MLHealthTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}