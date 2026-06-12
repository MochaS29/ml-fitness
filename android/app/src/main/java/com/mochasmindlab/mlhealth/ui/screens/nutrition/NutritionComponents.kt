package com.mochasmindlab.mlhealth.ui.screens.nutrition

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochasmindlab.mlhealth.data.models.DailyTotals
import com.mochasmindlab.mlhealth.data.models.MacroGoals
import com.mochasmindlab.mlhealth.data.models.MealTotals
import com.mochasmindlab.mlhealth.data.models.NutritionDailyTotals
import com.mochasmindlab.mlhealth.ui.theme.*
import java.util.Date

// =====================================================================
// Internal helper models
// =====================================================================

internal data class SimpleTotals(
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,
    val sugar: Double,
    val sodium: Double
)

internal fun NutritionDailyTotals.toSimpleTotals() = SimpleTotals(
    calories, protein, carbs, fat, fiber, sugar, sodium
)

internal fun DailyTotals.toSimpleTotals() = SimpleTotals(
    calories, protein, carbs, fat, fiber, sugar, sodium
)

internal fun sumOf(days: List<DailyTotals>): DailyTotals {
    if (days.isEmpty()) return DailyTotals(Date(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    return days.reduce { acc, d ->
        acc.copy(
            calories = acc.calories + d.calories,
            protein  = acc.protein  + d.protein,
            carbs    = acc.carbs    + d.carbs,
            fat      = acc.fat      + d.fat,
            fiber    = acc.fiber    + d.fiber,
            sugar    = acc.sugar    + d.sugar,
            sodium   = acc.sodium   + d.sodium
        )
    }
}

internal fun averageOf(days: List<DailyTotals>): SimpleTotals {
    if (days.isEmpty()) return SimpleTotals(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    val n = days.size.toDouble()
    val s = sumOf(days)
    return SimpleTotals(
        s.calories / n, s.protein / n, s.carbs / n,
        s.fat / n, s.fiber / n, s.sugar / n, s.sodium / n
    )
}

// =====================================================================
// Shared card wrapper
// =====================================================================

@Composable
internal fun NutritionCard(title: String, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )
            content()
        }
    }
}

// =====================================================================
// Stat chip (2×2 grid in summary card)
// =====================================================================

@Composable
internal fun StatChip(
    label: String,
    value: String,
    unit: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(8.dp),
        color = color.copy(alpha = 0.10f)
    ) {
        Column(
            modifier = Modifier.padding(10.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Row(
                verticalAlignment = Alignment.Bottom,
                horizontalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(value,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = color
                )
                Text(unit,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

// =====================================================================
// Macro progress bar
// =====================================================================

@Composable
internal fun MacroBar(label: String, value: Double, goal: Double, unit: String, color: Color) {
    val progress = (value / goal.coerceAtLeast(1.0)).coerceIn(0.0, 1.0).toFloat()
    val valueText = if (unit == "mg") "%.0f / %.0f %s".format(value, goal, unit)
                    else "%.1f / %.0f %s".format(value, goal, unit)
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row {
            Text(label, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Medium)
            Spacer(Modifier.weight(1f))
            Text(valueText,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        LinearProgressIndicator(
            progress = progress,
            modifier = Modifier.fillMaxWidth().height(8.dp),
            color = color,
            trackColor = color.copy(alpha = 0.15f)
        )
    }
}

// =====================================================================
// Nutrient table row
// =====================================================================

@Composable
internal fun NutrientRow(name: String, value: Double, unit: String, color: Color, avgLabel: String?) {
    val formatted = when (unit) {
        "kcal", "mg" -> "%.0f %s".format(value, unit)
        else          -> "%.1f %s".format(value, unit)
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp, horizontal = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            modifier = Modifier.size(8.dp),
            shape = RoundedCornerShape(50),
            color = color
        ) {}
        Spacer(Modifier.width(8.dp))
        Text(name, style = MaterialTheme.typography.bodyMedium)
        Spacer(Modifier.weight(1f))
        if (avgLabel != null) {
            Text(avgLabel,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(end = 6.dp)
            )
        }
        Text(formatted,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.SemiBold,
            color = color
        )
    }
}

// =====================================================================
// Canvas bar chart (mirrors ProgressReportsScreen style + goal line)
// =====================================================================

@Composable
internal fun NutritionBarChart(
    values: List<Float>,
    labels: List<String>,
    barColor: Color,
    goalLine: Float,
    modifier: Modifier = Modifier
) {
    if (values.isEmpty()) return
    val maxValue = values.maxOrNull()?.takeIf { it > 0f } ?: goalLine.coerceAtLeast(1f)
    val chartMax = maxOf(maxValue, goalLine)
    val goalLineColor = MochaBrown.copy(alpha = 0.45f)
    val barCount = values.size

    Column(modifier = modifier) {
        Canvas(modifier = Modifier.weight(1f).fillMaxWidth()) {
            val canvasW = size.width
            val canvasH = size.height
            val barW = canvasW / (barCount * 1.8f)
            val gap = (canvasW - barW * barCount) / (barCount + 1)

            values.forEachIndexed { i, v ->
                val barH = (v / chartMax) * canvasH
                val left = gap + i * (barW + gap)
                drawRoundRect(
                    color = barColor,
                    topLeft = Offset(left, canvasH - barH),
                    size = Size(barW, barH),
                    cornerRadius = CornerRadius(6f, 6f)
                )
            }

            if (goalLine > 0f) {
                val lineY = canvasH - (goalLine / chartMax) * canvasH
                drawLine(
                    color = goalLineColor,
                    start = Offset(0f, lineY),
                    end = Offset(canvasW, lineY),
                    strokeWidth = 2.dp.toPx(),
                    pathEffect = androidx.compose.ui.graphics.PathEffect.dashPathEffect(
                        floatArrayOf(12f, 8f), 0f
                    )
                )
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            labels.forEach { label ->
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    fontSize = 10.sp,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}
