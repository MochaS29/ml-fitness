package com.mochasmindlab.mlhealth.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * Modal bottom sheet for adjusting serving count before logging a food/recipe to the diary.
 * Mirrors iOS ServingSizeSheet — ±0.25 stepper, live macro preview.
 *
 * Caller passes the per-1-serving macros and an optional default meal type. The sheet
 * shows a meal-type chooser if [allowMealTypeSelect] is true and [mealType] is null.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ServingSizeSheet(
    title: String,
    subtitle: String?,
    perServingCalories: Int,
    perServingProtein: Double,
    perServingCarbs: Double,
    perServingFat: Double,
    servingLabel: String = "serving",
    initialServings: Double = 1.0,
    allowMealTypeSelect: Boolean = true,
    initialMealType: String = "breakfast",
    onConfirm: (servings: Double, mealType: String) -> Unit,
    onDismiss: () -> Unit
) {
    var servings by remember { mutableStateOf(initialServings) }
    var mealType by remember { mutableStateOf(initialMealType) }

    val totalCalories = (perServingCalories * servings).roundToInt()
    val totalProtein = (perServingProtein * servings)
    val totalCarbs = (perServingCarbs * servings)
    val totalFat = (perServingFat * servings)

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp)
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(title, fontSize = 20.sp, fontWeight = FontWeight.Bold, maxLines = 2)
                    subtitle?.takeIf { it.isNotBlank() }?.let {
                        Spacer(Modifier.height(2.dp))
                        Text(it, fontSize = 13.sp, color = Color.Gray)
                    }
                }
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Cancel")
                }
            }

            Spacer(Modifier.height(20.dp))

            // Serving stepper
            Text("Servings", fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
            Spacer(Modifier.height(10.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                FilledTonalButton(
                    onClick = { servings = max(0.25, servings - 0.25) },
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp)
                ) { Text("−", fontSize = 22.sp, fontWeight = FontWeight.Bold) }

                val unitText = if (servings == 1.0) servingLabel
                    else servingLabel.pluralize()
                Text(
                    "${formatServings(servings)}  $unitText",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold
                )

                FilledTonalButton(
                    onClick = { servings += 0.25 },
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp)
                ) { Text("+", fontSize = 22.sp, fontWeight = FontWeight.Bold) }
            }

            Spacer(Modifier.height(20.dp))

            // Live macro preview
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f)
                ),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 14.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    MacroBlock("$totalCalories", "kcal")
                    MacroBlock("${totalProtein.roundToInt()}g", "protein")
                    MacroBlock("${totalCarbs.roundToInt()}g", "carbs")
                    MacroBlock("${totalFat.roundToInt()}g", "fat")
                }
            }

            // Meal type picker
            if (allowMealTypeSelect) {
                Spacer(Modifier.height(20.dp))
                Text("Meal", fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                Spacer(Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    listOf("breakfast", "lunch", "dinner", "snack").forEach { mt ->
                        FilterChip(
                            selected = mealType == mt,
                            onClick = { mealType = mt },
                            label = {
                                Text(mt.replaceFirstChar { it.uppercase() })
                            },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            Button(
                onClick = { onConfirm(servings, mealType) },
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(vertical = 14.dp)
            ) {
                Text("Add to Diary", fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }
        }
    }
}

@Composable
private fun MacroBlock(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        Text(label, fontSize = 11.sp, color = Color.Gray)
    }
}

private fun formatServings(s: Double): String {
    val rounded = (s * 100).roundToInt() / 100.0
    return if (rounded == rounded.toInt().toDouble()) "${rounded.toInt()}" else "%.2f".format(rounded)
}

/**
 * Pluralize a serving label so "1.5 serving (157g)s" doesn't happen.
 * If the label looks like "X (Y)" we pluralize the part before the parenthetical.
 */
private fun String.pluralize(): String {
    val parenIdx = indexOf('(')
    return if (parenIdx > 0) {
        val head = substring(0, parenIdx).trimEnd()
        val tail = substring(parenIdx)
        val pluralHead = if (head.endsWith("s")) head else "${head}s"
        "$pluralHead $tail"
    } else {
        if (endsWith("s")) this else "${this}s"
    }
}
