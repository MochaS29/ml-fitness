package com.mochasmindlab.mlhealth.ui.screens.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.utils.DemoDataGenerator
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import kotlinx.coroutines.launch
import androidx.hilt.navigation.compose.hiltViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    navController: NavController,
    preferencesManager: PreferencesManager? = null,
    demoDataGenerator: DemoDataGenerator? = null
) {
    var isDarkMode by remember { mutableStateOf(false) }
    var notificationsEnabled by remember { mutableStateOf(true) }
    var waterReminders by remember { mutableStateOf(true) }
    var mealReminders by remember { mutableStateOf(true) }
    var exerciseReminders by remember { mutableStateOf(false) }
    var showDemoDataDialog by remember { mutableStateOf(false) }
    var showClearDataDialog by remember { mutableStateOf(false) }
    var isGeneratingData by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()

    // Load preferences
    LaunchedEffect(preferencesManager) {
        preferencesManager?.let {
            launch {
                it.notificationsEnabled.collect { enabled ->
                    notificationsEnabled = enabled
                }
            }
            launch {
                it.waterReminderEnabled.collect { enabled ->
                    waterReminders = enabled
                }
            }
            launch {
                it.mealReminderEnabled.collect { enabled ->
                    mealReminders = enabled
                }
            }
            launch {
                it.exerciseReminderEnabled.collect { enabled ->
                    exerciseReminders = enabled
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
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
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Appearance Section
            item {
                SettingsSection(title = "Appearance") {
                    SettingsToggleItem(
                        icon = Icons.Default.DarkMode,
                        title = "Dark Mode",
                        subtitle = "Use dark theme",
                        checked = isDarkMode,
                        onCheckedChange = { isDarkMode = it }
                    )
                }
            }

            // Notifications Section
            item {
                SettingsSection(title = "Notifications") {
                    SettingsToggleItem(
                        icon = Icons.Default.Notifications,
                        title = "Enable Notifications",
                        subtitle = "Allow app to send notifications",
                        checked = notificationsEnabled,
                        onCheckedChange = { enabled ->
                            notificationsEnabled = enabled
                            coroutineScope.launch {
                                preferencesManager?.setNotificationsEnabled(enabled)
                            }
                        }
                    )

                    if (notificationsEnabled) {
                        Divider(modifier = Modifier.padding(vertical = 8.dp))

                        SettingsToggleItem(
                            icon = Icons.Default.WaterDrop,
                            title = "Water Reminders",
                            subtitle = "Remind to drink water",
                            checked = waterReminders,
                            onCheckedChange = { enabled ->
                                waterReminders = enabled
                                coroutineScope.launch {
                                    preferencesManager?.setWaterReminderEnabled(enabled)
                                }
                            },
                            enabled = notificationsEnabled
                        )

                        SettingsToggleItem(
                            icon = Icons.Default.Restaurant,
                            title = "Meal Reminders",
                            subtitle = "Remind to log meals",
                            checked = mealReminders,
                            onCheckedChange = { enabled ->
                                mealReminders = enabled
                                coroutineScope.launch {
                                    preferencesManager?.setMealReminderEnabled(enabled)
                                }
                            },
                            enabled = notificationsEnabled
                        )

                        SettingsToggleItem(
                            icon = Icons.Default.FitnessCenter,
                            title = "Exercise Reminders",
                            subtitle = "Remind to work out",
                            checked = exerciseReminders,
                            onCheckedChange = { enabled ->
                                exerciseReminders = enabled
                                coroutineScope.launch {
                                    preferencesManager?.setExerciseReminderEnabled(enabled)
                                }
                            },
                            enabled = notificationsEnabled
                        )
                    }
                }
            }

            // Data & Privacy Section
            item {
                SettingsSection(title = "Data & Privacy") {
                    SettingsClickableItem(
                        icon = Icons.Default.Science,
                        title = "Generate Demo Data",
                        subtitle = "Fill app with sample data for testing",
                        onClick = { showDemoDataDialog = true }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.DeleteForever,
                        title = "Clear All Data",
                        subtitle = "Remove all stored data",
                        onClick = { showClearDataDialog = true },
                        textColor = MaterialTheme.colorScheme.error
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.Download,
                        title = "Export Data",
                        subtitle = "Download your data",
                        onClick = { navController.navigate("export") }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.Shield,
                        title = "Privacy Policy",
                        subtitle = "View privacy policy",
                        onClick = { navController.navigate("privacy") }
                    )
                }
            }

            // Account Section
            item {
                SettingsSection(title = "Account") {
                    SettingsClickableItem(
                        icon = Icons.Default.Person,
                        title = "Profile",
                        subtitle = "Edit your profile",
                        onClick = { navController.navigate("profile") }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.Star,
                        title = "Goals",
                        subtitle = "Update your fitness goals",
                        onClick = { navController.navigate("goals") }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.Logout,
                        title = "Sign Out",
                        subtitle = "Sign out of your account",
                        onClick = { /* TODO: Implement sign out */ }
                    )
                }
            }

            // About Section
            item {
                SettingsSection(title = "About") {
                    SettingsClickableItem(
                        icon = Icons.Default.Info,
                        title = "About ML Fitness",
                        subtitle = "Version 1.5.0",
                        onClick = { navController.navigate("about") }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.Help,
                        title = "Help & Support",
                        subtitle = "Get help with the app",
                        onClick = { navController.navigate("help") }
                    )

                    SettingsClickableItem(
                        icon = Icons.Default.RateReview,
                        title = "Rate App",
                        subtitle = "Share your feedback",
                        onClick = { /* TODO: Open app store */ }
                    )
                }
            }
        }
    }

    // Dialogs
    if (showDemoDataDialog) {
        AlertDialog(
            onDismissRequest = { showDemoDataDialog = false },
            title = { Text("Generate Demo Data") },
            text = {
                Text("This will add 30 days of sample data to help you explore the app's features. Continue?")
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showDemoDataDialog = false
                        isGeneratingData = true
                        coroutineScope.launch {
                            demoDataGenerator?.generateDemoData(30)
                            isGeneratingData = false
                        }
                    }
                ) {
                    Text("Generate")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDemoDataDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    if (showClearDataDialog) {
        AlertDialog(
            onDismissRequest = { showClearDataDialog = false },
            title = {
                Text(
                    "Clear All Data",
                    color = MaterialTheme.colorScheme.error
                )
            },
            text = {
                Text("This will permanently delete all your data. This action cannot be undone. Are you sure?")
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showClearDataDialog = false
                        coroutineScope.launch {
                            // TODO: Implement clear all data
                            preferencesManager?.clearAllPreferences()
                        }
                    },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Delete All")
                }
            },
            dismissButton = {
                TextButton(onClick = { showClearDataDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Loading overlay
    if (isGeneratingData) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
    }
}

@Composable
fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MochaBrown,
                modifier = Modifier.padding(bottom = 12.dp)
            )
            content()
        }
    }
}

@Composable
fun SettingsToggleItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    enabled: Boolean = true
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = if (enabled) MochaBrown else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f),
            modifier = Modifier.size(24.dp)
        )

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 16.dp)
        ) {
            Text(
                title,
                style = MaterialTheme.typography.bodyLarge,
                color = if (enabled) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
            )
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = if (enabled) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.38f)
            )
        }

        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            enabled = enabled,
            colors = SwitchDefaults.colors(
                checkedThumbColor = MochaBrown,
                checkedTrackColor = MochaBrown.copy(alpha = 0.5f)
            )
        )
    }
}

@Composable
fun SettingsClickableItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    textColor: androidx.compose.ui.graphics.Color = MaterialTheme.colorScheme.onSurface
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = if (textColor == MaterialTheme.colorScheme.error) textColor else MochaBrown,
            modifier = Modifier.size(24.dp)
        )

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 16.dp)
        ) {
            Text(
                title,
                style = MaterialTheme.typography.bodyLarge,
                color = textColor
            )
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = if (textColor == MaterialTheme.colorScheme.error)
                    textColor.copy(alpha = 0.7f)
                else
                    MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Icon(
            Icons.Default.ChevronRight,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}