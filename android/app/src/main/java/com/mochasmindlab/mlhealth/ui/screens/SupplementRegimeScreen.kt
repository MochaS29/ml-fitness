package com.mochasmindlab.mlhealth.ui.screens

import android.Manifest
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.window.Dialog
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.mochasmindlab.mlhealth.data.entities.RegimeSupplement
import com.mochasmindlab.mlhealth.data.entities.SupplementRegime
import com.mochasmindlab.mlhealth.viewmodel.SupplementRegimeViewModel
import kotlinx.coroutines.launch
import java.util.UUID
import java.util.concurrent.Executors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SupplementRegimeScreen(
    navController: NavController,
    viewModel: SupplementRegimeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showAddRegimeDialog by remember { mutableStateOf(false) }
    var showBarcodeScanner by remember { mutableStateOf(false) }
    var selectedRegimeForEdit by remember { mutableStateOf<SupplementRegime?>(null) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Supplement Regimes") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { showAddRegimeDialog = true }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Regime")
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
            // Quick Actions Card
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            "Daily Supplement Tracking",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            "Create regimes to quickly log your daily supplements",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        
                        if (uiState.activeRegimes.isNotEmpty()) {
                            Divider(modifier = Modifier.padding(vertical = 8.dp))
                            Text(
                                "Quick Log Today's Supplements:",
                                style = MaterialTheme.typography.labelLarge
                            )
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                for (regime in uiState.activeRegimes) {
                                    AssistChip(
                                        onClick = { 
                                            viewModel.logRegimeForToday(regime)
                                            navController.navigate("diary")
                                        },
                                        label = { Text(regime.name) },
                                        leadingIcon = {
                                            Icon(
                                                Icons.Default.CheckCircle,
                                                contentDescription = null,
                                                modifier = Modifier.size(18.dp)
                                            )
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            
            // Active Regimes Section
            if (uiState.activeRegimes.isNotEmpty()) {
                item {
                    Text(
                        "Active Regimes",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
                
                items(uiState.activeRegimes.size) { index ->
                    val regime = uiState.activeRegimes[index]
                    RegimeCard(
                        regime = regime,
                        onEdit = { selectedRegimeForEdit = regime },
                        onToggleActive = { viewModel.toggleRegimeActive(regime) },
                        onDelete = { viewModel.deleteRegime(regime) },
                        onLogToday = { 
                            viewModel.logRegimeForToday(regime)
                            navController.navigate("diary")
                        }
                    )
                }
            }
            
            // Inactive Regimes Section
            if (uiState.inactiveRegimes.isNotEmpty()) {
                item {
                    Text(
                        "Inactive Regimes",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 16.dp)
                    )
                }
                
                items(uiState.inactiveRegimes.size) { index ->
                    val regime = uiState.inactiveRegimes[index]
                    RegimeCard(
                        regime = regime,
                        onEdit = { selectedRegimeForEdit = regime },
                        onToggleActive = { viewModel.toggleRegimeActive(regime) },
                        onDelete = { viewModel.deleteRegime(regime) },
                        onLogToday = null // Don't show log button for inactive regimes
                    )
                }
            }
            
            // Empty State
            if (uiState.activeRegimes.isEmpty() && uiState.inactiveRegimes.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 48.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            Icon(
                                Icons.Default.MedicalServices,
                                contentDescription = null,
                                modifier = Modifier.size(64.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                "No supplement regimes yet",
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Button(onClick = { showAddRegimeDialog = true }) {
                                Icon(Icons.Default.Add, contentDescription = null)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Create Your First Regime")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Add/Edit Regime Dialog
    if (showAddRegimeDialog || selectedRegimeForEdit != null) {
        AddEditRegimeDialog(
            regime = selectedRegimeForEdit,
            onDismiss = { 
                showAddRegimeDialog = false
                selectedRegimeForEdit = null
            },
            onSave = { regime ->
                if (selectedRegimeForEdit != null) {
                    viewModel.updateRegime(regime)
                } else {
                    viewModel.addRegime(regime)
                }
                showAddRegimeDialog = false
                selectedRegimeForEdit = null
            },
            onScanBarcode = { showBarcodeScanner = true }
        )
    }
    
    // Barcode Scanner Dialog
    if (showBarcodeScanner) {
        BarcodeScannerDialog(
            onBarcodeScanned = { barcode ->
                // Handle barcode result
                showBarcodeScanner = false
            },
            onDismiss = { showBarcodeScanner = false }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegimeCard(
    regime: SupplementRegime,
    onEdit: () -> Unit,
    onToggleActive: () -> Unit,
    onDelete: () -> Unit,
    onLogToday: (() -> Unit)?
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = if (regime.isActive) {
            CardDefaults.cardColors()
        } else {
            CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surfaceVariant
            )
        }
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        regime.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        "${regime.supplements.size} supplements",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                
                Row {
                    IconButton(onClick = onEdit) {
                        Icon(Icons.Default.Edit, contentDescription = "Edit")
                    }
                    IconButton(onClick = onToggleActive) {
                        Icon(
                            if (regime.isActive) Icons.Default.Pause else Icons.Default.PlayArrow,
                            contentDescription = if (regime.isActive) "Deactivate" else "Activate"
                        )
                    }
                    IconButton(onClick = onDelete) {
                        Icon(Icons.Default.Delete, contentDescription = "Delete")
                    }
                }
            }
            
            // Supplement List
            if (regime.supplements.isNotEmpty()) {
                Column(
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    regime.supplements.forEach { supplement ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                Icons.Default.Circle,
                                contentDescription = null,
                                modifier = Modifier.size(8.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                "${supplement.name} - ${supplement.servingCount} ${supplement.servingUnit}",
                                style = MaterialTheme.typography.bodySmall
                            )
                        }
                    }
                }
            }
            
            // Log Today Button
            if (onLogToday != null && regime.isActive) {
                Button(
                    onClick = onLogToday,
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    )
                ) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Log Today")
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditRegimeDialog(
    regime: SupplementRegime?,
    onDismiss: () -> Unit,
    onSave: (SupplementRegime) -> Unit,
    onScanBarcode: () -> Unit
) {
    var name by remember { mutableStateOf(regime?.name ?: "") }
    var supplements by remember { mutableStateOf(regime?.supplements ?: emptyList()) }
    var showAddSupplementDialog by remember { mutableStateOf(false) }
    
    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 600.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    if (regime != null) "Edit Regime" else "Create New Regime",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
                
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Regime Name") },
                    placeholder = { Text("e.g., Morning Vitamins") },
                    modifier = Modifier.fillMaxWidth()
                )
                
                // Supplements List
                Column(
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Supplements",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            IconButton(onClick = onScanBarcode) {
                                Icon(Icons.Default.QrCodeScanner, contentDescription = "Scan Barcode")
                            }
                            IconButton(onClick = { showAddSupplementDialog = true }) {
                                Icon(Icons.Default.Add, contentDescription = "Add Supplement")
                            }
                        }
                    }
                    
                    if (supplements.isEmpty()) {
                        Text(
                            "No supplements added yet",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    } else {
                        supplements.forEach { supplement ->
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                colors = CardDefaults.cardColors(
                                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                                )
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(12.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(
                                            supplement.name,
                                            style = MaterialTheme.typography.bodyLarge,
                                            fontWeight = FontWeight.Medium
                                        )
                                        Text(
                                            "${supplement.servingCount} ${supplement.servingUnit}",
                                            style = MaterialTheme.typography.bodySmall
                                        )
                                    }
                                    IconButton(
                                        onClick = {
                                            supplements = supplements.filter { it != supplement }
                                        }
                                    ) {
                                        Icon(
                                            Icons.Default.Close,
                                            contentDescription = "Remove",
                                            tint = MaterialTheme.colorScheme.error
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    TextButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Cancel")
                    }
                    Button(
                        onClick = {
                            val newRegime = regime?.copy(
                                name = name,
                                supplements = supplements,
                                updatedAt = System.currentTimeMillis()
                            ) ?: SupplementRegime(
                                name = name,
                                supplements = supplements
                            )
                            onSave(newRegime)
                        },
                        modifier = Modifier.weight(1f),
                        enabled = name.isNotBlank() && supplements.isNotEmpty()
                    ) {
                        Text("Save")
                    }
                }
            }
        }
    }
    
    // Add Supplement Sub-Dialog
    if (showAddSupplementDialog) {
        AddSupplementToRegimeDialog(
            onDismiss = { showAddSupplementDialog = false },
            onAdd = { supplement ->
                supplements = supplements + supplement
                showAddSupplementDialog = false
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddSupplementToRegimeDialog(
    onDismiss: () -> Unit,
    onAdd: (RegimeSupplement) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var brand by remember { mutableStateOf("") }
    var servingSize by remember { mutableStateOf("1") }
    var servingUnit by remember { mutableStateOf("tablet") }
    
    Dialog(onDismissRequest = onDismiss) {
        Card {
            Column(
                modifier = Modifier.padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    "Add Supplement",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
                
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Supplement Name") },
                    modifier = Modifier.fillMaxWidth()
                )
                
                OutlinedTextField(
                    value = brand,
                    onValueChange = { brand = it },
                    label = { Text("Brand (Optional)") },
                    modifier = Modifier.fillMaxWidth()
                )
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = servingSize,
                        onValueChange = { servingSize = it },
                        label = { Text("Amount") },
                        modifier = Modifier.weight(1f)
                    )
                    
                    OutlinedTextField(
                        value = servingUnit,
                        onValueChange = { servingUnit = it },
                        label = { Text("Unit") },
                        modifier = Modifier.weight(1f)
                    )
                }
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    TextButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Cancel")
                    }
                    Button(
                        onClick = {
                            onAdd(
                                RegimeSupplement(
                                    name = name,
                                    brand = brand.takeIf { it.isNotBlank() },
                                    servingSize = servingSize,
                                    servingUnit = servingUnit,
                                    servingCount = servingSize.toDoubleOrNull() ?: 1.0
                                )
                            )
                        },
                        modifier = Modifier.weight(1f),
                        enabled = name.isNotBlank()
                    ) {
                        Text("Add")
                    }
                }
            }
        }
    }
}

@Composable
fun BarcodeScannerDialog(
    onBarcodeScanned: (String) -> Unit,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val cameraProviderFuture = remember { ProcessCameraProvider.getInstance(context) }
    var hasCameraPermission by remember { mutableStateOf(false) }
    
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission(),
        onResult = { isGranted ->
            hasCameraPermission = isGranted
        }
    )
    
    LaunchedEffect(Unit) {
        val permission = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.CAMERA
        )
        hasCameraPermission = permission == android.content.pm.PackageManager.PERMISSION_GRANTED
        if (!hasCameraPermission) {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }
    
    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .height(400.dp)
        ) {
            if (hasCameraPermission) {
                AndroidView(
                    factory = { context ->
                        val previewView = PreviewView(context)
                        val executor = Executors.newSingleThreadExecutor()
                        
                        cameraProviderFuture.addListener({
                            val cameraProvider = cameraProviderFuture.get()
                            val preview = Preview.Builder().build().also {
                                it.setSurfaceProvider(previewView.surfaceProvider)
                            }
                            
                            val imageAnalyzer = ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build()
                                .also {
                                    it.setAnalyzer(executor) { imageProxy ->
                                        val scanner = BarcodeScanning.getClient()
                                        val mediaImage = imageProxy.image
                                        if (mediaImage != null) {
                                            val image = InputImage.fromMediaImage(
                                                mediaImage,
                                                imageProxy.imageInfo.rotationDegrees
                                            )
                                            scanner.process(image)
                                                .addOnSuccessListener { barcodes ->
                                                    barcodes.firstOrNull()?.let { barcode ->
                                                        barcode.rawValue?.let { value ->
                                                            onBarcodeScanned(value)
                                                        }
                                                    }
                                                }
                                                .addOnCompleteListener {
                                                    imageProxy.close()
                                                }
                                        }
                                    }
                                }
                            
                            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
                            
                            try {
                                cameraProvider.unbindAll()
                                cameraProvider.bindToLifecycle(
                                    lifecycleOwner,
                                    cameraSelector,
                                    preview,
                                    imageAnalyzer
                                )
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }, ContextCompat.getMainExecutor(context))
                        
                        previewView
                    },
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text("Camera permission required")
                }
            }
        }
    }
}