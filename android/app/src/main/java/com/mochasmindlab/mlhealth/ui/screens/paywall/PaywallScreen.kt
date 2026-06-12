package com.mochasmindlab.mlhealth.ui.screens.paywall

import android.app.Activity
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.services.BillingManager
import com.mochasmindlab.mlhealth.services.ConnectionState
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.ui.theme.NutritionGreen
import com.mochasmindlab.mlhealth.ui.theme.SuccessGreen
import com.mochasmindlab.mlhealth.viewmodel.PaywallViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PaywallScreen(
    navController: NavController,
    viewModel: PaywallViewModel = hiltViewModel()
) {
    val billing = viewModel.billing
    val connectionState by billing.connectionState.collectAsStateWithLifecycle()
    val productDetails by billing.proProductDetails.collectAsStateWithLifecycle()
    val isPro by billing.isProUser.collectAsStateWithLifecycle()

    val activity = LocalContext.current as? Activity

    val formattedPrice = productDetails
        ?.oneTimePurchaseOfferDetails
        ?.formattedPrice
        ?: "$6.99"

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MindLab Fitness Pro") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(
                            Icons.Default.Close,
                            contentDescription = "Close"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        }
    ) { paddingValues ->
        if (connectionState == ConnectionState.Connecting) {
            // Show a full-screen loading indicator while billing client initialises.
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    CircularProgressIndicator(color = MochaBrown)
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "Connecting to store…",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            return@Scaffold
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
        ) {

            // ---- Hero gradient header -----------------------------------
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.linearGradient(
                            colors = listOf(MochaBrown, NutritionGreen)
                        )
                    )
                    .padding(vertical = 32.dp, horizontal = 24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(56.dp)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "MindLab Fitness Pro",
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "The AI-powered nutrition coach in your pocket.",
                        style = MaterialTheme.typography.bodyMedium.copy(color = Color.White.copy(alpha = 0.9f)),
                        textAlign = TextAlign.Center
                    )

                    // "Already Pro" badge
                    if (isPro) {
                        Spacer(modifier = Modifier.height(12.dp))
                        Surface(
                            shape = RoundedCornerShape(20.dp),
                            color = SuccessGreen,
                            modifier = Modifier.padding(horizontal = 8.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            ) {
                                Icon(
                                    Icons.Default.CheckCircle,
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Already Pro",
                                    color = Color.White,
                                    fontWeight = FontWeight.SemiBold,
                                    fontSize = 13.sp
                                )
                            }
                        }
                    }
                }
            }

            // ---- Stat strip (social proof) --------------------------------
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .padding(vertical = 14.dp, horizontal = 24.dp),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                ProStat(value = "400+", label = "Recipes")
                Divider(
                    modifier = Modifier
                        .height(28.dp)
                        .width(1.dp)
                )
                ProStat(value = "8", label = "Diet plans")
                Divider(
                    modifier = Modifier
                        .height(28.dp)
                        .width(1.dp)
                )
                ProStat(value = "AI", label = "Meal scanner")
            }

            Spacer(modifier = Modifier.height(24.dp))

            // ---- Feature blocks ------------------------------------------
            Column(
                modifier = Modifier.padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                ProFeatureBlock(
                    icon = Icons.Default.CameraAlt,
                    title = "AI Meal Scanner",
                    description = "Unlimited photo scans — point your camera at any meal and AI logs macros instantly."
                )
                ProFeatureBlock(
                    icon = Icons.Default.CalendarMonth,
                    title = "All 8 Meal Plans",
                    description = "400+ recipes vs Mediterranean only — 4 weeks each with grocery lists."
                )
                ProFeatureBlock(
                    icon = Icons.Default.AutoAwesome,
                    title = "All Future Pro Features",
                    description = "Every feature we add to Pro is yours forever — one payment, lifetime access."
                )
            }

            Spacer(modifier = Modifier.height(28.dp))

            // ---- CTAs -------------------------------------------------------
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Primary — Unlock Pro
                if (!isPro) {
                    Button(
                        onClick = {
                            activity?.let { billing.launchPurchaseFlow(it) }
                        },
                        enabled = productDetails != null && activity != null,
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = MochaBrown),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp)
                    ) {
                        Text(
                            text = "Unlock Pro · $formattedPrice",
                            fontWeight = FontWeight.Bold,
                            fontSize = 16.sp
                        )
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(
                        text = "One-time purchase · no subscription",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Restore Purchases link
                    TextButton(
                        onClick = {
                            viewModel.restorePurchases()
                        }
                    ) {
                        Text(
                            text = "Restore Purchase",
                            color = MochaBrown
                        )
                    }
                } else {
                    // Already Pro state
                    Button(
                        onClick = { navController.navigateUp() },
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp)
                    ) {
                        Icon(Icons.Default.CheckCircle, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("You're Pro — Enjoy!", fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(modifier = Modifier.height(36.dp))
        }
    }
}

// ---- Supporting composables ------------------------------------------------

@Composable
private fun ProStat(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            style = MaterialTheme.typography.titleMedium.copy(
                fontWeight = FontWeight.Bold,
                color = MochaBrown
            )
        )
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun ProFeatureBlock(
    icon: ImageVector,
    title: String,
    description: String
) {
    Row(
        verticalAlignment = Alignment.Top,
        modifier = Modifier.fillMaxWidth()
    ) {
        Surface(
            shape = RoundedCornerShape(8.dp),
            color = MochaBrown.copy(alpha = 0.12f),
            modifier = Modifier.size(40.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MochaBrown,
                    modifier = Modifier.size(22.dp)
                )
            }
        }

        Spacer(modifier = Modifier.width(14.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold)
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
