package com.mlhealth.app.services

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.mlhealth.app.data.Supplement
import com.mlhealth.app.data.SupplementDatabase
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

// Barcode scanner service
class SupplementBarcodeScanner(private val context: Context) {
    private var cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var onBarcodeScanned: ((String) -> Unit)? = null

    fun setOnBarcodeScannedListener(listener: (String) -> Unit) {
        onBarcodeScanned = listener
    }

    fun shutdown() {
        cameraExecutor.shutdown()
    }

    @androidx.annotation.OptIn(ExperimentalGetImage::class)
    fun createImageAnalyzer(): ImageAnalysis {
        return ImageAnalysis.Builder()
            .build()
            .also { imageAnalysis ->
                imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
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
                                    barcode.rawValue?.let { value ->
                                        onBarcodeScanned?.invoke(value)
                                    }
                                }
                            }
                            .addOnFailureListener {
                                // Handle failure
                            }
                            .addOnCompleteListener {
                                imageProxy.close()
                            }
                    }
                }
            }
    }
}

// Composable UI for barcode scanning
@Composable
fun SupplementBarcodeScannerScreen(
    onSupplementFound: (Supplement) -> Unit,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val coroutineScope = rememberCoroutineScope()

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

                // First try local database for quick lookup
                var supplement = SupplementDatabase.searchByBarcode(barcode)
                    ?: SupplementDatabase.searchByDPN(barcode)

                if (supplement != null) {
                    onSupplementFound(supplement)
                } else {
                    // Try NIH and other APIs
                    coroutineScope.launch {
                        try {
                            val apiService = com.mochasmindlab.mlhealth.services.SupplementAPIService()
                            val apiResult = apiService.lookupSupplement(barcode)

                            if (apiResult != null) {
                                // Convert API result to local Supplement format
                                val newSupplement = Supplement(
                                    id = "api-${barcode}",
                                    name = apiResult.name,
                                    brand = apiResult.brand ?: "Unknown",
                                    category = "Supplement",
                                    description = "Found via ${apiResult.source}",
                                    servingSize = apiResult.servingSize ?: "See bottle",
                                    barcode = barcode,
                                    vitamins = VitaminContent(), // Parse from nutrients map
                                    minerals = MineralContent(), // Parse from nutrients map
                                    otherIngredients = apiResult.ingredients
                                )

                                // Add to local database for future quick access
                                SupplementDatabase.addCustomSupplement(newSupplement)
                                onSupplementFound(newSupplement)
                            } else {
                                errorMessage = "Supplement not found. Try manual entry."
                                delay(3000)
                                errorMessage = null
                                scannedBarcode = null
                            }
                        } catch (e: Exception) {
                            errorMessage = "Error looking up supplement: ${e.message}"
                            delay(3000)
                            errorMessage = null
                            scannedBarcode = null
                        }
                    }
                }

                isProcessing = false
            }
        }
    }

    if (hasCameraPermission) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Camera preview
            AndroidView(
                factory = { ctx ->
                    val previewView = PreviewView(ctx)
                    val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                    val scanner = SupplementBarcodeScanner(ctx)

                    scanner.setOnBarcodeScannedListener { barcode ->
                        if (!isProcessing) {
                            scannedBarcode = barcode
                        }
                    }

                    cameraProviderFuture.addListener({
                        val cameraProvider = cameraProviderFuture.get()
                        val preview = Preview.Builder().build().also {
                            it.setSurfaceProvider(previewView.surfaceProvider)
                        }

                        val imageAnalyzer = scanner.createImageAnalyzer()

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

            // Scanning overlay
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Top instructions
                Card(
                    modifier = Modifier.padding(top = 50.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.9f)
                    )
                ) {
                    Text(
                        text = "Align barcode within camera view",
                        modifier = Modifier.padding(16.dp),
                        style = MaterialTheme.typography.bodyLarge
                    )
                }

                // Bottom controls
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(bottom = 50.dp)
                ) {
                    if (isProcessing) {
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.9f)
                            )
                        ) {
                            Row(
                                modifier = Modifier.padding(16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(24.dp)
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Text("Looking up supplement...")
                            }
                        }
                    }

                    errorMessage?.let { error ->
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.errorContainer
                            ),
                            modifier = Modifier.padding(vertical = 8.dp)
                        ) {
                            Text(
                                text = error,
                                modifier = Modifier.padding(16.dp),
                                color = MaterialTheme.colorScheme.onErrorContainer
                            )
                        }
                    }

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                        modifier = Modifier.padding(top = 16.dp)
                    ) {
                        Button(
                            onClick = onDismiss,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = MaterialTheme.colorScheme.error
                            )
                        ) {
                            Text("Cancel")
                        }

                        Button(
                            onClick = {
                                // Navigate to manual entry
                            }
                        ) {
                            Text("Manual Entry")
                        }
                    }
                }
            }
        }
    } else {
        // No camera permission
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Camera permission is required to scan barcodes",
                style = MaterialTheme.typography.bodyLarge
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = {
                    permissionLauncher.launch(Manifest.permission.CAMERA)
                }
            ) {
                Text("Grant Permission")
            }

            TextButton(
                onClick = onDismiss
            ) {
                Text("Cancel")
            }
        }
    }
}