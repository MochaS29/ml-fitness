package com.mochasmindlab.mlhealth.services

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown

/**
 * Shows [content] when the user has Pro access, otherwise shows [lockedContent].
 *
 * Usage:
 *   ProFeatureGate(billing = billingManager, navController = navController) {
 *       MyProScreen()
 *   }
 */
@Composable
fun ProFeatureGate(
    billing: BillingManager,
    navController: NavController,
    content: @Composable () -> Unit,
    lockedContent: @Composable () -> Unit = {
        DefaultLockedOverlay(navController = navController)
    }
) {
    val isPro by billing.isProUser.collectAsState()
    if (isPro) {
        content()
    } else {
        lockedContent()
    }
}

/**
 * Default locked overlay shown when [ProFeatureGate] gates content.
 * Displays a lock icon, "Pro Feature" label, and an "Unlock Pro" button
 * that navigates to the Paywall screen.
 *
 * Pass a null [navController] if you handle navigation yourself via [onUnlockClick].
 */
@Composable
fun DefaultLockedOverlay(
    navController: NavController? = null,
    onUnlockClick: (() -> Unit)? = null
) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(32.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Lock,
                contentDescription = "Locked",
                modifier = Modifier.size(56.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Pro Feature",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onBackground
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "Upgrade to MindLab Fitness Pro to access this feature.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = {
                    when {
                        onUnlockClick != null -> onUnlockClick()
                        navController != null -> navController.navigate("paywall")
                    }
                },
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = MochaBrown),
                modifier = Modifier
                    .fillMaxWidth(0.6f)
                    .height(50.dp)
            ) {
                Text(
                    text = "Unlock Pro",
                    style = MaterialTheme.typography.labelLarge
                )
            }
        }
    }
}
