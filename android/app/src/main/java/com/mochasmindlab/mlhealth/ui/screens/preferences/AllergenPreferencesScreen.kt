package com.mochasmindlab.mlhealth.ui.screens.preferences

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.DietaryPreference
import com.mochasmindlab.mlhealth.data.models.FoodAllergy
import com.mochasmindlab.mlhealth.viewmodel.AllergenPreferencesViewModel

// Unified "Dietary Preferences" screen — mirrors iOS FoodPreferencesView.
// Two sections: lifestyle/diet (e.g. vegan, keto) + allergens. Single screen so
// users edit both food-safety and dietary choices in one place; matches the iOS
// app's single-entry navigation from the More tab.
@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun AllergenPreferencesScreen(
    navController: NavController,
    viewModel: AllergenPreferencesViewModel = hiltViewModel()
) {
    val allergens by viewModel.selected.collectAsState()
    val diets by viewModel.dietaryPreferences.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dietary Preferences") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // ── Diet & lifestyle ──────────────────────────────────────────
            item {
                SectionHeader(
                    title = "Diet & Lifestyle",
                    subtitle = "Select all that apply. Used to filter recipe suggestions and tailor meal plans."
                )
            }
            item {
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    DietaryPreference.values().forEach { pref ->
                        FilterChip(
                            selected = pref in diets,
                            onClick = { viewModel.toggleDietaryPreference(pref) },
                            label = { Text(pref.displayName) }
                        )
                    }
                }
            }

            // ── Allergens ─────────────────────────────────────────────────
            item {
                Divider()
                SectionHeader(
                    title = "Allergens",
                    subtitle = "Foods you want to avoid. We'll warn you when you log items that contain them."
                )
            }
            item {
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FoodAllergy.values().forEach { allergy ->
                        FilterChip(
                            selected = allergy in allergens,
                            onClick = { viewModel.toggle(allergy) },
                            label = { Text(allergy.displayName) }
                        )
                    }
                }
            }

            // Footer / done
            item {
                Divider()
                Spacer(Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "${diets.size} diet${if (diets.size == 1) "" else "s"} · ${allergens.size} allergen${if (allergens.size == 1) "" else "s"}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    // Selections persist automatically on each toggle via DataStore.
                    TextButton(onClick = { navController.popBackStack() }) {
                        Text("Done", fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String, subtitle: String) {
    Column {
        Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(4.dp))
        Text(
            subtitle,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

// Enum-name → human-readable label. "TREE_NUTS" → "Tree Nuts",
// "ANTI_INFLAMMATORY" → "Anti Inflammatory". Matches the iOS displayName style.
private val FoodAllergy.displayName: String
    get() = name.split("_").joinToString(" ") { it.lowercase().replaceFirstChar { c -> c.uppercaseChar() } }

private val DietaryPreference.displayName: String
    get() = name.split("_").joinToString(" ") { it.lowercase().replaceFirstChar { c -> c.uppercaseChar() } }
