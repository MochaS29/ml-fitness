package com.mochasmindlab.mlhealth.ui.screens.about

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.OpenInNew
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.BuildConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(navController: NavController) {
    val context = LocalContext.current
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("About") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("🩺", fontSize = 48.sp, modifier = Modifier.align(Alignment.CenterHorizontally))
            Text(
                "MindLab Fitness",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )
            Text(
                "Version ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )

            Spacer(Modifier.height(8.dp))
            Text(
                "An offline-first nutrition + fitness tracker built by Mocha's MindLab. " +
                "Track meals against the USDA Foundation, SR-Legacy, and Branded Foods databases " +
                "(53 000+ items), log workouts, water, sleep, supplements, and weight, and " +
                "(optionally) sync with Health Connect.",
                fontSize = 14.sp,
                lineHeight = 20.sp
            )

            Divider()

            Text("Data sources", fontWeight = FontWeight.SemiBold)
            BulletItem("USDA FoodData Central — Foundation, SR-Legacy, Branded")
            BulletItem("Open Food Facts — barcode lookup")
            BulletItem("Anthropic Claude — AI meal scanner image analysis")
            BulletItem("ML Kit — on-device barcode recognition")
            BulletItem("Health Connect — optional steps / weight sync")

            Divider()

            Text("Links", fontWeight = FontWeight.SemiBold)
            LinkRow(
                label = "Privacy policy",
                url = "https://mochasmindlab.com/privacy.html",
                onOpen = {
                    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(it)))
                }
            )
            LinkRow(
                label = "Support",
                url = "mailto:mocha.shmigelsky@gmail.com",
                onOpen = {
                    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(it)))
                }
            )

            Spacer(Modifier.height(16.dp))
            Text(
                "© 2026 Mocha's MindLab. All rights reserved.",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PrivacyScreen(navController: NavController) {
    val context = LocalContext.current
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Privacy") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                "Your data stays on your device.",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                "MindLab Fitness stores all your logged data — food, water, exercise, " +
                "sleep, weight, supplements — in a local SQLite database on this " +
                "device. We do not run a server and do not see what you log.",
                lineHeight = 20.sp
            )
            Divider()

            Text("What goes off-device", fontWeight = FontWeight.SemiBold)
            BulletItem("AI meal scanner: when you scan a meal, the photo is sent to Anthropic's Claude API for analysis. Photos are not stored after analysis.")
            BulletItem("Barcode lookup: barcodes you scan may be queried against Open Food Facts.")
            BulletItem("In-app purchases: handled by Google Play Billing — we never see your payment details.")
            BulletItem("Health Connect: only enabled if you grant permission. Data is read on-device.")

            Divider()
            Text("Your rights", fontWeight = FontWeight.SemiBold)
            BulletItem("Uninstalling the app deletes all your data.")
            BulletItem("You can export your data any time from More → Export.")
            BulletItem("You can revoke Health Connect access from your phone settings.")

            Spacer(Modifier.height(8.dp))
            TextButton(
                onClick = {
                    context.startActivity(
                        Intent(Intent.ACTION_VIEW, Uri.parse("https://mochasmindlab.com/privacy.html"))
                    )
                }
            ) {
                Icon(Icons.Default.OpenInNew, contentDescription = null)
                Spacer(Modifier.width(8.dp))
                Text("Read the full privacy policy online")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HelpScreen(navController: NavController) {
    val context = LocalContext.current
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Help & Support") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text("Quick tips", fontSize = 18.sp, fontWeight = FontWeight.Bold)
            BulletItem("Tap the centre + button on the bottom bar to log food, water, exercise, weight, supplements, or scan a barcode.")
            BulletItem("Long-press a recipe in the meal plan to log it without opening the detail sheet.")
            BulletItem("Quick Calories on the food search screen lets you log calories without picking a specific food.")
            BulletItem("Set a target on the Goals screen — your dashboard will use it as the new daily goal.")
            BulletItem("Backdate weight entries from the Date field in the Add Weight dialog.")
            BulletItem("Health Connect sync is optional — enable it from More → Health Connect.")

            Divider()
            Text("Get in touch", fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Text("For bug reports, feature requests, or general questions:")
            TextButton(onClick = {
                context.startActivity(
                    Intent(Intent.ACTION_VIEW, Uri.parse("mailto:mocha.shmigelsky@gmail.com?subject=MindLab%20Fitness%20support"))
                )
            }) {
                Icon(Icons.Default.OpenInNew, contentDescription = null)
                Spacer(Modifier.width(8.dp))
                Text("Email support")
            }
        }
    }
}

@Composable
private fun BulletItem(text: String) {
    Row {
        Text("• ", fontWeight = FontWeight.Bold)
        Text(text, fontSize = 14.sp, lineHeight = 20.sp)
    }
}

@Composable
private fun LinkRow(label: String, url: String, onOpen: (String) -> Unit) {
    TextButton(onClick = { onOpen(url) }) {
        Icon(Icons.Default.OpenInNew, contentDescription = null)
        Spacer(Modifier.width(8.dp))
        Text(label)
    }
}
