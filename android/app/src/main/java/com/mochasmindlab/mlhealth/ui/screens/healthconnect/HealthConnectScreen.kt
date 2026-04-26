package com.mochasmindlab.mlhealth.ui.screens.healthconnect

import android.content.Intent
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.DirectionsWalk
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.MindLabsPurple
import com.mochasmindlab.mlhealth.ui.theme.StepsGreen
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.HealthConnectState
import com.mochasmindlab.mlhealth.viewmodel.HealthConnectViewModel

/**
 * Health Connect integration screen.
 *
 * Shows different UI per [HealthConnectState]:
 *  - [HealthConnectState.Loading]          — full-screen spinner
 *  - [HealthConnectState.NotInstalled]     — "Install Health Connect" CTA linking to Play Store
 *  - [HealthConnectState.NeedsPermissions] — "Grant access" button triggering the permission contract
 *  - [HealthConnectState.Connected]        — cards showing today's steps and latest weight + Refresh
 *  - [HealthConnectState.Error]            — error message + Retry button
 *
 * PERMISSION NOTE: Android Health Connect requires the permission request to originate from
 * an Activity result. We use [rememberLauncherForActivityResult] with the contract provided
 * by [HealthConnectManager.permissionsContract]. The launcher is registered unconditionally
 * (required by Compose rules) and is only *launched* when the user taps "Grant access".
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HealthConnectScreen(
    navController: NavController,
    viewModel: HealthConnectViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val stepsToday by viewModel.stepsToday.collectAsStateWithLifecycle()
    val latestWeightKg by viewModel.latestWeightKg.collectAsStateWithLifecycle()
    val errorMessage by viewModel.errorMessage.collectAsStateWithLifecycle()

    val context = LocalContext.current

    // Permission launcher must be registered unconditionally per Compose rules.
    // The contract() call is deferred-safe: if HC isn't installed the screen never reaches
    // the NeedsPermissions state so this launcher is never triggered.
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = viewModel.permissionsContract()
    ) { grantedPermissions ->
        viewModel.onPermissionResult(grantedPermissions)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Health Connect") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                actions = {
                    if (state == HealthConnectState.Connected) {
                        IconButton(onClick = { viewModel.refresh() }) {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Refresh"
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MindLabsPurple,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary,
                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentAlignment = Alignment.Center
        ) {
            when (state) {
                HealthConnectState.Loading -> {
                    CircularProgressIndicator(color = MindLabsPurple)
                }

                HealthConnectState.NotInstalled -> {
                    NotInstalledContent(
                        onInstall = {
                            val intent = Intent(
                                Intent.ACTION_VIEW,
                                Uri.parse(viewModel.installPlayStoreLink)
                            )
                            context.startActivity(intent)
                        }
                    )
                }

                HealthConnectState.NeedsPermissions -> {
                    NeedsPermissionsContent(
                        onGrantAccess = {
                            permissionLauncher.launch(viewModel.requiredPermissions)
                        }
                    )
                }

                HealthConnectState.Connected -> {
                    ConnectedContent(
                        stepsToday = stepsToday,
                        latestWeightKg = latestWeightKg,
                        onRefresh = { viewModel.refresh() }
                    )
                }

                HealthConnectState.Error -> {
                    ErrorContent(
                        message = errorMessage ?: "An unexpected error occurred.",
                        onRetry = { viewModel.refresh() }
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Sub-composables per state
// ---------------------------------------------------------------------------

@Composable
private fun NotInstalledContent(onInstall: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.FitnessCenter,
            contentDescription = null,
            modifier = Modifier.size(72.dp),
            tint = MindLabsPurple
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Health Connect Not Installed",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "ML Fitness uses Google Health Connect to sync your steps and weight. " +
                    "Install it from the Play Store to enable this feature.",
            fontSize = 15.sp,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(32.dp))
        Button(
            onClick = onInstall,
            colors = ButtonDefaults.buttonColors(containerColor = MindLabsPurple)
        ) {
            Text("Install Health Connect")
        }
    }
}

@Composable
private fun NeedsPermissionsContent(onGrantAccess: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.FitnessCenter,
            contentDescription = null,
            modifier = Modifier.size(72.dp),
            tint = MochaBrown
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Permissions Required",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "ML Fitness needs permission to read your steps and weight from Health Connect, " +
                    "and to write weight data back. Tap below to grant access.",
            fontSize = 15.sp,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(32.dp))
        Button(
            onClick = onGrantAccess,
            colors = ButtonDefaults.buttonColors(containerColor = MochaBrown)
        ) {
            Text("Grant Access")
        }
    }
}

@Composable
private fun ConnectedContent(
    stepsToday: Long?,
    latestWeightKg: Double?,
    onRefresh: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Health Connect",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = "Connected",
            fontSize = 14.sp,
            color = StepsGreen
        )

        // Steps card
        HealthDataCard(
            icon = Icons.Default.DirectionsWalk,
            iconTint = StepsGreen,
            label = "Steps Today",
            value = stepsToday?.let { "%,d".format(it) } ?: "--"
        )

        // Weight card
        HealthDataCard(
            icon = Icons.Default.FitnessCenter,
            iconTint = MochaBrown,
            label = "Latest Weight",
            value = latestWeightKg?.let { "%.1f kg".format(it) } ?: "No data"
        )

        Spacer(modifier = Modifier.height(8.dp))

        OutlinedButton(
            onClick = onRefresh,
            border = ButtonDefaults.outlinedButtonBorder
        ) {
            Icon(
                imageVector = Icons.Default.Refresh,
                contentDescription = null,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text("Refresh")
        }
    }
}

@Composable
private fun HealthDataCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    iconTint: androidx.compose.ui.graphics.Color,
    label: String,
    value: String
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(36.dp)
            )
            Spacer(modifier = Modifier.width(16.dp))
            Column {
                Text(
                    text = label,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = value,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
private fun ErrorContent(message: String, onRetry: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Warning,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.error
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Something went wrong",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = message,
            fontSize = 14.sp,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(24.dp))
        Button(
            onClick = onRetry,
            colors = ButtonDefaults.buttonColors(containerColor = MindLabsPurple)
        ) {
            Text("Retry")
        }
    }
}

// TODO: Wire this screen into navigation by adding the following route to MLHealthNavHost.kt / MLFitnessNavigation.kt:
//
//   composable("health_connect") {
//       HealthConnectScreen(navController = navController)
//   }
//
// And navigate to it with: navController.navigate("health_connect")
// Entry point could be a tile on the More/Settings screen.
// Also add a <queries> entry in AndroidManifest if not already present (see manifest comments).
