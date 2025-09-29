package com.mochasmindlab.mlhealth.services

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.mochasmindlab.mlhealth.data.models.FoodItem
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

@Composable
fun FoodBarcodeScannerScreen(
    onFoodFound: (FoodItem) -> Unit,
    onManualEntry: () -> Unit,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val coroutineScope = rememberCoroutineScope()
    val foodBarcodeService = remember { FoodBarcodeService() }

    var hasCameraPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        )
    }

    var scannedBarcode by remember { mutableStateOf<String?>(null) }
    var isProcessing by remember { mutableStateOf(false) }
    var scanResult by remember { mutableStateOf<ScanResult?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasCameraPermission = isGranted
    }

    LaunchedEffect(Unit) {
        if (!hasCameraPermission) {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    // Handle barcode scanning
    LaunchedEffect(scannedBarcode) {
        scannedBarcode?.let { barcode ->
            if (!isProcessing) {
                isProcessing = true
                scanResult = ScanResult.Loading
                
                coroutineScope.launch {
                    try {
                        val foodItem = foodBarcodeService.lookupBarcode(barcode)
                        if (foodItem != null) {
                            scanResult = ScanResult.Success(foodItem)
                            delay(500) // Show success briefly
                            onFoodFound(foodItem)
                        } else {
                            scanResult = ScanResult.NotFound
                            delay(3000)
                            scanResult = null
                            scannedBarcode = null
                        }
                    } catch (e: Exception) {
                        scanResult = ScanResult.Error(e.message ?: "Network error")
                        delay(3000)
                        scanResult = null
                        scannedBarcode = null
                    } finally {
                        isProcessing = false
                    }
                }
            }
        }
    }

    if (hasCameraPermission) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Camera preview
            CameraPreview(
                onBarcodeScanned = { barcode ->
                    if (!isProcessing) {
                        scannedBarcode = barcode
                    }
                },
                lifecycleOwner = lifecycleOwner
            )

            // Scanning overlay
            ScannerOverlay(
                scanResult = scanResult,
                onManualEntry = onManualEntry,
                onDismiss = onDismiss
            )
        }
    } else {
        // No camera permission screen
        NoCameraPermissionScreen(
            onRequestPermission = {
                permissionLauncher.launch(Manifest.permission.CAMERA)
            },
            onDismiss = onDismiss
        )
    }
}

@Composable
private fun CameraPreview(
    onBarcodeScanned: (String) -> Unit,
    lifecycleOwner: androidx.lifecycle.LifecycleOwner
) {
    val context = LocalContext.current
    var cameraExecutor by remember { mutableStateOf<ExecutorService?>(null) }

    DisposableEffect(Unit) {
        cameraExecutor = Executors.newSingleThreadExecutor()
        onDispose {
            cameraExecutor?.shutdown()
        }
    }

    AndroidView(
        factory = { ctx ->
            val previewView = PreviewView(ctx)
            val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)

            cameraProviderFuture.addListener({
                val cameraProvider = cameraProviderFuture.get()
                val preview = Preview.Builder().build().also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }

                val imageAnalyzer = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .build()
                    .also { imageAnalysis ->
                        imageAnalysis.setAnalyzer(cameraExecutor!!) { imageProxy ->
                            processImageProxy(imageProxy, onBarcodeScanned)
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
                    // Handle error
                }
            }, ContextCompat.getMainExecutor(ctx))

            previewView
        },
        modifier = Modifier.fillMaxSize()
    )
}

@androidx.annotation.OptIn(ExperimentalGetImage::class)
private fun processImageProxy(
    imageProxy: ImageProxy,
    onBarcodeScanned: (String) -> Unit
) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
        val image = InputImage.fromMediaImage(
            mediaImage,
            imageProxy.imageInfo.rotationDegrees
        )

        val scanner = BarcodeScanning.getClient()
        scanner.process(image)
            .addOnSuccessListener { barcodes ->
                for (barcode in barcodes) {
                    when (barcode.format) {
                        Barcode.FORMAT_UPC_A,
                        Barcode.FORMAT_UPC_E,
                        Barcode.FORMAT_EAN_13,
                        Barcode.FORMAT_EAN_8 -> {
                            barcode.rawValue?.let { value ->
                                onBarcodeScanned(value)
                            }
                        }
                    }
                }
            }
            .addOnCompleteListener {
                imageProxy.close()
            }
    } else {
        imageProxy.close()
    }
}

