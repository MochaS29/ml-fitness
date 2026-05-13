package com.mochasmindlab.mlhealth.ui.screens.scanner

import android.graphics.Bitmap
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.DetectedFood
import com.mochasmindlab.mlhealth.viewmodel.MealScannerViewModel
import com.mochasmindlab.mlhealth.viewmodel.ScanPhase
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MealScannerScreen(
    navController: NavController,
    viewModel: MealScannerViewModel = hiltViewModel()
) {
    val phase by viewModel.phase.collectAsState()
    val editableItems by viewModel.editableItems.collectAsState()
    val analysis by viewModel.analysis.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val selectedMealType by viewModel.selectedMealType.collectAsState()
    val mealScanCount by viewModel.mealScanCount.collectAsState()
    val isPro by viewModel.isPro.collectAsState()

    val context = LocalContext.current
    var capturedBitmap by remember { mutableStateOf<Bitmap?>(null) }
    val scope = rememberCoroutineScope()

    val takePictureLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.TakePicturePreview()
    ) { bitmap ->
        if (bitmap != null) {
            capturedBitmap = bitmap
            viewModel.analyze(bitmap)
        }
    }

    // GetContent("image/*") works with activity-compose 1.4.0; PickVisualMedia requires 1.7.0+.
    val pickImageLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            scope.launch {
                val bitmap = uriToBitmap(context, uri)
                if (bitmap != null) {
                    capturedBitmap = bitmap
                    viewModel.analyze(bitmap)
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("AI Meal Scanner", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = {
                        viewModel.reset()
                        navController.popBackStack()
                    }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (phase) {
                ScanPhase.Idle -> IdleContent(
                    onTakePhoto = { takePictureLauncher.launch(null) },
                    onPickGallery = { pickImageLauncher.launch("image/*") },
                    freeScansLeft = (3 - mealScanCount).coerceAtLeast(0),
                    isPro = isPro
                )

                ScanPhase.Paywall -> PaywallGate(
                    onUpgrade = { navController.navigate("paywall") },
                    onCancel = {
                        viewModel.reset()
                        navController.popBackStack()
                    }
                )

                ScanPhase.Capturing -> {
                    // TakePicturePreview handles its own UI; show nothing extra here.
                }

                ScanPhase.Analyzing -> AnalyzingContent(bitmap = capturedBitmap)

                ScanPhase.Results -> ResultsContent(
                    items = editableItems,
                    totalCalories = analysis?.totalCalories ?: 0,
                    selectedMealType = selectedMealType,
                    onItemUpdated = { index, item -> viewModel.updateItem(index, item) },
                    onMealTypeSelected = { viewModel.selectMealType(it) },
                    onSave = {
                        viewModel.saveToDiary()
                        navController.popBackStack()
                    },
                    onDiscard = {
                        viewModel.reset()
                        navController.popBackStack()
                    }
                )

                ScanPhase.Error -> ErrorContent(
                    message = errorMessage ?: "Something went wrong",
                    onRetry = {
                        capturedBitmap?.let { viewModel.analyze(it) }
                            ?: run { viewModel.reset() }
                    },
                    onDismiss = {
                        viewModel.reset()
                        navController.popBackStack()
                    }
                )
            }
        }
    }
}

@Composable
private fun PaywallGate(onUpgrade: () -> Unit, onCancel: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("⭐", fontSize = 48.sp)
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            "You've used your 3 free scans",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            "Upgrade to Pro for unlimited AI meal scans, advanced charts, and full Health Connect sync.",
            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
            color = Color.Gray
        )
        Spacer(modifier = Modifier.height(24.dp))
        Button(onClick = onUpgrade, modifier = Modifier.fillMaxWidth()) {
            Text("See Pro options")
        }
        Spacer(modifier = Modifier.height(8.dp))
        TextButton(onClick = onCancel) { Text("Not now") }
    }
}

@Composable
private fun IdleContent(
    onTakePhoto: () -> Unit,
    onPickGallery: () -> Unit,
    freeScansLeft: Int = 3,
    isPro: Boolean = false
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            "Scan Your Meal",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            "Take a photo or pick from your gallery. Claude AI will identify the food and estimate nutrition.",
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        Spacer(modifier = Modifier.height(16.dp))
        if (isPro) {
            AssistChip(
                onClick = {},
                label = { Text("Pro · unlimited scans") }
            )
        } else {
            AssistChip(
                onClick = {},
                label = { Text("$freeScansLeft of 3 free scans remaining") }
            )
        }
        Spacer(modifier = Modifier.height(24.dp))
        Button(
            onClick = onTakePhoto,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.CameraAlt, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text("Take Photo")
        }
        Spacer(modifier = Modifier.height(12.dp))
        OutlinedButton(
            onClick = onPickGallery,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.PhotoLibrary, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text("Choose from Gallery")
        }
    }
}

