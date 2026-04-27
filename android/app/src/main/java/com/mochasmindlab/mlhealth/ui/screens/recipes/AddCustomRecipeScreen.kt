package com.mochasmindlab.mlhealth.ui.screens.recipes

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.RecipeCategory
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.AddCustomRecipeViewModel

// ---------------------------------------------------------------------------
// TODO – Route wiring:
//   "add_custom_recipe" → AddCustomRecipeScreen(navController)
// ---------------------------------------------------------------------------

@OptIn(
    ExperimentalMaterial3Api::class,
    androidx.compose.foundation.layout.ExperimentalLayoutApi::class
)
@Composable
fun AddCustomRecipeScreen(
    navController: NavController,
    viewModel: AddCustomRecipeViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    // Navigate back when save completes
    LaunchedEffect(state.savedSuccessfully) {
        if (state.savedSuccessfully) navController.popBackStack()
    }

    // Draft ingredient / instruction / tag input text
    var ingredientInput by remember { mutableStateOf("") }
    var instructionInput by remember { mutableStateOf("") }
    var tagInput by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add Recipe", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.Close, contentDescription = "Cancel")
                    }
                },
                actions = {
                    if (state.isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier
                                .size(24.dp)
                                .padding(end = 8.dp),
                            strokeWidth = 2.dp
                        )
                    } else {
                        TextButton(
                            onClick = { viewModel.save() },
                            enabled = state.name.isNotBlank()
                        ) {
                            Text("Save", fontWeight = FontWeight.Bold)
                        }
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            // ---- Basic info ----
            item {
                SectionHeader("Recipe Information")
            }

            item {
                OutlinedTextField(
                    value = state.name,
                    onValueChange = { viewModel.setName(it) },
                    label = { Text("Recipe Name *") },
                    isError = state.nameError != null,
                    supportingText = state.nameError?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            item {
                // Category dropdown
                var expanded by remember { mutableStateOf(false) }
                ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = { expanded = it }) {
                    OutlinedTextField(
                        value = state.category,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Category") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor()
                    )
                    ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                        RecipeCategory.entries.forEach { cat ->
                            DropdownMenuItem(
                                text = { Text(cat.displayName) },
                                onClick = {
                                    viewModel.setCategory(cat.displayName)
                                    expanded = false
                                }
                            )
                        }
                    }
                }
            }

            item {
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    // Prep time stepper
                    TimeStepperField(
                        label = "Prep",
                        value = state.prepTime,
                        onDecrement = { viewModel.setPrepTime(state.prepTime - 5) },
                        onIncrement = { viewModel.setPrepTime(state.prepTime + 5) },
                        modifier = Modifier.weight(1f)
                    )
                    // Cook time stepper
                    TimeStepperField(
                        label = "Cook",
                        value = state.cookTime,
                        onDecrement = { viewModel.setCookTime(state.cookTime - 5) },
                        onIncrement = { viewModel.setCookTime(state.cookTime + 5) },
                        modifier = Modifier.weight(1f)
                    )
                    // Servings stepper
                    TimeStepperField(
                        label = "Servings",
                        value = state.servings,
                        onDecrement = { viewModel.setServings(state.servings - 1) },
                        onIncrement = { viewModel.setServings(state.servings + 1) },
                        suffix = "",
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // ---- Ingredients ----
            item { Divider(); SectionHeader("Ingredients") }

            itemsIndexed(state.ingredients) { index, ingredient ->
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        "• ",
                        color = MochaBrown,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(end = 4.dp)
                    )
                    OutlinedTextField(
                        value = ingredient,
                        onValueChange = { viewModel.updateIngredient(index, it) },
                        modifier = Modifier.weight(1f),
                        singleLine = true,
                        placeholder = { Text("e.g. 1 cup flour") }
                    )
                    IconButton(onClick = { viewModel.removeIngredient(index) }) {
                        Icon(Icons.Default.Delete, contentDescription = "Remove", tint = Color.Gray)
                    }
                }
            }

            item {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    OutlinedTextField(
                        value = ingredientInput,
                        onValueChange = { ingredientInput = it },
                        modifier = Modifier.weight(1f),
                        singleLine = true,
                        placeholder = { Text("Add ingredient…") }
                    )
                    Spacer(Modifier.width(8.dp))
                    FilledTonalIconButton(
                        onClick = {
                            if (ingredientInput.isNotBlank()) {
                                viewModel.addIngredient(ingredientInput)
                                ingredientInput = ""
                            }
                        }
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Add ingredient")
                    }
                }
            }

            // ---- Instructions ----
            item { Divider(); SectionHeader("Instructions") }

            itemsIndexed(state.instructions) { index, step ->
                Row(verticalAlignment = Alignment.Top) {
                    Text(
                        "${index + 1}.",
                        color = MochaBrown,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 16.dp, end = 8.dp)
                    )
                    OutlinedTextField(
                        value = step,
                        onValueChange = { viewModel.updateInstruction(index, it) },
                        modifier = Modifier.weight(1f),
                        minLines = 2,
                        placeholder = { Text("Describe this step…") }
                    )
                    IconButton(
                        onClick = { viewModel.removeInstruction(index) },
                        modifier = Modifier.padding(top = 4.dp)
                    ) {
                        Icon(Icons.Default.Delete, contentDescription = "Remove", tint = Color.Gray)
                    }
                }
            }

            item {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    OutlinedTextField(
                        value = instructionInput,
                        onValueChange = { instructionInput = it },
                        modifier = Modifier.weight(1f),
                        placeholder = { Text("Add step…") },
                        minLines = 2
                    )
                    Spacer(Modifier.width(8.dp))
                    FilledTonalIconButton(
                        onClick = {
                            viewModel.addInstruction(instructionInput)
                            instructionInput = ""
                        }
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Add step")
                    }
                }
            }

            // ---- Nutrition (per serving) ----
            item { Divider(); SectionHeader("Nutrition (per serving)") }

            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        NutritionField("Calories", state.caloriesStr, { viewModel.setCalories(it) }, Modifier.weight(1f))
                        NutritionField("Protein (g)", state.proteinStr, { viewModel.setProtein(it) }, Modifier.weight(1f))
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        NutritionField("Carbs (g)", state.carbsStr, { viewModel.setCarbs(it) }, Modifier.weight(1f))
                        NutritionField("Fat (g)", state.fatStr, { viewModel.setFat(it) }, Modifier.weight(1f))
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        NutritionField("Fiber (g)", state.fiberStr, { viewModel.setFiber(it) }, Modifier.weight(1f))
                        NutritionField("Sugar (g)", state.sugarStr, { viewModel.setSugar(it) }, Modifier.weight(1f))
                    }
                    NutritionField("Sodium (mg)", state.sodiumStr, { viewModel.setSodium(it) }, Modifier.fillMaxWidth())
                }
            }

            // ---- Tags ----
            item { Divider(); SectionHeader("Tags") }

            if (state.tags.isNotEmpty()) {
                item {
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        state.tags.forEach { tag ->
                            InputChip(
                                selected = false,
                                onClick = { viewModel.removeTag(tag) },
                                label = { Text(tag) },
                                trailingIcon = {
                                    Icon(Icons.Default.Close, contentDescription = "Remove tag", modifier = Modifier.size(14.dp))
                                }
                            )
                        }
                    }
                }
            }

            item {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    OutlinedTextField(
                        value = tagInput,
                        onValueChange = { tagInput = it },
                        modifier = Modifier.weight(1f),
                        singleLine = true,
                        placeholder = { Text("Add tag…") }
                    )
                    Spacer(Modifier.width(8.dp))
                    FilledTonalIconButton(
                        onClick = {
                            if (tagInput.isNotBlank()) {
                                viewModel.addTag(tagInput)
                                tagInput = ""
                            }
                        }
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Add tag")
                    }
                }
            }

            // Error message
            if (state.errorMessage != null) {
                item {
                    Text(state.errorMessage!!, color = MaterialTheme.colorScheme.error, fontSize = 13.sp)
                }
            }

            item { Spacer(Modifier.height(32.dp)) }
        }
    }
}

