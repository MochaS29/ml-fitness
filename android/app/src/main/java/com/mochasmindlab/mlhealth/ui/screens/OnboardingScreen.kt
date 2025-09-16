package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.*
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import com.mochasmindlab.mlhealth.utils.UnitConversions
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingScreen(
    navController: NavController,
    preferencesManager: PreferencesManager
) {
    var currentStep by remember { mutableStateOf(0) }
    val scope = rememberCoroutineScope()
    
    // User data states
    var name by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf(Gender.FEMALE) }
    var height by remember { mutableStateOf("") }
    var heightFeet by remember { mutableStateOf("") }
    var heightInches by remember { mutableStateOf("") }
    var heightUnit by remember { mutableStateOf(HeightUnit.CM) }
    var weight by remember { mutableStateOf("") }
    var weightUnit by remember { mutableStateOf(WeightUnit.KG) }
    var activityLevel by remember { mutableStateOf(ActivityLevel.MODERATE) }
    var goalType by remember { mutableStateOf(GoalCategory.WEIGHT_LOSS) }
    var targetWeight by remember { mutableStateOf("") }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        "Welcome to ML Health",
                        fontWeight = FontWeight.Bold
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MindLabsPurple,
                    titleContentColor = androidx.compose.ui.graphics.Color.White
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Progress indicator
            LinearProgressIndicator(
                progress = (currentStep + 1) / 5f,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .padding(bottom = 24.dp),
                color = MindfulTeal,
                trackColor = MindfulTeal.copy(alpha = 0.2f)
            )
            
            when (currentStep) {
                0 -> WelcomeStep(
                    onNext = { currentStep = 1 }
                )
                
                1 -> BasicInfoStep(
                    name = name,
                    age = age,
                    gender = gender,
                    onNameChange = { name = it },
                    onAgeChange = { age = it },
                    onGenderChange = { gender = it },
                    onNext = { currentStep = 2 },
                    onBack = { currentStep = 0 }
                )
                
                2 -> BodyMetricsStep(
                    height = height,
                    heightFeet = heightFeet,
                    heightInches = heightInches,
                    heightUnit = heightUnit,
                    weight = weight,
                    weightUnit = weightUnit,
                    onHeightChange = { height = it },
                    onHeightFeetChange = { heightFeet = it },
                    onHeightInchesChange = { heightInches = it },
                    onHeightUnitChange = { heightUnit = it },
                    onWeightChange = { weight = it },
                    onWeightUnitChange = { weightUnit = it },
                    onNext = { currentStep = 3 },
                    onBack = { currentStep = 1 }
                )
                
                3 -> ActivityLevelStep(
                    activityLevel = activityLevel,
                    onActivityLevelChange = { activityLevel = it },
                    onNext = { currentStep = 4 },
                    onBack = { currentStep = 2 }
                )
                
                4 -> GoalsStep(
                    goalType = goalType,
                    targetWeight = targetWeight,
                    currentWeight = weight,
                    weightUnit = weightUnit,
                    onGoalTypeChange = { goalType = it },
                    onTargetWeightChange = { targetWeight = it },
                    onComplete = {
                        scope.launch {
                            // Convert height to cm if needed
                            val heightInCm = if (heightUnit == HeightUnit.FEET_INCHES) {
                                UnitConversions.feetInchesToCm(
                                    heightFeet.toIntOrNull() ?: 5,
                                    heightInches.toIntOrNull() ?: 6
                                )
                            } else {
                                height.toFloatOrNull() ?: 170f
                            }
                            
                            // Save user preferences
                            preferencesManager.saveUserProfile(
                                name = name,
                                age = age.toIntOrNull() ?: 25,
                                gender = gender,
                                height = heightInCm,
                                heightUnit = heightUnit,
                                weight = weight.toFloatOrNull() ?: 70f,
                                weightUnit = weightUnit,
                                activityLevel = activityLevel,
                                goalType = goalType,
                                targetWeight = targetWeight.toFloatOrNull() ?: weight.toFloatOrNull() ?: 70f
                            )
                            preferencesManager.setOnboardingCompleted(true)
                            navController.navigate("dashboard") {
                                popUpTo("onboarding") { inclusive = true }
                            }
                        }
                    },
                    onBack = { currentStep = 3 }
                )
            }
        }
    }
}

