package com.mochasmindlab.mlhealth.ui.screens.customfood

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.AddCustomFoodViewModel

// TODO route name: "add_custom_food"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddCustomFoodScreen(
    navController: NavController,
    viewModel: AddCustomFoodViewModel = hiltViewModel()
) {
    val formState by viewModel.formState.collectAsState()

    // Navigate back as soon as the save completes
    LaunchedEffect(formState.savedSuccessfully) {
        if (formState.savedSuccessfully) {
            navController.popBackStack()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add Custom Food", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(
                        onClick = { viewModel.save() },
                        enabled = !formState.isSaving
                    ) {
                        Icon(Icons.Default.Check, contentDescription = "Save")
                    }
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // ---- Basic Info ----
            item {
                SectionHeader("Basic Information")
            }

            item {
                OutlinedTextField(
                    value = formState.name,
                    onValueChange = viewModel::updateName,
                    label = { Text("Food Name *") },
                    isError = formState.nameError != null,
                    supportingText = formState.nameError?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            item {
                OutlinedTextField(
                    value = formState.brand,
                    onValueChange = viewModel::updateBrand,
                    label = { Text("Brand (optional)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            // ---- Serving Size ----
            item {
                SectionHeader("Serving Size")
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = formState.servingSize,
                        onValueChange = viewModel::updateServingSize,
                        label = { Text("Amount *") },
                        isError = formState.servingSizeError != null,
                        supportingText = formState.servingSizeError?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
                        modifier = Modifier.weight(1f),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        singleLine = true
                    )
                    OutlinedTextField(
                        value = formState.servingUnit,
                        onValueChange = viewModel::updateServingUnit,
                        label = { Text("Unit") },
                        placeholder = { Text("g, oz, cup…") },
                        modifier = Modifier.weight(1f),
                        singleLine = true
                    )
                }
            }

            // ---- Macronutrients ----
            item {
                SectionHeader("Nutrition (per serving)")
            }

            item {
                NutrientField(
                    label = "Calories *",
                    value = formState.calories,
                    onValueChange = viewModel::updateCalories,
                    isError = formState.caloriesError != null,
                    errorText = formState.caloriesError,
                    unit = "kcal"
                )
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    NutrientField(
                        label = "Protein",
                        value = formState.protein,
                        onValueChange = viewModel::updateProtein,
                        unit = "g",
                        modifier = Modifier.weight(1f)
                    )
                    NutrientField(
                        label = "Carbs",
                        value = formState.carbs,
                        onValueChange = viewModel::updateCarbs,
                        unit = "g",
                        modifier = Modifier.weight(1f)
                    )
                    NutrientField(
                        label = "Fat",
                        value = formState.fat,
                        onValueChange = viewModel::updateFat,
                        unit = "g",
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // ---- Optional micronutrients ----
            item {
                SectionHeader("Additional Nutrients (optional)")
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    NutrientField(
                        label = "Fiber",
                        value = formState.fiber,
                        onValueChange = viewModel::updateFiber,
                        unit = "g",
                        modifier = Modifier.weight(1f)
                    )
                    NutrientField(
                        label = "Sugar",
                        value = formState.sugar,
                        onValueChange = viewModel::updateSugar,
                        unit = "g",
                        modifier = Modifier.weight(1f)
                    )
                    NutrientField(
                        label = "Sodium",
                        value = formState.sodium,
                        onValueChange = viewModel::updateSodium,
                        unit = "mg",
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // ---- Save Button ----
            item {
                Spacer(modifier = Modifier.height(8.dp))
                Button(
                    onClick = { viewModel.save() },
                    enabled = !formState.isSaving,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = MochaBrown)
                ) {
                    if (formState.isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = MaterialTheme.colorScheme.onPrimary,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Text("Save Custom Food", fontWeight = FontWeight.Bold)
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }

        // Error snackbar
        formState.errorMessage?.let { msg ->
            AlertDialog(
                onDismissRequest = viewModel::clearError,
                title = { Text("Error") },
                text = { Text(msg) },
                confirmButton = {
                    TextButton(onClick = viewModel::clearError) { Text("OK") }
                }
            )
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleSmall,
        fontWeight = FontWeight.SemiBold,
        color = MochaBrown,
        modifier = Modifier.padding(top = 4.dp, bottom = 2.dp)
    )
    Divider()
}

@Composable
private fun NutrientField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    unit: String,
    modifier: Modifier = Modifier.fillMaxWidth(),
    isError: Boolean = false,
    errorText: String? = null
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        suffix = { Text(unit, style = MaterialTheme.typography.bodySmall) },
        isError = isError,
        supportingText = errorText?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
        modifier = modifier,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        singleLine = true
    )
}
