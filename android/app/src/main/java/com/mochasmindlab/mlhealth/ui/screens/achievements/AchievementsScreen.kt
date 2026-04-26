package com.mochasmindlab.mlhealth.ui.screens.achievements

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.AchievementCategory
import com.mochasmindlab.mlhealth.data.models.MLAchievement
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.AchievementsViewModel

// ─── Category colours (matching iOS colour intent) ────────────────────────────

private val AchievementCategory.color: Color
    get() = when (this) {
        AchievementCategory.STREAK    -> Color(0xFFEF4444)   // red / flame
        AchievementCategory.LOGGING   -> MochaBrown
        AchievementCategory.WEIGHT    -> MindfulTeal
        AchievementCategory.EXERCISE  -> ExerciseOrange
        AchievementCategory.WATER     -> WaterBlue
        AchievementCategory.MEAL_SCAN -> SupplementPurple
    }

// ─── Icon helper — maps iconName strings to Material icons ────────────────────

private fun iconForName(name: String): ImageVector = when (name) {
    "LocalFireDepartment" -> Icons.Default.Whatshot
    "EmojiEvents"         -> Icons.Default.EmojiEvents
    "Book"                -> Icons.Default.Book
    "Star"                -> Icons.Default.Star
    "FitnessCenter"       -> Icons.Default.FitnessCenter
    "TrendingDown"        -> Icons.Default.TrendingDown
    "DirectionsRun"       -> Icons.Default.DirectionsRun
    "SportsMartialArts"   -> Icons.Default.SportsKabaddi
    "WaterDrop"           -> Icons.Default.WaterDrop
    "CameraAlt"           -> Icons.Default.CameraAlt
    "QrCodeScanner"       -> Icons.Default.QrCodeScanner
    else                  -> Icons.Default.Star
}

// ─── Screen ───────────────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AchievementsScreen(
    navController: NavController,
    viewModel: AchievementsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Achievements", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background),
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            // ── Header card: streak + unlock count ────────────────────────────
            item {
                AchievementsHeaderCard(
                    streakDays = uiState.currentStreak,
                    totalUnlocked = uiState.totalUnlocked,
                    totalAchievements = uiState.totalAchievements
                )
            }

            // ── Categorised sections ──────────────────────────────────────────
            AchievementCategory.values().forEach { category ->
                val entries = uiState.groupedAchievements[category] ?: emptyList()
                if (entries.isNotEmpty()) {
                    // Sticky-style category header (LazyColumn stickyHeader requires
                    // ExperimentalFoundationApi — using a plain item for broad compatibility)
                    item(key = "header_${category.name}") {
                        CategoryHeader(
                            category = category,
                            unlockedCount = entries.count { it.second },
                            totalCount = entries.size
                        )
                    }

                    items(
                        items = entries,
                        key = { (achievement, _) -> achievement.id }
                    ) { (achievement, isUnlocked) ->
                        AchievementRow(
                            achievement = achievement,
                            isUnlocked = isUnlocked,
                            categoryColor = category.color
                        )
                    }
                }
            }
        }
    }
}

// ─── Sub-composables ──────────────────────────────────────────────────────────

@Composable
private fun AchievementsHeaderCard(
    streakDays: Int,
    totalUnlocked: Int,
    totalAchievements: Int
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        colors = CardDefaults.cardColors(containerColor = MochaBrown),
        shape = RoundedCornerShape(16.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Current streak
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Whatshot,
                        contentDescription = "Streak",
                        tint = Color(0xFFFFD700),
                        modifier = Modifier.size(28.dp)
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = "$streakDays",
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
                Text(
                    text = if (streakDays == 1) "day streak" else "day streak",
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }

            Divider(
                modifier = Modifier
                    .height(48.dp)
                    .width(1.dp),
                color = Color.White.copy(alpha = 0.3f)
            )

            // Unlocked count
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.EmojiEvents,
                        contentDescription = "Unlocked",
                        tint = Color(0xFFFFD700),
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = "$totalUnlocked / $totalAchievements",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
                Text(
                    text = "unlocked",
                    fontSize = 12.sp,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }
        }
    }
}

@Composable
private fun CategoryHeader(
    category: AchievementCategory,
    unlockedCount: Int,
    totalCount: Int
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(category.color)
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = category.displayName,
            fontSize = 15.sp,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = "$unlockedCount / $totalCount",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun AchievementRow(
    achievement: MLAchievement,
    isUnlocked: Boolean,
    categoryColor: Color
) {
    var expanded by remember { mutableStateOf(false) }

    val iconTint = if (isUnlocked) categoryColor else Color.Gray.copy(alpha = 0.4f)
    val titleColor = if (isUnlocked) MaterialTheme.colorScheme.onSurface else Color.Gray

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 4.dp)
            .animateContentSize()
            .clickable { expanded = !expanded },
        colors = CardDefaults.cardColors(
            containerColor = if (isUnlocked)
                MaterialTheme.colorScheme.surface
            else
                MaterialTheme.colorScheme.surface.copy(alpha = 0.6f)
        ),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isUnlocked) 2.dp else 0.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Icon circle
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(iconTint.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = iconForName(achievement.iconName),
                        contentDescription = achievement.title,
                        tint = iconTint,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Spacer(Modifier.width(12.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = achievement.title,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Medium,
                        color = titleColor
                    )
                    if (!expanded) {
                        Text(
                            text = if (isUnlocked) "Unlocked" else "Locked",
                            fontSize = 12.sp,
                            color = if (isUnlocked) categoryColor else Color.Gray
                        )
                    }
                }

                // Chevron
                Icon(
                    imageVector = if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = if (expanded) "Collapse" else "Expand",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Expanded description
            if (expanded) {
                Spacer(Modifier.height(10.dp))
                Divider(color = MaterialTheme.colorScheme.outlineVariant)
                Spacer(Modifier.height(10.dp))
                Text(
                    text = achievement.description,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    lineHeight = 18.sp
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    text = if (isUnlocked) "✓ Achieved" else "Not yet achieved",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = if (isUnlocked) categoryColor else Color.Gray
                )
            }
        }
    }
}

// ─── Route wiring TODO ────────────────────────────────────────────────────────
// TODO: Wire this screen in MLFitnessNavigation.kt under the "achievements" route.
// Replace the existing ComingSoonScreen composable for that destination with:
//   composable("achievements") { AchievementsScreen(navController = navController) }
// Also add the import:
//   import com.mochasmindlab.mlhealth.ui.screens.achievements.AchievementsScreen