@Composable
private fun AnalyzingContent(bitmap: Bitmap?) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        if (bitmap != null) {
            Image(
                bitmap = bitmap.asImageBitmap(),
                contentDescription = "Captured meal",
                modifier = Modifier
                    .size(200.dp)
                    .padding(bottom = 24.dp)
            )
        }
        CircularProgressIndicator()
        Spacer(modifier = Modifier.height(16.dp))
        Text("Analyzing your meal...", fontSize = 16.sp)
        Text(
            "Claude AI is identifying food items",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun ResultsContent(
    items: List<DetectedFood>,
    totalCalories: Int,
    selectedMealType: String,
    onItemUpdated: (Int, DetectedFood) -> Unit,
    onMealTypeSelected: (String) -> Unit,
    onSave: () -> Unit,
    onDiscard: () -> Unit
) {
    val mealTypes = listOf("breakfast", "lunch", "dinner", "snack")

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("Detected Items", fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Text(
                "Total: ~$totalCalories cal",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(4.dp))
        }

        itemsIndexed(items) { index, item ->
            FoodItemCard(
                item = item,
                onUpdate = { updated -> onItemUpdated(index, updated) }
            )
        }

        item {
            Spacer(modifier = Modifier.height(4.dp))
            Text("Meal Type", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                mealTypes.forEach { type ->
                    FilterChip(
                        selected = selectedMealType == type,
                        onClick = { onMealTypeSelected(type) },
                        label = { Text(type.replaceFirstChar { it.uppercase() }, fontSize = 12.sp) }
                    )
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(8.dp))
            Button(
                onClick = onSave,
                modifier = Modifier.fillMaxWidth(),
                enabled = items.isNotEmpty()
            ) {
                Text("Save to Diary")
            }
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedButton(
                onClick = onDiscard,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Discard")
            }
        }
    }
}

@Composable
private fun FoodItemCard(item: DetectedFood, onUpdate: (DetectedFood) -> Unit) {
    var quantityText by remember(item.quantity) { mutableStateOf(item.quantity) }
    var caloriesText by remember(item.calories) { mutableStateOf(item.calories.toInt().toString()) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(item.name, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = quantityText,
                    onValueChange = { new ->
                        quantityText = new
                        onUpdate(item.copy(quantity = new))
                    },
                    label = { Text("Quantity") },
                    modifier = Modifier.weight(1f),
                    singleLine = true
                )
                OutlinedTextField(
                    value = caloriesText,
                    onValueChange = { new ->
                        caloriesText = new
                        val cal = new.toDoubleOrNull() ?: item.calories
                        onUpdate(item.copy(calories = cal))
                    },
                    label = { Text("Cal") },
                    modifier = Modifier.weight(0.7f),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                MacroChip("P", "${item.protein.toInt()}g")
                MacroChip("C", "${item.carbs.toInt()}g")
                MacroChip("F", "${item.fat.toInt()}g")
                item.fiber?.let { MacroChip("Fiber", "${it.toInt()}g") }
            }
        }
    }
}

@Composable
private fun MacroChip(label: String, value: String) {
    Surface(
        shape = RoundedCornerShape(6.dp),
        color = MaterialTheme.colorScheme.surfaceVariant
    ) {
        Row(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)) {
            Text(label, fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(modifier = Modifier.width(4.dp))
            Text(value, fontSize = 11.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
private fun ErrorContent(message: String, onRetry: () -> Unit, onDismiss: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Scan Failed", fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            message,
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        Spacer(modifier = Modifier.height(32.dp))
        Button(onClick = onRetry, modifier = Modifier.fillMaxWidth()) {
            Text("Try Again")
        }
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) {
            Text("Cancel")
        }
    }
}

private fun uriToBitmap(context: android.content.Context, uri: Uri): Bitmap? {
    return try {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            android.graphics.ImageDecoder.decodeBitmap(
                android.graphics.ImageDecoder.createSource(context.contentResolver, uri)
            ) { decoder, _, _ -> decoder.allocator = android.graphics.ImageDecoder.ALLOCATOR_SOFTWARE }
        } else {
            @Suppress("DEPRECATION")
            android.provider.MediaStore.Images.Media.getBitmap(context.contentResolver, uri)
        }
    } catch (e: Exception) {
        null
    }
}

// TODO: Register this screen in the NavHost.
//
// Route name : "meal_scanner"
//
// Add the following inside the NavHost block in
// ui/navigation/MLFitnessNavigation.kt (or navigation/MLHealthNavHost.kt):
//
//   composable("meal_scanner") {
//       com.mochasmindlab.mlhealth.ui.screens.scanner.MealScannerScreen(navController = navController)
//   }
//
// To launch the scanner from the Add menu, add an AddMenuItem entry in AddMenuContent
// that calls:  navController.navigate("meal_scanner")