@Composable
private fun ScannerOverlay(
    scanResult: ScanResult?,
    onManualEntry: () -> Unit,
    onDismiss: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.SpaceBetween,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top section with instructions
        Card(
            modifier = Modifier.padding(top = 50.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f)
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.QrCodeScanner,
                    contentDescription = null,
                    tint = MochaBrown,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = "Align barcode within camera view",
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }

        // Center scanning frame
        Box(
            modifier = Modifier
                .size(250.dp)
                .border(2.dp, MochaBrown, RoundedCornerShape(16.dp))
                .clip(RoundedCornerShape(16.dp))
                .background(Color.Transparent),
            contentAlignment = Alignment.Center
        ) {
            // Scanning corners
            ScanningCorners()
        }

        // Bottom section with status and controls
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(bottom = 50.dp)
        ) {
            // Status display
            when (scanResult) {
                is ScanResult.Loading -> {
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.primaryContainer
                        )
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(20.dp),
                                color = MochaBrown
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(
                                "Looking up food...",
                                color = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        }
                    }
                }
                is ScanResult.Success -> {
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = Color(0xFF4CAF50)
                        )
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Column {
                                Text(
                                    "Found: ${scanResult.foodItem.name}",
                                    color = Color.White,
                                    fontWeight = FontWeight.Bold
                                )
                                scanResult.foodItem.brand?.let {
                                    Text(
                                        it,
                                        color = Color.White.copy(alpha = 0.9f),
                                        style = MaterialTheme.typography.bodySmall
                                    )
                                }
                            }
                        }
                    }
                }
                is ScanResult.NotFound -> {
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.errorContainer
                        )
                    ) {
                        Text(
                            "Food not found. Try manual search.",
                            modifier = Modifier.padding(16.dp),
                            color = MaterialTheme.colorScheme.onErrorContainer
                        )
                    }
                }
                is ScanResult.Error -> {
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.errorContainer
                        )
                    ) {
                        Text(
                            scanResult.message,
                            modifier = Modifier.padding(16.dp),
                            color = MaterialTheme.colorScheme.onErrorContainer
                        )
                    }
                }
                null -> {}
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Control buttons
            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedButton(
                    onClick = onDismiss,
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Icon(Icons.Default.Close, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Cancel")
                }

                Button(
                    onClick = onManualEntry,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MochaBrown
                    )
                ) {
                    Icon(Icons.Default.Search, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Manual Search")
                }
            }
        }
    }
}

@Composable
private fun ScanningCorners() {
    val cornerSize = 30.dp
    val strokeWidth = 3.dp
    
    Box(modifier = Modifier.fillMaxSize()) {
        // Top-left corner
        Box(
            modifier = Modifier
                .align(Alignment.TopStart)
                .size(cornerSize)
                .border(
                    width = strokeWidth,
                    color = MochaBrown,
                    shape = RoundedCornerShape(topStart = 16.dp)
                )
        )
        
        // Top-right corner
        Box(
            modifier = Modifier
                .align(Alignment.TopEnd)
                .size(cornerSize)
                .border(
                    width = strokeWidth,
                    color = MochaBrown,
                    shape = RoundedCornerShape(topEnd = 16.dp)
                )
        )
        
        // Bottom-left corner
        Box(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .size(cornerSize)
                .border(
                    width = strokeWidth,
                    color = MochaBrown,
                    shape = RoundedCornerShape(bottomStart = 16.dp)
                )
        )
        
        // Bottom-right corner
        Box(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .size(cornerSize)
                .border(
                    width = strokeWidth,
                    color = MochaBrown,
                    shape = RoundedCornerShape(bottomEnd = 16.dp)
                )
        )
    }
}

@Composable
private fun NoCameraPermissionScreen(
    onRequestPermission: () -> Unit,
    onDismiss: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            Icons.Default.CameraAlt,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MochaBrown
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        Text(
            text = "Camera Permission Required",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Text(
            text = "To scan barcodes, ML Fitness needs access to your camera.",
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = onRequestPermission,
            colors = ButtonDefaults.buttonColors(
                containerColor = MochaBrown
            ),
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Check, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text("Grant Permission")
        }

        Spacer(modifier = Modifier.height(8.dp))

        TextButton(
            onClick = onDismiss,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Cancel")
        }
    }
}

// Scan result states
private sealed class ScanResult {
    object Loading : ScanResult()
    data class Success(val foodItem: FoodItem) : ScanResult()
    object NotFound : ScanResult()
    data class Error(val message: String) : ScanResult()
}