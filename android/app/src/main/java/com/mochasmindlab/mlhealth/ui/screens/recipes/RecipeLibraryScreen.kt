package com.mochasmindlab.mlhealth.ui.screens.recipes

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.entities.CustomRecipe
import com.mochasmindlab.mlhealth.data.models.LibraryTab
import com.mochasmindlab.mlhealth.data.models.RecipeCategory
import com.mochasmindlab.mlhealth.data.models.RecipeListItem
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.RecipeLibraryViewModel
import kotlinx.coroutines.launch

// ---------------------------------------------------------------------------
// TODO – Route wiring (do NOT edit MLFitnessNavigation.kt until ready):
//   "recipes"             → RecipeLibraryScreen(navController)
//   "add_custom_recipe"   → AddCustomRecipeScreen(navController)
//   "recipe_detail/{id}"  → RecipeDetailScreen(navController, recipeId)
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeLibraryScreen(
    navController: NavController,
    viewModel: RecipeLibraryViewModel = hiltViewModel()
) {
    val tab by viewModel.tab.collectAsState()
    val category by viewModel.category.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val libraryItems by viewModel.filteredLibraryRecipes.collectAsState()
    val myRecipes by viewModel.filteredMyRecipes.collectAsState()
    val isImporting by viewModel.isImporting.collectAsState()

    var showImportDialog by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = { Text("Recipes", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { navController.navigate("add_custom_recipe") }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Recipe")
                    }
                    IconButton(onClick = { showImportDialog = true }) {
                        Icon(Icons.Default.Link, contentDescription = "Import from URL")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // ---------- Pill toggle ----------
            PillToggle(
                selected = tab,
                onSelect = { viewModel.selectTab(it) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp)
            )

            // ---------- Search bar ----------
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { viewModel.setSearch(it) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 8.dp),
                placeholder = { Text("Search recipes…") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                trailingIcon = {
                    if (searchQuery.isNotEmpty()) {
                        IconButton(onClick = { viewModel.setSearch("") }) {
                            Icon(Icons.Default.Clear, contentDescription = "Clear")
                        }
                    }
                },
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )

            // ---------- Category chips ----------
            CategoryChipsRow(
                selected = category,
                onSelect = { viewModel.selectCategory(it) }
            )

            // ---------- Content ----------
            when (tab) {
                LibraryTab.LIBRARY -> LibraryContent(
                    items = libraryItems,
                    onRecipeTap = { item -> navController.navigate("recipe_detail/${item.id}") }
                )
                LibraryTab.MY_RECIPES -> MyRecipesContent(
                    recipes = myRecipes,
                    onRecipeTap = { recipe -> navController.navigate("recipe_detail/${recipe.id}") },
                    onDelete = { recipe -> viewModel.deleteCustomRecipe(recipe) },
                    onFavoriteToggle = { recipe -> viewModel.toggleFavorite(recipe) },
                    onImportClick = { showImportDialog = true },
                    onAddClick = { navController.navigate("add_custom_recipe") }
                )
            }
        }
    }

    // ---------- Import dialog ----------
    if (showImportDialog) {
        ImportRecipeDialog(
            isLoading = isImporting,
            onDismiss = { showImportDialog = false },
            onImport = { url ->
                viewModel.importFromUrl(url) { result ->
                    showImportDialog = false
                    scope.launch {
                        if (result.isSuccess) {
                            viewModel.selectTab(LibraryTab.MY_RECIPES)
                            snackbarHostState.showSnackbar("Recipe imported!")
                        } else {
                            snackbarHostState.showSnackbar(
                                result.exceptionOrNull()?.message ?: "Import failed"
                            )
                        }
                    }
                }
            }
        )
    }
}

// ---------------------------------------------------------------------------
// Pill toggle
// ---------------------------------------------------------------------------

