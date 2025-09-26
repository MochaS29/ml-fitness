package com.mochasmindlab.mlhealth.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// ML Fitness Colors - Matching iOS exactly
val MochaBrown = Color(0xFF8B4513)  // Primary brand color
val DarkMochaBrown = Color(0xFF7B3F00)
val LightBeige = Color(0xFFF9F7F4)  // Background color
val DeepCharcoal = Color(0xFF2C2C2C)

// Semantic colors matching iOS
val SuccessGreen = Color(0xFF10B981)
val WarningOrange = Color(0xFFF59E0B)
val ErrorRed = Color(0xFFEF4444)

// Feature colors
val WaterBlue = Color(0xFF00BCD4)  // Hydration
val ExerciseOrange = Color(0xFFFF5722)  // Exercise/calories burned
val StepsGreen = Color(0xFF4CAF50)  // Steps
val ProteinBlue = Color(0xFF2196F3)  // Protein macro
val CarbsGreen = Color(0xFF4CAF50)  // Carbs macro
val FatYellow = Color(0xFFFFC107)  // Fat macro
val SupplementPurple = Color(0xFF9C27B0)
val FastingOrange = Color(0xFFFF9800)
val SleepBlue = Color(0xFF3F51B5)
val GoldStar = Color(0xFFFFD700)

private val LightColorScheme = lightColorScheme(
    primary = MochaBrown,
    onPrimary = Color.White,
    secondary = DarkMochaBrown,
    onSecondary = Color.White,
    tertiary = SuccessGreen,
    background = LightBeige,
    surface = Color.White,
    error = ErrorRed,
    onBackground = DeepCharcoal,
    onSurface = DeepCharcoal
)

private val DarkColorScheme = darkColorScheme(
    primary = MochaBrown,
    onPrimary = Color.White,
    secondary = DarkMochaBrown,
    onSecondary = Color.White,
    tertiary = SuccessGreen,
    background = Color(0xFF1C1C1E),
    surface = Color(0xFF2C2C2E),
    error = ErrorRed,
    onBackground = Color.White,
    onSurface = Color.White
)

@Composable
fun MLFitnessTheme(
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