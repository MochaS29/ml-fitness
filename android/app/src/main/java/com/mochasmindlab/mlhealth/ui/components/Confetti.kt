package com.mochasmindlab.mlhealth.ui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import kotlinx.coroutines.launch
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

private val confettiColors = listOf(
    Color(0xFFE53935), // red
    Color(0xFFFB8C00), // orange
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFF8E24AA), // purple
    Color(0xFFE91E63), // pink
)

private data class Particle(
    val startX: Float,          // 0f..1f (fraction of canvas width)
    val driftX: Float,          // horizontal drift in px
    val sizeDp: Float,          // square side in dp
    val color: Color,
    val rotationSpeed: Float,   // degrees per progress unit (0..1)
    val delay: Float,           // 0f..1f (fraction of total duration to wait before starting)
)

/**
 * Canvas-drawn confetti animation.
 *
 * A single [LaunchedEffect] drives one [Animatable] (0f → 1f over [durationMs]).
 * All particles are rendered in a single [Canvas] pass — no per-particle recomposition.
 *
 * @param particleCount Number of confetti squares. Keep ≤ 80 for performance.
 * @param durationMs    Total fall duration in milliseconds.
 */
@Composable
fun Confetti(
    modifier: Modifier = Modifier,
    particleCount: Int = 60,
    durationMs: Int = 2200,
) {
    // Generate stable particle definitions only once.
    val particles = remember(particleCount) {
        List(particleCount) {
            Particle(
                startX = Random.nextFloat(),
                driftX = Random.nextFloat() * 120f - 60f,   // -60..+60 px drift
                sizeDp = Random.nextFloat() * 6f + 8f,       // 8..14 dp
                color = confettiColors.random(),
                rotationSpeed = Random.nextFloat() * 540f + 180f, // 180..720 deg / fall
                delay = Random.nextFloat() * 0.4f,           // stagger up to 40 % of duration
            )
        }
    }

    val progress = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        // Loop confetti for the lifetime of the overlay (it will be removed externally)
        while (true) {
            progress.snapTo(0f)
            progress.animateTo(
                targetValue = 1f,
                animationSpec = tween(durationMillis = durationMs, easing = LinearEasing)
            )
        }
    }

    val p = progress.value

    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height

        particles.forEach { particle ->
            // Each particle starts after its delay; local progress 0→1 within its active window.
            val localProgress = if (p < particle.delay) 0f
            else ((p - particle.delay) / (1f - particle.delay)).coerceIn(0f, 1f)

            if (localProgress <= 0f) return@forEach

            val x = particle.startX * w + particle.driftX * localProgress
            val y = -particle.sizeDp + (h + particle.sizeDp * 2f) * localProgress
            val rotation = particle.rotationSpeed * localProgress
            val alpha = if (localProgress > 0.8f) (1f - localProgress) / 0.2f else 1f

            rotate(degrees = rotation, pivot = Offset(x, y)) {
                drawRect(
                    color = particle.color.copy(alpha = alpha),
                    topLeft = Offset(x - particle.sizeDp / 2f, y - particle.sizeDp / 2f),
                    size = Size(particle.sizeDp, particle.sizeDp),
                )
            }
        }
    }
}