@Composable
private fun PillToggle(
    selected: LibraryTab,
    onSelect: (LibraryTab) -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceVariant,
        tonalElevation = 1.dp
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            LibraryTab.entries.forEach { tab ->
                val isSelected = selected == tab
                val bgColor by animateColorAsState(
                    targetValue = if (isSelected) MochaBrown else Color.Transparent,
                    animationSpec = tween(200),
                    label = "tabBg"
                )
                val textColor by animateColorAsState(
                    targetValue = if (isSelected) Color.White
                                 else MaterialTheme.colorScheme.onSurfaceVariant,
                    animationSpec = tween(200),
                    label = "tabText"
                )
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(bgColor, RoundedCornerShape(12.dp))
                ) {
                    TextButton(
                        onClick = { onSelect(tab) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = if (tab == LibraryTab.LIBRARY) "Library" else "My Recipes",
                            color = textColor,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Category chips row
// ---------------------------------------------------------------------------

@Composable
private fun CategoryChipsRow(
    selected: RecipeCategory?,
    onSelect: (RecipeCategory?) -> Unit
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.padding(bottom = 8.dp)
    ) {
        item {
            FilterChip(
                selected = selected == null,
                onClick = { onSelect(null) },
                label = { Text("All") }
            )
        }
        items(RecipeCategory.entries) { cat ->
            FilterChip(
                selected = selected == cat,
                onClick = { onSelect(cat) },
                label = { Text(cat.displayName) }
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Library tab content
// ---------------------------------------------------------------------------

@Composable
private fun LibraryContent(
    items: List<RecipeListItem.Bundled>,
    onRecipeTap: (RecipeListItem.Bundled) -> Unit
) {
    if (items.isEmpty()) {
        EmptyState(
            icon = { Icon(Icons.Default.MenuBook, contentDescription = null, modifier = Modifier.size(64.dp)) },
            title = "No Recipes Found",
            subtitle = "Try a different search or category"
        )
        return
    }
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(items, key = { it.id }) { item ->
            RecipeCard(
                name = item.name,
                category = item.category.displayName,
                subtitle = buildSubtitle(item.totalTimeMinutes, item.calories),
                isFavorite = false,
                showFavoriteButton = false,
                onTap = { onRecipeTap(item) },
                onFavoriteTap = {}
            )
        }
    }
}

// ---------------------------------------------------------------------------
// My Recipes tab content
// ---------------------------------------------------------------------------

@Composable
private fun MyRecipesContent(
    recipes: List<CustomRecipe>,
    onRecipeTap: (CustomRecipe) -> Unit,
    onDelete: (CustomRecipe) -> Unit,
    onFavoriteToggle: (CustomRecipe) -> Unit,
    onImportClick: () -> Unit,
    onAddClick: () -> Unit
) {
    if (recipes.isEmpty()) {
        EmptyMyRecipes(onImportClick = onImportClick, onAddClick = onAddClick)
        return
    }
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(recipes, key = { it.id.toString() }) { recipe ->
            var isDismissed by remember { mutableStateOf(false) }
            val dismissState = rememberDismissState(
                confirmValueChange = { value ->
                    if (value == DismissValue.DismissedToStart) {
                        isDismissed = true
                        onDelete(recipe)
                        true
                    } else false
                }
            )
            if (!isDismissed) {
                SwipeToDismiss(
                    state = dismissState,
                    directions = setOf(DismissDirection.EndToStart),
                    background = {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(
                                    MaterialTheme.colorScheme.errorContainer,
                                    RoundedCornerShape(12.dp)
                                )
                                .padding(end = 16.dp),
                            contentAlignment = Alignment.CenterEnd
                        ) {
                            Icon(
                                Icons.Default.Delete,
                                contentDescription = "Delete",
                                tint = MaterialTheme.colorScheme.onErrorContainer
                            )
                        }
                    },
                    dismissContent = {
                        val cat = RecipeCategory.fromString(recipe.category)
                        RecipeCard(
                            name = recipe.name,
                            category = cat.displayName,
                            subtitle = buildSubtitle(recipe.prepTime + recipe.cookTime, recipe.calories.toInt()),
                            isFavorite = recipe.isFavorite,
                            showFavoriteButton = true,
                            onTap = { onRecipeTap(recipe) },
                            onFavoriteTap = { onFavoriteToggle(recipe) }
                        )
                    }
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Shared recipe card
// ---------------------------------------------------------------------------

@Composable
private fun RecipeCard(
    name: String,
    category: String,
    subtitle: String,
    isFavorite: Boolean,
    showFavoriteButton: Boolean,
    onTap: () -> Unit,
    onFavoriteTap: () -> Unit
) {
    Card(
        onClick = onTap,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Category icon
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .background(MochaBrown.copy(alpha = 0.12f), RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = categoryIcon(category),
                    contentDescription = category,
                    tint = MochaBrown,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(name, fontWeight = FontWeight.SemiBold, maxLines = 1)
                Text(subtitle, fontSize = 12.sp, color = Color.Gray)
            }

            if (showFavoriteButton) {
                IconButton(onClick = onFavoriteTap) {
                    Icon(
                        imageVector = if (isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (isFavorite) Color.Red else Color.Gray
                    )
                }
            }

            Icon(Icons.Default.ChevronRight, contentDescription = null, tint = Color.Gray)
        }
    }
}

// ---------------------------------------------------------------------------
// Empty states
// ---------------------------------------------------------------------------

@Composable
private fun EmptyState(
    icon: @Composable () -> Unit,
    title: String,
    subtitle: String
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CompositionLocalProvider(LocalContentColor provides Color.Gray) { icon() }
        Spacer(Modifier.height(16.dp))
        Text(title, fontWeight = FontWeight.SemiBold, color = Color.Gray)
        Spacer(Modifier.height(4.dp))
        Text(subtitle, fontSize = 13.sp, color = Color.Gray)
    }
}

@Composable
private fun EmptyMyRecipes(
    onImportClick: () -> Unit,
    onAddClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(Icons.Default.Book, contentDescription = null, modifier = Modifier.size(64.dp), tint = Color.Gray)
        Spacer(Modifier.height(16.dp))
        Text("No Personal Recipes Yet", fontWeight = FontWeight.SemiBold, color = Color.Gray)
        Spacer(Modifier.height(8.dp))
        Text(
            "Import a recipe from a URL or create your own.",
            fontSize = 13.sp,
            color = Color.Gray
        )
        Spacer(Modifier.height(24.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton(onClick = onImportClick) {
                Icon(Icons.Default.Link, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(4.dp))
                Text("Import")
            }
            Button(onClick = onAddClick) {
                Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(4.dp))
                Text("Create")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Import dialog
// ---------------------------------------------------------------------------

@Composable
private fun ImportRecipeDialog(
    isLoading: Boolean,
    onDismiss: () -> Unit,
    onImport: (String) -> Unit
) {
    var url by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = { if (!isLoading) onDismiss() },
        title = { Text("Import Recipe from URL") },
        text = {
            Column {
                Text("Paste a recipe URL from AllRecipes, Bon Appétit, or any site with structured recipe data.")
                Spacer(Modifier.height(12.dp))
                OutlinedTextField(
                    value = url,
                    onValueChange = { url = it },
                    label = { Text("Recipe URL") },
                    placeholder = { Text("https://www.allrecipes.com/recipe/…") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !isLoading
                )
                if (isLoading) {
                    Spacer(Modifier.height(12.dp))
                    LinearProgressIndicator(progress = 0f, modifier = Modifier.fillMaxWidth())
                    Spacer(Modifier.height(4.dp))
                    Text("Importing…", fontSize = 12.sp, color = Color.Gray)
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = { if (url.isNotBlank()) onImport(url.trim()) },
                enabled = url.isNotBlank() && !isLoading
            ) { Text("Import") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss, enabled = !isLoading) { Text("Cancel") }
        }
    )
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

private fun buildSubtitle(totalMinutes: Int, calories: Int): String {
    val parts = mutableListOf<String>()
    if (totalMinutes > 0) parts.add("$totalMinutes min")
    if (calories > 0) parts.add("$calories cal")
    return parts.joinToString(" · ")
}

private fun categoryIcon(category: String) = when (category.lowercase()) {
    "breakfast" -> Icons.Default.FreeBreakfast
    "lunch"     -> Icons.Default.LunchDining
    "dinner"    -> Icons.Default.DinnerDining
    "snack"     -> Icons.Default.Cookie
    else        -> Icons.Default.Restaurant
}