// ---------------------------------------------------------------------------
// Small reusable composables
// ---------------------------------------------------------------------------

@Composable
private fun SectionHeader(title: String) {
    Text(
        title,
        fontWeight = FontWeight.Bold,
        fontSize = 16.sp,
        color = MochaBrown,
        modifier = Modifier.padding(top = 4.dp, bottom = 4.dp)
    )
}

@Composable
private fun TimeStepperField(
    label: String,
    value: Int,
    onDecrement: () -> Unit,
    onIncrement: () -> Unit,
    suffix: String = " min",
    modifier: Modifier = Modifier
) {
    Card(modifier = modifier, elevation = CardDefaults.cardElevation(1.dp)) {
        Column(
            modifier = Modifier.padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(label, fontSize = 11.sp, color = Color.Gray)
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onDecrement, modifier = Modifier.size(28.dp)) {
                    Icon(Icons.Default.Remove, contentDescription = "Decrease", modifier = Modifier.size(16.dp))
                }
                Text("$value$suffix", fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
                IconButton(onClick = onIncrement, modifier = Modifier.size(28.dp)) {
                    Icon(Icons.Default.Add, contentDescription = "Increase", modifier = Modifier.size(16.dp))
                }
            }
        }
    }
}

@Composable
private fun NutritionField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, fontSize = 11.sp) },
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
        singleLine = true,
        modifier = modifier
    )
}
