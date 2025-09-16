package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.background
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
import com.mochasmindlab.mlhealth.ui.theme.*

data class ExerciseCategory(
    val name: String,
    val icon: ImageVector,
    val color: Color,
    val exercises: List<String>
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExerciseSelectionDialog(
    onDismiss: () -> Unit,
    onExerciseSelected: (String) -> Unit
) {
    val exerciseCategories = listOf(
        ExerciseCategory(
            name = "Cardio",
            icon = Icons.Default.DirectionsRun,
            color = EnergeticOrange,
            exercises = listOf(
                "Running", "Walking", "Cycling", "Swimming", 
                "Elliptical", "Rowing", "Jump Rope", "Stair Climbing"
            )
        ),
        ExerciseCategory(
            name = "Strength",
            icon = Icons.Default.FitnessCenter,
            color = ExerciseGreen,
            exercises = listOf(
                "Weight Training", "Push-ups", "Pull-ups", "Squats",
                "Deadlifts", "Bench Press", "Dumbbell Exercises", "Resistance Bands"
            )
        ),
        ExerciseCategory(
            name = "Flexibility",
            icon = Icons.Default.SelfImprovement,
            color = MindfulTeal,
            exercises = listOf(
                "Yoga", "Pilates", "Stretching", "Tai Chi",
                "Foam Rolling", "Dynamic Stretching"
            )
        ),
        ExerciseCategory(
            name = "Sports",
            icon = Icons.Default.SportsTennis,
            color = BalancedPurple,
            exercises = listOf(
                "Basketball", "Soccer", "Tennis", "Golf",
                "Baseball", "Volleyball", "Badminton", "Hockey"
            )
        ),
        ExerciseCategory(
            name = "HIIT",
            icon = Icons.Default.Bolt,
            color = Color(0xFFFF6B6B),
            exercises = listOf(
                "Circuit Training", "Tabata", "CrossFit", "Bootcamp",
                "Interval Running", "Burpees"
            )
        )
    )

    var selectedCategory by remember { mutableStateOf<ExerciseCategory?>(null) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        contentColor = MaterialTheme.colorScheme.onSurface
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp)
        ) {
            // Header with back button if category is selected
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (selectedCategory != null) {
                    IconButton(
                        onClick = { selectedCategory = null },
                        modifier = Modifier.size(40.dp)
                    ) {
                        Icon(
                            Icons.Default.ArrowBack,
                            contentDescription = "Back",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                }
                
                Text(
                    text = selectedCategory?.name ?: "Select Exercise Type",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Divider(modifier = Modifier.padding(horizontal = 24.dp))
            
            if (selectedCategory == null) {
                // Show categories
                LazyColumn(
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(vertical = 8.dp)
                ) {
                    items(exerciseCategories) { category ->
                        CategoryItem(
                            category = category,
                            onClick = { selectedCategory = category }
                        )
                    }
                }
            } else {
                // Show exercises in selected category
                LazyColumn(
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(vertical = 8.dp)
                ) {
                    items(selectedCategory!!.exercises) { exercise ->
                        ExerciseItem(
                            exercise = exercise,
                            categoryColor = selectedCategory!!.color,
                            onClick = { onExerciseSelected(exercise) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CategoryItem(
    category: ExerciseCategory,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(horizontal = 24.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(category.color.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                category.icon,
                contentDescription = category.name,
                tint = category.color,
                modifier = Modifier.size(24.dp)
            )
        }
        
        Spacer(modifier = Modifier.width(16.dp))
        
        Column(modifier = Modifier.weight(1f)) {
            Text(
                category.name,
                fontWeight = FontWeight.Medium,
                fontSize = 16.sp
            )
            Text(
                "${category.exercises.size} exercises",
                fontSize = 14.sp,
                color = Color.Gray
            )
        }
        
        Icon(
            Icons.Default.ChevronRight,
            contentDescription = null,
            tint = Color.Gray.copy(alpha = 0.5f)
        )
    }
}

@Composable
private fun ExerciseItem(
    exercise: String,
    categoryColor: Color,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(horizontal = 24.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(categoryColor)
        )
        
        Spacer(modifier = Modifier.width(16.dp))
        
        Text(
            exercise,
            fontWeight = FontWeight.Normal,
            fontSize = 16.sp,
            modifier = Modifier.weight(1f)
        )
        
        Icon(
            Icons.Default.Add,
            contentDescription = "Add $exercise",
            tint = categoryColor,
            modifier = Modifier.size(20.dp)
        )
    }
}