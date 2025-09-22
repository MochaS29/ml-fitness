import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // Data types we want to read/write
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.workoutType()
    ]
    
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFiber)!,
        HKObjectType.workoutType()
    ]
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    // MARK: - Weight Management
    
    func saveWeight(_ weight: Double, date: Date = Date(), completion: @escaping (Bool) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: date, end: date)
        
        healthStore.save(weightSample) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func fetchLatestWeight(completion: @escaping (Double?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let weight = sample.quantity.doubleValue(for: .pound())
            DispatchQueue.main.async {
                completion(weight)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeightHistory(days: Int = 30, completion: @escaping ([HealthKitWeightEntry]) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let weightEntries = samples.map { sample in
                HealthKitWeightEntry(
                    date: sample.startDate,
                    weight: sample.quantity.doubleValue(for: .pound())
                )
            }.sorted { $0.date > $1.date }
            
            DispatchQueue.main.async {
                completion(weightEntries)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Exercise/Workout Management
    
    func saveWorkout(exercise: ExerciseEntry, completion: @escaping (Bool) -> Void) {
        guard let startDate = exercise.timestamp,
              let duration = TimeInterval(exactly: exercise.duration * 60),
              let calories = Double(exactly: exercise.caloriesBurned) else {
            completion(false)
            return
        }
        
        let endDate = startDate.addingTimeInterval(duration)
        let caloriesBurned = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        
        let workoutType: HKWorkoutActivityType = {
            switch exercise.type?.lowercased() {
            case "cardio": return .running
            case "strength": return .traditionalStrengthTraining
            case "flexibility": return .yoga
            case "sports": return .discSports
            default: return .other
            }
        }()
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Add energy burned sample
            let energySample = HKQuantitySample(
                    type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    quantity: caloriesBurned,
                    start: startDate,
                    end: endDate
                )
                
                builder.add([energySample]) { success, error in
                    if !success {
                        print("Failed to add energy sample: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            
            builder.endCollection(withEnd: endDate) { success, error in
                guard success else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                builder.finishWorkout { workout, error in
                    DispatchQueue.main.async {
                        completion(workout != nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Nutrition Management
    
    func saveNutrition(food: FoodEntry, completion: @escaping (Bool) -> Void) {
        guard let date = food.timestamp else {
            completion(false)
            return
        }
        
        var samplesToSave: [HKQuantitySample] = []
        
        // Calories
        if food.calories > 0 {
            let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            let caloriesQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: food.calories)
            let caloriesSample = HKQuantitySample(type: caloriesType, quantity: caloriesQuantity, start: date, end: date)
            samplesToSave.append(caloriesSample)
        }
        
        // Protein
        if food.protein > 0 {
            let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!
            let proteinQuantity = HKQuantity(unit: .gram(), doubleValue: food.protein)
            let proteinSample = HKQuantitySample(type: proteinType, quantity: proteinQuantity, start: date, end: date)
            samplesToSave.append(proteinSample)
        }
        
        // Carbs
        if food.carbs > 0 {
            let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            let carbsQuantity = HKQuantity(unit: .gram(), doubleValue: food.carbs)
            let carbsSample = HKQuantitySample(type: carbsType, quantity: carbsQuantity, start: date, end: date)
            samplesToSave.append(carbsSample)
        }
        
        // Fat
        if food.fat > 0 {
            let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!
            let fatQuantity = HKQuantity(unit: .gram(), doubleValue: food.fat)
            let fatSample = HKQuantitySample(type: fatType, quantity: fatQuantity, start: date, end: date)
            samplesToSave.append(fatSample)
        }
        
        // Fiber
        if food.fiber > 0 {
            let fiberType = HKQuantityType.quantityType(forIdentifier: .dietaryFiber)!
            let fiberQuantity = HKQuantity(unit: .gram(), doubleValue: food.fiber)
            let fiberSample = HKQuantitySample(type: fiberType, quantity: fiberQuantity, start: date, end: date)
            samplesToSave.append(fiberSample)
        }
        
        guard !samplesToSave.isEmpty else {
            completion(false)
            return
        }
        
        healthStore.save(samplesToSave) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    // MARK: - Activity Data

    func fetchSteps(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }

            let stepCount = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(stepCount)
            }
        }

        healthStore.execute(query)
    }

    func fetchTodaySteps(completion: @escaping (Double?) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(steps)
            }
        }
        
        healthStore.execute(query)
    }

    func fetchHourlySteps(from startDate: Date, to endDate: Date, completion: @escaping ([Double]) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        var hourlySteps: [Double] = []
        let group = DispatchGroup()

        // Calculate hours between start and end
        let hours = calendar.dateComponents([.hour], from: startDate, to: endDate).hour ?? 0

        for hour in 0...min(hours, 23) {
            guard let hourStart = calendar.date(byAdding: .hour, value: hour, to: startDate),
                  let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) else {
                continue
            }

            group.enter()
            let predicate = HKQuery.predicateForSamples(withStart: hourStart, end: hourEnd, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                defer { group.leave() }

                if let result = result, let sum = result.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    hourlySteps.append(steps)
                } else {
                    hourlySteps.append(0)
                }
            }

            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            completion(hourlySteps)
        }
    }
}

struct HealthKitWeightEntry {
    let date: Date
    let weight: Double
}