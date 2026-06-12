package com.mochasmindlab.mlhealth.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.mochasmindlab.mlhealth.data.models.FoodAllergy

/**
 * Inline red-tinted warning banner shown when detected allergens match the
 * user's saved allergen preferences.
 *
 * Renders nothing when [allergens] is empty, so callers can unconditionally
 * include it in a layout without extra visibility logic.
 *
 * Usage:
 * ```kotlin
 * AllergenWarningBanner(allergens = detectedAllergens)
 * ```
 */
@Composable
fun AllergenWarningBanner(
    allergens: Set<FoodAllergy>,
    modifier: Modifier = Modifier
) {
    if (allergens.isEmpty()) return

    val allergenLabel = allergens.joinToString(", ") { it.displayName }

    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFFFFEBEE) // red-50 tint
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Warning,
                contentDescription = "Allergen warning",
                tint = Color(0xFFC62828), // red-900
                modifier = Modifier.size(20.dp)
            )
            Text(
                text = "Contains: $allergenLabel",
                style = MaterialTheme.typography.bodySmall.copy(
                    fontWeight = FontWeight.SemiBold,
                    color = Color(0xFFC62828)
                )
            )
        }
    }
}

// ── Display name helper ───────────────────────────────────────────────────────
// Converts enum name (e.g. TREE_NUTS) to a human-friendly label ("Tree Nuts").
private val FoodAllergy.displayName: String
    get() = name.split("_").joinToString(" ") { word ->
        word.lowercase().replaceFirstChar { it.uppercaseChar() }
    }