@Composable
private fun WelcomeStep(onNext: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            Icons.Default.Favorite,
            contentDescription = null,
            modifier = Modifier.size(100.dp),
            tint = MindLabsPurple
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        Text(
            "Your Health Journey Starts Here",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            "Let's personalize ML Health for you.\nThis will only take a minute!",
            fontSize = 16.sp,
            textAlign = TextAlign.Center,
            color = androidx.compose.ui.graphics.Color.Gray
        )
        
        Spacer(modifier = Modifier.height(48.dp))
        
        Button(
            onClick = onNext,
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MindLabsPurple
            )
        ) {
            Text("Get Started", fontSize = 18.sp)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun BasicInfoStep(
    name: String,
    age: String,
    gender: Gender,
    onNameChange: (String) -> Unit,
    onAgeChange: (String) -> Unit,
    onGenderChange: (Gender) -> Unit,
    onNext: () -> Unit,
    onBack: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            "Tell us about yourself",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        OutlinedTextField(
            value = name,
            onValueChange = onNameChange,
            label = { Text("Your Name") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        OutlinedTextField(
            value = age,
            onValueChange = onAgeChange,
            label = { Text("Age") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        Text("Gender", fontWeight = FontWeight.Medium)
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Gender.values().forEach { g ->
                FilterChip(
                    selected = gender == g,
                    onClick = { onGenderChange(g) },
                    label = { 
                        Text(when(g) {
                            Gender.MALE -> "Male"
                            Gender.FEMALE -> "Female"
                            Gender.OTHER -> "Other"
                        })
                    },
                    modifier = Modifier.weight(1f)
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f).height(56.dp)
            ) {
                Text("Back")
            }
            
            Button(
                onClick = onNext,
                modifier = Modifier.weight(1f).height(56.dp),
                enabled = name.isNotBlank() && age.isNotBlank(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MindLabsPurple
                )
            ) {
                Text("Next")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun BodyMetricsStep(
    height: String,
    heightFeet: String,
    heightInches: String,
    heightUnit: HeightUnit,
    weight: String,
    weightUnit: WeightUnit,
    onHeightChange: (String) -> Unit,
    onHeightFeetChange: (String) -> Unit,
    onHeightInchesChange: (String) -> Unit,
    onHeightUnitChange: (HeightUnit) -> Unit,
    onWeightChange: (String) -> Unit,
    onWeightUnitChange: (WeightUnit) -> Unit,
    onNext: () -> Unit,
    onBack: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            "Your body metrics",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        
        Text(
            "This helps us calculate your nutritional needs",
            fontSize = 14.sp,
            color = androidx.compose.ui.graphics.Color.Gray
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        // Height unit selector
        Text("Height Unit", fontWeight = FontWeight.Medium)
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = heightUnit == HeightUnit.CM,
                onClick = { onHeightUnitChange(HeightUnit.CM) },
                label = { Text("Centimeters") },
                modifier = Modifier.weight(1f)
            )
            FilterChip(
                selected = heightUnit == HeightUnit.FEET_INCHES,
                onClick = { onHeightUnitChange(HeightUnit.FEET_INCHES) },
                label = { Text("Feet & Inches") },
                modifier = Modifier.weight(1f)
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Height input fields
        if (heightUnit == HeightUnit.CM) {
            OutlinedTextField(
                value = height,
                onValueChange = onHeightChange,
                label = { Text("Height (cm)") },
                modifier = Modifier.fillMaxWidth(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true
            )
        } else {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = heightFeet,
                    onValueChange = onHeightFeetChange,
                    label = { Text("Feet") },
                    modifier = Modifier.weight(1f),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
                OutlinedTextField(
                    value = heightInches,
                    onValueChange = onHeightInchesChange,
                    label = { Text("Inches") },
                    modifier = Modifier.weight(1f),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    singleLine = true
                )
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Weight unit selector
        Text("Weight Unit", fontWeight = FontWeight.Medium)
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = weightUnit == WeightUnit.KG,
                onClick = { onWeightUnitChange(WeightUnit.KG) },
                label = { Text("Kilograms (kg)") },
                modifier = Modifier.weight(1f)
            )
            FilterChip(
                selected = weightUnit == WeightUnit.LBS,
                onClick = { onWeightUnitChange(WeightUnit.LBS) },
                label = { Text("Pounds (lbs)") },
                modifier = Modifier.weight(1f)
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        OutlinedTextField(
            value = weight,
            onValueChange = onWeightChange,
            label = { Text("Current Weight (${if (weightUnit == WeightUnit.KG) "kg" else "lbs"})") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.weight(1f))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f).height(56.dp)
            ) {
                Text("Back")
            }
            
            Button(
                onClick = onNext,
                modifier = Modifier.weight(1f).height(56.dp),
                enabled = if (heightUnit == HeightUnit.CM) {
                    height.isNotBlank() && weight.isNotBlank()
                } else {
                    heightFeet.isNotBlank() && heightInches.isNotBlank() && weight.isNotBlank()
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = MindLabsPurple
                )
            ) {
                Text("Next")
            }
        }
    }
}

@Composable
private fun ActivityLevelStep(
    activityLevel: ActivityLevel,
    onActivityLevelChange: (ActivityLevel) -> Unit,
    onNext: () -> Unit,
    onBack: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            "How active are you?",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        ActivityLevel.values().forEach { level ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
                    .clickable { onActivityLevelChange(level) },
                colors = CardDefaults.cardColors(
                    containerColor = if (activityLevel == level) 
                        MindLabsPurple.copy(alpha = 0.1f) 
                    else androidx.compose.ui.graphics.Color.White
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RadioButton(
                        selected = activityLevel == level,
                        onClick = { onActivityLevelChange(level) }
                    )
                    
                    Spacer(modifier = Modifier.width(16.dp))
                    
                    Column {
                        Text(
                            text = when(level) {
                                ActivityLevel.SEDENTARY -> "Sedentary"
                                ActivityLevel.LIGHT -> "Lightly Active"
                                ActivityLevel.MODERATE -> "Moderately Active"
                                ActivityLevel.ACTIVE -> "Active"
                                ActivityLevel.VERY_ACTIVE -> "Very Active"
                            },
                            fontWeight = FontWeight.Medium
                        )
                        
                        Text(
                            text = when(level) {
                                ActivityLevel.SEDENTARY -> "Little or no exercise"
                                ActivityLevel.LIGHT -> "Exercise 1-3 days/week"
                                ActivityLevel.MODERATE -> "Exercise 3-5 days/week"
                                ActivityLevel.ACTIVE -> "Exercise 6-7 days/week"
                                ActivityLevel.VERY_ACTIVE -> "Very hard exercise daily"
                            },
                            fontSize = 12.sp,
                            color = androidx.compose.ui.graphics.Color.Gray
                        )
                    }
                }
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f).height(56.dp)
            ) {
                Text("Back")
            }
            
            Button(
                onClick = onNext,
                modifier = Modifier.weight(1f).height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MindLabsPurple
                )
            ) {
                Text("Next")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GoalsStep(
    goalType: GoalCategory,
    targetWeight: String,
    currentWeight: String,
    weightUnit: WeightUnit,
    onGoalTypeChange: (GoalCategory) -> Unit,
    onTargetWeightChange: (String) -> Unit,
    onComplete: () -> Unit,
    onBack: () -> Unit
) {
    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            "What's your primary goal?",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item {
                FilterChip(
                    selected = goalType == GoalCategory.WEIGHT_LOSS,
                    onClick = { onGoalTypeChange(GoalCategory.WEIGHT_LOSS) },
                    label = { Text("Lose Weight") }
                )
            }
            item {
                FilterChip(
                    selected = goalType == GoalCategory.WEIGHT_GAIN,
                    onClick = { onGoalTypeChange(GoalCategory.WEIGHT_GAIN) },
                    label = { Text("Gain Weight") }
                )
            }
            item {
                FilterChip(
                    selected = goalType == GoalCategory.NUTRITION,
                    onClick = { onGoalTypeChange(GoalCategory.NUTRITION) },
                    label = { Text("Eat Healthier") }
                )
            }
            item {
                FilterChip(
                    selected = goalType == GoalCategory.EXERCISE,
                    onClick = { onGoalTypeChange(GoalCategory.EXERCISE) },
                    label = { Text("Get Fit") }
                )
            }
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        if (goalType == GoalCategory.WEIGHT_LOSS || goalType == GoalCategory.WEIGHT_GAIN) {
            OutlinedTextField(
                value = targetWeight,
                onValueChange = onTargetWeightChange,
                label = { Text("Target Weight (${if (weightUnit == WeightUnit.KG) "kg" else "lbs"})") },
                modifier = Modifier.fillMaxWidth(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                singleLine = true,
                supportingText = {
                    Text("Current: $currentWeight${if (weightUnit == WeightUnit.KG) "kg" else "lbs"}")
                }
            )
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MindfulTeal.copy(alpha = 0.1f)
            )
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Info,
                    contentDescription = null,
                    tint = MindfulTeal
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    "You can change your goals anytime in Settings",
                    fontSize = 14.sp
                )
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onBack,
                modifier = Modifier.weight(1f).height(56.dp)
            ) {
                Text("Back")
            }
            
            Button(
                onClick = onComplete,
                modifier = Modifier.weight(1f).height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = ExerciseGreen
                )
            ) {
                Text("Complete Setup")
            }
        }
    }
}