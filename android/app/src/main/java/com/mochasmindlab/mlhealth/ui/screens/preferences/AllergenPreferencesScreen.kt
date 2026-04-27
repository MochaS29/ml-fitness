package com.mochasmindlab.mlhealth.ui.screens.preferences

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import com.mochasmindlab.mlhealth.data.models.FoodAllergy
import com.mochasmindlab.mlhealth.viewmodel.AllergenPreferencesViewModel

// TODO: Route `allergen_preferences` in MLFitnessNavigation.kt should navigate
//       to this screen.  Example call-site:
//         composable("allergen_preferences") {
//             AllergenPreferencesScreen(navController = navController)
//         }

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun AllergenPreferencesScreen(
    navController: NavController,
    viewModel: AllergenPreferencesViewModel = hiltViewModel()
) {
    val selected by viewModel.selected.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Allergens") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
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
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Subtitle
            item {
                Text(
                    text = "Select foods you want to avoid. We'll warn you when you log items containing them.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Chip grid — FlowRow wraps chips into multiple rows automatically
            item {
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FoodAllergy.values().forEach { allergy ->
                        FilterChip(
                            selected = allergy in selected,
                            onClick = { viewModel.toggle(allergy) },
                            label = { Text(allergy.displayName) }
                        )
                    }
                }
            }

            // Selected count footer
            item {
                Divider()
                Spacer(Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = if (selected.isEmpty()) {
                            "No allergens selected"
                        } else {
                            "${selected.size} allergen${if (selected.size == 1) "" else "s"} selected"
                        },
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    // Changes persist automatically on each toggle via DataStore.
                    // A dedicated "Save" action is not required, but a visual
                    // affordance is provided here for user confidence.
                    TextButton(onClick = { navController.popBackStack() }) {
                        Text("Done", fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }
}

// ── Display name helper ───────────────────────────────────────────────────────
private val FoodAllergy.displayName: String
    get() = name.split("_").joinToString(" ") { word ->
        word.lowercase().replaceFirstChar { it.uppercaseChar() }
    }
