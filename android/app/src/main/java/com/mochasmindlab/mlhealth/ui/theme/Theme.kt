package com.mochasmindlab.mlhealth.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.hilt.navigation.compose.hiltViewModel
import com.mochasmindlab.mlhealth.viewmodel.SettingsViewModel

/** Composition local that exposes the current dark-mode state app-wide. */
val LocalDarkMode = compositionLocalOf { false }

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

// MindLabs specific colors
val MindLabsPurple = Color(0xFF6B46C1)  // Brand purple for MindLabs
val NutritionGreen = Color(0xFF10B981)  // Nutrition/health green

// Additional UI colors for screens
val HydrationBlue = Color(0xFF00BCD4)  // Water tracking
val ExerciseGreen = Color(0xFF4CAF50)  // Exercise
val EnergeticOrange = Color(0xFFFF5722)  // Energy/calories
val MindfulTeal = Color(0xFF00796B)  // Mindfulness
val BalancedPurple = Color(0xFF9C27B0)  // Balance
val CalorieRed = Color(0xFFEF4444)  // Calorie/warning

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

/**
 * App theme.
 *
 * [darkTheme] defaults to the persisted user preference (read from [SettingsViewModel]).
 * Callers may override it explicitly (e.g. previews) by passing a value directly.
 * The resolved dark-mode state is also published via [LocalDarkMode] so child composables
 * can read it without injecting the ViewModel themselves.
 */
@Composable
fun MLFitnessTheme(
    darkTheme: Boolean? = null,          // null = use persisted pref; non-null = caller override
    settingsViewModel: SettingsViewModel = hiltViewModel(),
    content: @Composable () -> Unit
) {
    val uiState by settingsViewModel.uiState.collectAsState()
    val resolvedDark = darkTheme ?: uiState.isDarkMode
    val colorScheme = if (resolvedDark) DarkColorScheme else LightColorScheme

    CompositionLocalProvider(LocalDarkMode provides resolvedDark) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}