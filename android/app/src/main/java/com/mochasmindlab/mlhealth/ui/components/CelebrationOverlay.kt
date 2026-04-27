package com.mochasmindlab.mlhealth.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.mochasmindlab.mlhealth.data.models.MLAchievement
import com.mochasmindlab.mlhealth.services.AchievementManager
import kotlinx.coroutines.delay

/**
 * Root-level wrapper that listens to [AchievementManager.recentlyUnlocked] and
 * displays a full-screen celebration overlay (confetti + card) whenever an
 * achievement emits.
 *
 * Place this at the top of [MainActivity]'s setContent tree, wrapping all other
 * navigation content:
 *
 * ```kotlin
 * CelebrationHost(achievementManager = achievementManager) {
 *     MLFitnessNavigation()
 * }
 * ```
 *
 * The overlay auto-dismisses after 2.5 seconds and can also be tapped to dismiss early.
 */
@Composable
fun CelebrationHost(
    achievementManager: AchievementManager,
    content: @Composable () -> Unit,
) {
    var current by remember { mutableStateOf<MLAchievement?>(null) }

    // Collect emissions from the SharedFlow; one at a time.
    LaunchedEffect(Unit) {
        achievementManager.recentlyUnlocked.collect { ach ->
            current = ach
            delay(2500L)
            current = null
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // The app content always fills the whole space.
        content()

        // Overlay — sits above everything, rendered only when an achievement arrives.
        AnimatedVisibility(
            visible = current != null,
            modifier = Modifier
                .fillMaxSize()
                .zIndex(999f),
            enter = fadeIn(),
            exit = fadeOut(),
        ) {
            current?.let { achievement ->
                CelebrationOverlayContent(
                    achievement = achievement,
                    onDismiss = { current = null },
                )
            }
        }
    }
}

// ── Internal overlay content ──────────────────────────────────────────────────

@Composable
private fun CelebrationOverlayContent(
    achievement: MLAchievement,
    onDismiss: () -> Unit,
) {
    val haptic = LocalHapticFeedback.current

    // Trigger haptic feedback once when the overlay appears.
    LaunchedEffect(Unit) {
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
    }

    // Full-screen dim — tap anywhere to dismiss.
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.4f))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onDismiss,
            ),
        contentAlignment = Alignment.Center,
    ) {
        // Confetti rendered behind the card, pointer-events ignored via clickable on parent.
        Confetti(modifier = Modifier.fillMaxSize())

        // Achievement card — stop tap events propagating to the dim background.
        AchievementCard(
            achievement = achievement,
            modifier = Modifier
                .padding(horizontal = 40.dp)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onDismiss,
                ),
        )
    }
}

@Composable
private fun AchievementCard(
    achievement: MLAchievement,
    modifier: Modifier = Modifier,
) {
    // Springy entrance scale for the card.
    var visible by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (visible) 1f else 0.75f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium,
        ),
        label = "cardScale",
    )

    LaunchedEffect(Unit) { visible = true }

    Card(
        modifier = modifier.scale(scale),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 16.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            // Icon circle
            Box(
                modifier = Modifier
                    .size(88.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = Icons.Default.EmojiEvents,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(48.dp),
                )
            }

            // "Achievement Unlocked!" subhead
            Text(
                text = "Achievement Unlocked!",
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                color = MaterialTheme.colorScheme.primary,
                letterSpacing = 0.5.sp,
                textAlign = TextAlign.Center,
            )

            // Achievement title
            Text(
                text = achievement.title,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface,
                textAlign = TextAlign.Center,
            )

            // Achievement description
            Text(
                text = achievement.description,
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                lineHeight = 20.sp,
            )

            Spacer(modifier = Modifier.height(4.dp))

            // "Tap to continue" hint
            Text(
                text = "Tap anywhere to continue",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                textAlign = TextAlign.Center,
            )
        }
    }
}
