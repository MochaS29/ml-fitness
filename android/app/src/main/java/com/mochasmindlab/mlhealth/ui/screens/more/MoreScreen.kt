package com.mochasmindlab.mlhealth.ui.screens.more

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import com.mochasmindlab.mlhealth.BuildConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(
    navController: NavController,
    preferencesManager: PreferencesManager? = null
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "More",
                        fontWeight = FontWeight.Bold
                    )
                }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Profile Section
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { navController.navigate("profile") }
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(60.dp)
                                .clip(CircleShape)
                                .background(MochaBrown),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "U",
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                        }

                        Spacer(modifier = Modifier.width(16.dp))

                        Column(
                            modifier = Modifier.weight(1f)
                        ) {
                            Text(
                                text = "User Profile",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "View and edit your profile",
                                fontSize = 14.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        Icon(
                            Icons.Default.ChevronRight,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            // Tracking Tools Section
            item {
                Text(
                    text = "Tracking Tools",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MochaBrown
                )
            }

            val trackingTools = listOf(
                MoreMenuItem("Food Database", Icons.Default.Restaurant) {
                    navController.navigate("food_database")
                },
                MoreMenuItem("Recipe Manager", Icons.Default.MenuBook) {
                    navController.navigate("recipes")
                },
                MoreMenuItem("Progress Charts", Icons.Default.ShowChart) {
                    navController.navigate("progress")
                },
                MoreMenuItem("Goals", Icons.Default.Flag) {
                    navController.navigate("goals")
                }
            )

            items(trackingTools.size) { index ->
                MoreMenuItemCard(
                    item = trackingTools[index],
                    onClick = trackingTools[index].onClick
                )
            }

            // Settings Section
            item {
                Text(
                    text = "Settings",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MochaBrown
                )
            }

            val settingsItems = listOf(
                MoreMenuItem("Reminders", Icons.Default.Notifications) {
                    navController.navigate("reminders")
                },
                MoreMenuItem("Units & Goals", Icons.Default.Settings) {
                    navController.navigate("settings")
                },
                MoreMenuItem("Export Data", Icons.Default.Download) {
                    navController.navigate("export")
                },
                MoreMenuItem("Privacy", Icons.Default.Lock) {
                    navController.navigate("privacy")
                }
            )

            items(settingsItems.size) { index ->
                MoreMenuItemCard(
                    item = settingsItems[index],
                    onClick = settingsItems[index].onClick
                )
            }

            // App Info Section
            item {
                Text(
                    text = "App Info",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MochaBrown
                )
            }

            val appItems = listOf(
                MoreMenuItem("Help & Support", Icons.Default.Help) {
                    navController.navigate("help")
                },
                MoreMenuItem("About", Icons.Default.Info) {
                    navController.navigate("about")
                },
                MoreMenuItem("Rate Us", Icons.Default.Star) {
                    // Open app store
                }
            )

            items(appItems.size) { index ->
                MoreMenuItemCard(
                    item = appItems[index],
                    onClick = appItems[index].onClick
                )
            }

            // Version Info
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Version",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = "1.5.0",
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            // Developer Options (can be hidden in production)
            if (BuildConfig.DEBUG) {
                item {
                    Text(
                        text = "Developer Tools",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.Red
                    )
                }

                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { /* Generate demo data */ },
                        colors = CardDefaults.cardColors(
                            containerColor = Color.Red.copy(alpha = 0.1f)
                        )
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.AutoAwesome,
                                contentDescription = null,
                                tint = Color.Red
                            )
                            Spacer(modifier = Modifier.width(16.dp))
                            Text(
                                text = "Generate Demo Data",
                                fontSize = 16.sp
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun MoreMenuItemCard(
    item: MoreMenuItem,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                item.icon,
                contentDescription = item.title,
                tint = MochaBrown
            )

            Spacer(modifier = Modifier.width(16.dp))

            Text(
                text = item.title,
                fontSize = 16.sp,
                modifier = Modifier.weight(1f)
            )

            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

data class MoreMenuItem(
    val title: String,
    val icon: ImageVector,
    val onClick: () -> Unit
)