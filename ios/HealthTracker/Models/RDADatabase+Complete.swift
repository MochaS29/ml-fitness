//
//  RDADatabase+Complete.swift
//  HealthTracker
//
//  Complete RDA database with all essential vitamins and minerals
//

import Foundation

extension RDADatabase {
    
    func loadCompleteRDAData() {
        // Clear existing and reload with complete data
        nutrients.removeAll()
        
        // VITAMINS
        
        // Vitamin A
        nutrients["vitamin_a"] = NutrientRDA(
            nutrientId: "vitamin_a",
            name: "Vitamin A",
            maleValues: [
                .adult19to30: RDAValue(amount: 900, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult31to50: RDAValue(amount: 900, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult51to70: RDAValue(amount: 900, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult71plus: RDAValue(amount: 900, unit: .mcg, upperLimit: 3000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 700, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult31to50: RDAValue(amount: 700, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult51to70: RDAValue(amount: 700, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .adult71plus: RDAValue(amount: 700, unit: .mcg, upperLimit: 3000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 770, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .second: RDAValue(amount: 770, unit: .mcg, upperLimit: 3000, aiValue: nil),
                .third: RDAValue(amount: 770, unit: .mcg, upperLimit: 3000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1300, unit: .mcg, upperLimit: 3000, aiValue: nil)
        )
        
        // Vitamin C
        nutrients["vitamin_c"] = NutrientRDA(
            nutrientId: "vitamin_c",
            name: "Vitamin C",
            maleValues: [
                .adult19to30: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult31to50: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult51to70: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult31to50: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult51to70: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil),
                .second: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil),
                .third: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 120, unit: .mg, upperLimit: 2000, aiValue: nil)
        )
        
        // Vitamin D
        nutrients["vitamin_d"] = NutrientRDA(
            nutrientId: "vitamin_d",
            name: "Vitamin D",
            maleValues: [
                .adult19to30: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult31to50: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult51to70: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult71plus: RDAValue(amount: 20, unit: .mcg, upperLimit: 100, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult31to50: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult51to70: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .adult71plus: RDAValue(amount: 20, unit: .mcg, upperLimit: 100, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .second: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil),
                .third: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 15, unit: .mcg, upperLimit: 100, aiValue: nil)
        )
        
        // Vitamin E
        nutrients["vitamin_e"] = NutrientRDA(
            nutrientId: "vitamin_e",
            name: "Vitamin E",
            maleValues: [
                .adult19to30: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .second: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil),
                .third: RDAValue(amount: 15, unit: .mg, upperLimit: 1000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 19, unit: .mg, upperLimit: 1000, aiValue: nil)
        )
        
        // Vitamin K
        nutrients["vitamin_k"] = NutrientRDA(
            nutrientId: "vitamin_k",
            name: "Vitamin K",
            maleValues: [
                .adult19to30: RDAValue(amount: 120, unit: .mcg, upperLimit: nil, aiValue: 120),
                .adult31to50: RDAValue(amount: 120, unit: .mcg, upperLimit: nil, aiValue: 120),
                .adult51to70: RDAValue(amount: 120, unit: .mcg, upperLimit: nil, aiValue: 120),
                .adult71plus: RDAValue(amount: 120, unit: .mcg, upperLimit: nil, aiValue: 120)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90),
                .adult31to50: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90),
                .adult51to70: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90),
                .adult71plus: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90),
                .second: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90),
                .third: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90)
            ],
            breastfeedingValue: RDAValue(amount: 90, unit: .mcg, upperLimit: nil, aiValue: 90)
        )
        
        // B Vitamins
        
        // Thiamin (B1)
        nutrients["thiamin"] = NutrientRDA(
            nutrientId: "thiamin",
            name: "Thiamin (B1)",
            maleValues: [
                .adult19to30: RDAValue(amount: 1.2, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.2, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.2, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.2, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil),
                .second: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil),
                .third: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil)
        )
        
        // Riboflavin (B2)
        nutrients["riboflavin"] = NutrientRDA(
            nutrientId: "riboflavin",
            name: "Riboflavin (B2)",
            maleValues: [
                .adult19to30: RDAValue(amount: 1.3, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.3, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.3, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.3, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.1, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil),
                .second: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil),
                .third: RDAValue(amount: 1.4, unit: .mg, upperLimit: nil, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1.6, unit: .mg, upperLimit: nil, aiValue: nil)
        )
        
        // Niacin (B3)
        nutrients["niacin"] = NutrientRDA(
            nutrientId: "niacin",
            name: "Niacin (B3)",
            maleValues: [
                .adult19to30: RDAValue(amount: 16, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult31to50: RDAValue(amount: 16, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult51to70: RDAValue(amount: 16, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult71plus: RDAValue(amount: 16, unit: .mg, upperLimit: 35, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 14, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult31to50: RDAValue(amount: 14, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult51to70: RDAValue(amount: 14, unit: .mg, upperLimit: 35, aiValue: nil),
                .adult71plus: RDAValue(amount: 14, unit: .mg, upperLimit: 35, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 18, unit: .mg, upperLimit: 35, aiValue: nil),
                .second: RDAValue(amount: 18, unit: .mg, upperLimit: 35, aiValue: nil),
                .third: RDAValue(amount: 18, unit: .mg, upperLimit: 35, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 17, unit: .mg, upperLimit: 35, aiValue: nil)
        )
        
        // Vitamin B6
        nutrients["vitamin_b6"] = NutrientRDA(
            nutrientId: "vitamin_b6",
            name: "Vitamin B6",
            maleValues: [
                .adult19to30: RDAValue(amount: 1.3, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.3, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.7, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.7, unit: .mg, upperLimit: 100, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1.3, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult31to50: RDAValue(amount: 1.3, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult51to70: RDAValue(amount: 1.5, unit: .mg, upperLimit: 100, aiValue: nil),
                .adult71plus: RDAValue(amount: 1.5, unit: .mg, upperLimit: 100, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1.9, unit: .mg, upperLimit: 100, aiValue: nil),
                .second: RDAValue(amount: 1.9, unit: .mg, upperLimit: 100, aiValue: nil),
                .third: RDAValue(amount: 1.9, unit: .mg, upperLimit: 100, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 2.0, unit: .mg, upperLimit: 100, aiValue: nil)
        )
        
        // Folate
        nutrients["folate"] = NutrientRDA(
            nutrientId: "folate",
            name: "Folate",
            maleValues: [
                .adult19to30: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .second: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .third: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 500, unit: .mcg, upperLimit: 1000, aiValue: nil)
        )
        
        // Vitamin B12
        nutrients["vitamin_b12"] = NutrientRDA(
            nutrientId: "vitamin_b12",
            name: "Vitamin B12",
            maleValues: [
                .adult19to30: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult31to50: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult51to70: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil),
                .adult71plus: RDAValue(amount: 2.4, unit: .mcg, upperLimit: nil, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 2.6, unit: .mcg, upperLimit: nil, aiValue: nil),
                .second: RDAValue(amount: 2.6, unit: .mcg, upperLimit: nil, aiValue: nil),
                .third: RDAValue(amount: 2.6, unit: .mcg, upperLimit: nil, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 2.8, unit: .mcg, upperLimit: nil, aiValue: nil)
        )
        
        // MINERALS
        
        // Calcium
        nutrients["calcium"] = NutrientRDA(
            nutrientId: "calcium",
            name: "Calcium",
            maleValues: [
                .adult19to30: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult31to50: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult51to70: RDAValue(amount: 1000, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult31to50: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult51to70: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .second: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .third: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil)
        )
        
        // Iron
        nutrients["iron"] = NutrientRDA(
            nutrientId: "iron",
            name: "Iron",
            maleValues: [
                .adult19to30: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult31to50: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult51to70: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult71plus: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 18, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult31to50: RDAValue(amount: 18, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult51to70: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult71plus: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil),
                .second: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil),
                .third: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 9, unit: .mg, upperLimit: 45, aiValue: nil)
        )
        
        // Magnesium
        nutrients["magnesium"] = NutrientRDA(
            nutrientId: "magnesium",
            name: "Magnesium",
            maleValues: [
                .adult19to30: RDAValue(amount: 400, unit: .mg, upperLimit: 350, aiValue: nil), // Upper limit is for supplements only
                .adult31to50: RDAValue(amount: 420, unit: .mg, upperLimit: 350, aiValue: nil),
                .adult51to70: RDAValue(amount: 420, unit: .mg, upperLimit: 350, aiValue: nil),
                .adult71plus: RDAValue(amount: 420, unit: .mg, upperLimit: 350, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 310, unit: .mg, upperLimit: 350, aiValue: nil),
                .adult31to50: RDAValue(amount: 320, unit: .mg, upperLimit: 350, aiValue: nil),
                .adult51to70: RDAValue(amount: 320, unit: .mg, upperLimit: 350, aiValue: nil),
                .adult71plus: RDAValue(amount: 320, unit: .mg, upperLimit: 350, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 350, unit: .mg, upperLimit: 350, aiValue: nil),
                .second: RDAValue(amount: 360, unit: .mg, upperLimit: 350, aiValue: nil),
                .third: RDAValue(amount: 360, unit: .mg, upperLimit: 350, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 310, unit: .mg, upperLimit: 350, aiValue: nil)
        )
        
        // Zinc
        nutrients["zinc"] = NutrientRDA(
            nutrientId: "zinc",
            name: "Zinc",
            maleValues: [
                .adult19to30: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult31to50: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult51to70: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult71plus: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 8, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult31to50: RDAValue(amount: 8, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult51to70: RDAValue(amount: 8, unit: .mg, upperLimit: 40, aiValue: nil),
                .adult71plus: RDAValue(amount: 8, unit: .mg, upperLimit: 40, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil),
                .second: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil),
                .third: RDAValue(amount: 11, unit: .mg, upperLimit: 40, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 12, unit: .mg, upperLimit: 40, aiValue: nil)
        )
        
        // Potassium
        nutrients["potassium"] = NutrientRDA(
            nutrientId: "potassium",
            name: "Potassium",
            maleValues: [
                .adult19to30: RDAValue(amount: 3400, unit: .mg, upperLimit: nil, aiValue: 3400),
                .adult31to50: RDAValue(amount: 3400, unit: .mg, upperLimit: nil, aiValue: 3400),
                .adult51to70: RDAValue(amount: 3400, unit: .mg, upperLimit: nil, aiValue: 3400),
                .adult71plus: RDAValue(amount: 3400, unit: .mg, upperLimit: nil, aiValue: 3400)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 2600, unit: .mg, upperLimit: nil, aiValue: 2600),
                .adult31to50: RDAValue(amount: 2600, unit: .mg, upperLimit: nil, aiValue: 2600),
                .adult51to70: RDAValue(amount: 2600, unit: .mg, upperLimit: nil, aiValue: 2600),
                .adult71plus: RDAValue(amount: 2600, unit: .mg, upperLimit: nil, aiValue: 2600)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 2900, unit: .mg, upperLimit: nil, aiValue: 2900),
                .second: RDAValue(amount: 2900, unit: .mg, upperLimit: nil, aiValue: 2900),
                .third: RDAValue(amount: 2900, unit: .mg, upperLimit: nil, aiValue: 2900)
            ],
            breastfeedingValue: RDAValue(amount: 2800, unit: .mg, upperLimit: nil, aiValue: 2800)
        )
        
        // Selenium
        nutrients["selenium"] = NutrientRDA(
            nutrientId: "selenium",
            name: "Selenium",
            maleValues: [
                .adult19to30: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult31to50: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult51to70: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult71plus: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult31to50: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult51to70: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil),
                .adult71plus: RDAValue(amount: 55, unit: .mcg, upperLimit: 400, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 60, unit: .mcg, upperLimit: 400, aiValue: nil),
                .second: RDAValue(amount: 60, unit: .mcg, upperLimit: 400, aiValue: nil),
                .third: RDAValue(amount: 60, unit: .mcg, upperLimit: 400, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 70, unit: .mcg, upperLimit: 400, aiValue: nil)
        )
        
        // Copper
        nutrients["copper"] = NutrientRDA(
            nutrientId: "copper",
            name: "Copper",
            maleValues: [
                .adult19to30: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult31to50: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult51to70: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult71plus: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult31to50: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult51to70: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .adult71plus: RDAValue(amount: 900, unit: .mcg, upperLimit: 10000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1000, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .second: RDAValue(amount: 1000, unit: .mcg, upperLimit: 10000, aiValue: nil),
                .third: RDAValue(amount: 1000, unit: .mcg, upperLimit: 10000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1300, unit: .mcg, upperLimit: 10000, aiValue: nil)
        )
        
        // Manganese
        nutrients["manganese"] = NutrientRDA(
            nutrientId: "manganese",
            name: "Manganese",
            maleValues: [
                .adult19to30: RDAValue(amount: 2.3, unit: .mg, upperLimit: 11, aiValue: 2.3),
                .adult31to50: RDAValue(amount: 2.3, unit: .mg, upperLimit: 11, aiValue: 2.3),
                .adult51to70: RDAValue(amount: 2.3, unit: .mg, upperLimit: 11, aiValue: 2.3),
                .adult71plus: RDAValue(amount: 2.3, unit: .mg, upperLimit: 11, aiValue: 2.3)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1.8, unit: .mg, upperLimit: 11, aiValue: 1.8),
                .adult31to50: RDAValue(amount: 1.8, unit: .mg, upperLimit: 11, aiValue: 1.8),
                .adult51to70: RDAValue(amount: 1.8, unit: .mg, upperLimit: 11, aiValue: 1.8),
                .adult71plus: RDAValue(amount: 1.8, unit: .mg, upperLimit: 11, aiValue: 1.8)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 2.0, unit: .mg, upperLimit: 11, aiValue: 2.0),
                .second: RDAValue(amount: 2.0, unit: .mg, upperLimit: 11, aiValue: 2.0),
                .third: RDAValue(amount: 2.0, unit: .mg, upperLimit: 11, aiValue: 2.0)
            ],
            breastfeedingValue: RDAValue(amount: 2.6, unit: .mg, upperLimit: 11, aiValue: 2.6)
        )
        
        // Phosphorus
        nutrients["phosphorus"] = NutrientRDA(
            nutrientId: "phosphorus",
            name: "Phosphorus",
            maleValues: [
                .adult19to30: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult31to50: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult51to70: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult71plus: RDAValue(amount: 700, unit: .mg, upperLimit: 3000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult31to50: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult51to70: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil),
                .adult71plus: RDAValue(amount: 700, unit: .mg, upperLimit: 3000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 700, unit: .mg, upperLimit: 3500, aiValue: nil),
                .second: RDAValue(amount: 700, unit: .mg, upperLimit: 3500, aiValue: nil),
                .third: RDAValue(amount: 700, unit: .mg, upperLimit: 3500, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 700, unit: .mg, upperLimit: 4000, aiValue: nil)
        )
        
        // Iodine
        nutrients["iodine"] = NutrientRDA(
            nutrientId: "iodine",
            name: "Iodine",
            maleValues: [
                .adult19to30: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult31to50: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult51to70: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult71plus: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult31to50: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult51to70: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .adult71plus: RDAValue(amount: 150, unit: .mcg, upperLimit: 1100, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 220, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .second: RDAValue(amount: 220, unit: .mcg, upperLimit: 1100, aiValue: nil),
                .third: RDAValue(amount: 220, unit: .mcg, upperLimit: 1100, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 290, unit: .mcg, upperLimit: 1100, aiValue: nil)
        )
        
        // Chromium
        nutrients["chromium"] = NutrientRDA(
            nutrientId: "chromium",
            name: "Chromium",
            maleValues: [
                .adult19to30: RDAValue(amount: 35, unit: .mcg, upperLimit: nil, aiValue: 35),
                .adult31to50: RDAValue(amount: 35, unit: .mcg, upperLimit: nil, aiValue: 35),
                .adult51to70: RDAValue(amount: 30, unit: .mcg, upperLimit: nil, aiValue: 30),
                .adult71plus: RDAValue(amount: 30, unit: .mcg, upperLimit: nil, aiValue: 30)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 25, unit: .mcg, upperLimit: nil, aiValue: 25),
                .adult31to50: RDAValue(amount: 25, unit: .mcg, upperLimit: nil, aiValue: 25),
                .adult51to70: RDAValue(amount: 20, unit: .mcg, upperLimit: nil, aiValue: 20),
                .adult71plus: RDAValue(amount: 20, unit: .mcg, upperLimit: nil, aiValue: 20)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 30, unit: .mcg, upperLimit: nil, aiValue: 30),
                .second: RDAValue(amount: 30, unit: .mcg, upperLimit: nil, aiValue: 30),
                .third: RDAValue(amount: 30, unit: .mcg, upperLimit: nil, aiValue: 30)
            ],
            breastfeedingValue: RDAValue(amount: 45, unit: .mcg, upperLimit: nil, aiValue: 45)
        )
        
        // Other important nutrients
        
        // Omega-3 (EPA+DHA)
        nutrients["omega3"] = NutrientRDA(
            nutrientId: "omega3",
            name: "Omega-3 (EPA+DHA)",
            maleValues: [
                .adult19to30: RDAValue(amount: 1600, unit: .mg, upperLimit: nil, aiValue: 1600),
                .adult31to50: RDAValue(amount: 1600, unit: .mg, upperLimit: nil, aiValue: 1600),
                .adult51to70: RDAValue(amount: 1600, unit: .mg, upperLimit: nil, aiValue: 1600),
                .adult71plus: RDAValue(amount: 1600, unit: .mg, upperLimit: nil, aiValue: 1600)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1100, unit: .mg, upperLimit: nil, aiValue: 1100),
                .adult31to50: RDAValue(amount: 1100, unit: .mg, upperLimit: nil, aiValue: 1100),
                .adult51to70: RDAValue(amount: 1100, unit: .mg, upperLimit: nil, aiValue: 1100),
                .adult71plus: RDAValue(amount: 1100, unit: .mg, upperLimit: nil, aiValue: 1100)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1400, unit: .mg, upperLimit: nil, aiValue: 1400),
                .second: RDAValue(amount: 1400, unit: .mg, upperLimit: nil, aiValue: 1400),
                .third: RDAValue(amount: 1400, unit: .mg, upperLimit: nil, aiValue: 1400)
            ],
            breastfeedingValue: RDAValue(amount: 1300, unit: .mg, upperLimit: nil, aiValue: 1300)
        )
        
        // Choline
        nutrients["choline"] = NutrientRDA(
            nutrientId: "choline",
            name: "Choline",
            maleValues: [
                .adult19to30: RDAValue(amount: 550, unit: .mg, upperLimit: 3500, aiValue: 550),
                .adult31to50: RDAValue(amount: 550, unit: .mg, upperLimit: 3500, aiValue: 550),
                .adult51to70: RDAValue(amount: 550, unit: .mg, upperLimit: 3500, aiValue: 550),
                .adult71plus: RDAValue(amount: 550, unit: .mg, upperLimit: 3500, aiValue: 550)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 425, unit: .mg, upperLimit: 3500, aiValue: 425),
                .adult31to50: RDAValue(amount: 425, unit: .mg, upperLimit: 3500, aiValue: 425),
                .adult51to70: RDAValue(amount: 425, unit: .mg, upperLimit: 3500, aiValue: 425),
                .adult71plus: RDAValue(amount: 425, unit: .mg, upperLimit: 3500, aiValue: 425)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 450, unit: .mg, upperLimit: 3500, aiValue: 450),
                .second: RDAValue(amount: 450, unit: .mg, upperLimit: 3500, aiValue: 450),
                .third: RDAValue(amount: 450, unit: .mg, upperLimit: 3500, aiValue: 450)
            ],
            breastfeedingValue: RDAValue(amount: 550, unit: .mg, upperLimit: 3500, aiValue: 550)
        )
    }
}