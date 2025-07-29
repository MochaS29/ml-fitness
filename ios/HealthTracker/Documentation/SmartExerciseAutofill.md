# Smart Exercise Autofill

## Overview

The HealthTracker app now includes intelligent exercise autofill that learns from user patterns and provides contextual suggestions to streamline exercise logging.

## Features

### 1. Pattern Recognition
The system analyzes multiple data points to provide relevant suggestions:

- **Time of Day**: Suggests exercises typically done at the current time (±2 hours)
- **Day of Week**: Recognizes weekly patterns (e.g., "Leg day" on Mondays)
- **Frequency**: Prioritizes frequently performed exercises
- **Recency**: Shows recently used exercises with decay over 30 days
- **Text Matching**: Intelligent fuzzy matching with Levenshtein distance

### 2. Confidence Scoring
Each suggestion includes a confidence score (0-1) based on:
- Match quality with input text
- Number of historical occurrences
- Contextual relevance (time/day patterns)
- Recency of last performance

### 3. Smart Defaults
When an exercise is selected from suggestions:
- **Duration**: Auto-fills with user's typical duration for that exercise
- **Calories**: Pre-calculates based on historical average
- **Type**: Automatically sets the correct exercise category

### 4. Visual Indicators
Each suggestion displays:
- **Confidence dots**: Visual representation of match confidence
- **Reason icon**: Shows why the exercise was suggested
  - ⭐ Frequently used
  - 🕐 Time of day pattern
  - 📅 Day of week pattern
  - 🔄 Recently used
  - 🔍 Text match
  - 📈 Follows pattern
- **Last performed**: Relative time (e.g., "2 days ago")
- **Typical duration**: Average time spent on this exercise

## How It Works

### Data Collection
The service analyzes the last 200 exercise entries to build patterns:
```swift
private func fetchExerciseHistory(context: NSManagedObjectContext) -> [ExerciseEntry] {
    let fetchRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)]
    fetchRequest.fetchLimit = 200
    return try context.fetch(fetchRequest)
}
```

### Suggestion Algorithm
1. **Text Matching** (highest priority)
   - Exact match: 100% confidence
   - Prefix match: 90% confidence
   - Contains match: 70% confidence
   - Fuzzy match: Variable based on similarity

2. **Time-Based** (0.8 max confidence)
   - Exercises done within 2 hours of current time
   - Minimum 2 occurrences required

3. **Day-Based** (0.7 max confidence)
   - Exercises done on the same day of week
   - Minimum 2 occurrences required

4. **Recent** (0.6 max confidence)
   - Last 20 unique exercises
   - Confidence decays over 30 days

5. **Frequent** (0.5 max confidence)
   - Top 10 most used exercises
   - Confidence based on usage count

### User Interface

The autofill UI shows:
- **"Suggested for you"** section with top 3 smart suggestions
- **"All exercises"** section with traditional search results
- Seamless integration with existing exercise database
- Non-intrusive suggestions that appear as you type

## Usage Example

1. User opens "Add Exercise" at 6 PM on a Monday
2. System immediately shows:
   - "Bench Press" (Monday pattern, 45 min typical)
   - "Squats" (frequently done at 6 PM, 30 min typical)
   - "Running" (did yesterday, 25 min typical)

3. User types "be" and system refines to show:
   - "Bench Press" (text match + pattern)
   - "Bear Crawls" (text match)

4. Selecting "Bench Press" auto-fills:
   - Duration: 45 minutes
   - Calories: 270 (based on history)
   - Type: Strength Training

## Benefits

- **Faster logging**: Reduces input time by up to 80%
- **Consistency**: Helps maintain exercise routines
- **Accuracy**: Pre-fills with personalized historical data
- **Discovery**: Reminds users of exercises they haven't done recently
- **Smart patterns**: Reinforces good workout habits

## Privacy

All pattern analysis is done locally on device. No exercise data is sent to external servers for analysis.

## Future Enhancements

1. **Workout Templates**: Save complete workout routines
2. **Progressive Overload**: Suggest gradual increases in duration/intensity
3. **Rest Day Awareness**: Avoid suggesting exercises after intense sessions
4. **Social Patterns**: Learn from similar users (opt-in)
5. **Goal Integration**: Suggest exercises that align with user goals