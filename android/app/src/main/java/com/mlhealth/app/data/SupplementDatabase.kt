package com.mlhealth.app.data

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

// Supplement data models
data class Supplement(
    val id: String,
    val name: String,
    val brand: String,
    val category: String,
    val description: String = "",
    val servingSize: String,
    val servingsPerContainer: Int? = null,
    val barcode: String? = null,
    val dpn: String? = null, // Drug Product Number (Canada)
    val vitamins: VitaminContent,
    val minerals: MineralContent,
    val otherIngredients: List<String> = emptyList(),
    val targetGender: String? = null, // "male", "female", "unisex"
    val targetAge: String? = null,
    val warnings: List<String> = emptyList(),
    val certifications: List<String> = emptyList()
)

data class VitaminContent(
    val vitaminA: Double = 0.0, // mcg RAE
    val vitaminC: Double = 0.0, // mg
    val vitaminD: Double = 0.0, // mcg
    val vitaminE: Double = 0.0, // mg
    val vitaminK: Double = 0.0, // mcg
    val thiamine: Double = 0.0, // B1, mg
    val riboflavin: Double = 0.0, // B2, mg
    val niacin: Double = 0.0, // B3, mg
    val vitaminB6: Double = 0.0, // mg
    val folate: Double = 0.0, // mcg DFE
    val vitaminB12: Double = 0.0, // mcg
    val biotin: Double = 0.0, // mcg
    val pantothenicAcid: Double = 0.0 // B5, mg
)

data class MineralContent(
    val calcium: Double = 0.0, // mg
    val iron: Double = 0.0, // mg
    val magnesium: Double = 0.0, // mg
    val phosphorus: Double = 0.0, // mg
    val potassium: Double = 0.0, // mg
    val sodium: Double = 0.0, // mg
    val zinc: Double = 0.0, // mg
    val copper: Double = 0.0, // mg
    val manganese: Double = 0.0, // mg
    val selenium: Double = 0.0, // mcg
    val chromium: Double = 0.0, // mcg
    val molybdenum: Double = 0.0, // mcg
    val iodine: Double = 0.0 // mcg
)

// Singleton supplement database
object SupplementDatabase {
    private val _supplements = MutableStateFlow<List<Supplement>>(emptyList())
    val supplements: StateFlow<List<Supplement>> = _supplements.asStateFlow()

    init {
        loadSupplements()
    }

    private fun loadSupplements() {
        _supplements.value = listOf(
            // Centrum Men (Canada/USA)
            Supplement(
                id = "centrum-men",
                name = "Centrum Men",
                brand = "Centrum",
                category = "Multivitamin",
                description = "Complete multivitamin specially formulated for men",
                servingSize = "1 tablet",
                servingsPerContainer = 90,
                barcode = "062107073806",
                dpn = "02248186",
                vitamins = VitaminContent(
                    vitaminA = 1050.0,
                    vitaminC = 90.0,
                    vitaminD = 25.0,
                    vitaminE = 15.0,
                    vitaminK = 120.0,
                    thiamine = 1.2,
                    riboflavin = 1.3,
                    niacin = 16.0,
                    vitaminB6 = 1.7,
                    folate = 400.0,
                    vitaminB12 = 2.4,
                    biotin = 30.0,
                    pantothenicAcid = 5.0
                ),
                minerals = MineralContent(
                    calcium = 210.0,
                    iron = 0.0,
                    magnesium = 140.0,
                    phosphorus = 125.0,
                    potassium = 80.0,
                    zinc = 11.0,
                    copper = 0.9,
                    manganese = 2.3,
                    selenium = 55.0,
                    chromium = 35.0,
                    molybdenum = 45.0,
                    iodine = 150.0
                ),
                otherIngredients = listOf("Lycopene", "Lutein"),
                targetGender = "male",
                certifications = listOf("USP Verified")
            ),

            // One A Day Men's (USA)
            Supplement(
                id = "one-a-day-mens",
                name = "One A Day Men's Complete Multivitamin",
                brand = "One A Day",
                category = "Multivitamin",
                description = "Complete multivitamin for men's health",
                servingSize = "1 tablet",
                servingsPerContainer = 200,
                barcode = "016500535454",
                vitamins = VitaminContent(
                    vitaminA = 1050.0,
                    vitaminC = 60.0,
                    vitaminD = 17.5,
                    vitaminE = 10.0,
                    vitaminK = 20.0,
                    thiamine = 1.35,
                    riboflavin = 1.7,
                    niacin = 16.0,
                    vitaminB6 = 2.0,
                    folate = 400.0,
                    vitaminB12 = 6.0,
                    biotin = 30.0,
                    pantothenicAcid = 5.0
                ),
                minerals = MineralContent(
                    calcium = 210.0,
                    magnesium = 140.0,
                    zinc = 11.0,
                    copper = 0.9,
                    manganese = 2.3,
                    selenium = 55.0,
                    chromium = 120.0,
                    iodine = 150.0
                ),
                otherIngredients = listOf("Lycopene"),
                targetGender = "male"
            ),

            // Centrum Women (Canada/USA)
            Supplement(
                id = "centrum-women",
                name = "Centrum Women",
                brand = "Centrum",
                category = "Multivitamin",
                description = "Complete multivitamin specially formulated for women",
                servingSize = "1 tablet",
                servingsPerContainer = 90,
                barcode = "062107073813",
                dpn = "02248187",
                vitamins = VitaminContent(
                    vitaminA = 750.0,
                    vitaminC = 75.0,
                    vitaminD = 25.0,
                    vitaminE = 13.5,
                    vitaminK = 90.0,
                    thiamine = 1.1,
                    riboflavin = 1.1,
                    niacin = 14.0,
                    vitaminB6 = 1.5,
                    folate = 400.0,
                    vitaminB12 = 2.4,
                    biotin = 30.0,
                    pantothenicAcid = 5.0
                ),
                minerals = MineralContent(
                    calcium = 500.0,
                    iron = 18.0,
                    magnesium = 50.0,
                    phosphorus = 125.0,
                    potassium = 80.0,
                    zinc = 8.0,
                    copper = 0.9,
                    manganese = 1.8,
                    selenium = 55.0,
                    chromium = 25.0,
                    molybdenum = 45.0,
                    iodine = 150.0
                ),
                otherIngredients = listOf("Biotin", "Lutein"),
                targetGender = "female",
                certifications = listOf("USP Verified")
            ),

            // Materna Prenatal (Canada)
            Supplement(
                id = "materna-prenatal",
                name = "Materna Prenatal Multivitamin",
                brand = "Materna",
                category = "Prenatal",
                description = "Complete prenatal vitamin with DHA",
                servingSize = "1 tablet + 1 softgel",
                servingsPerContainer = 30,
                barcode = "060815008622",
                dpn = "02343398",
                vitamins = VitaminContent(
                    vitaminA = 600.0,
                    vitaminC = 85.0,
                    vitaminD = 15.0,
                    vitaminE = 13.5,
                    vitaminK = 90.0,
                    thiamine = 1.4,
                    riboflavin = 1.4,
                    niacin = 18.0,
                    vitaminB6 = 1.9,
                    folate = 1000.0, // Important for pregnancy
                    vitaminB12 = 2.6,
                    biotin = 30.0,
                    pantothenicAcid = 6.0
                ),
                minerals = MineralContent(
                    calcium = 300.0,
                    iron = 27.0, // High iron for pregnancy
                    magnesium = 50.0,
                    zinc = 11.0,
                    copper = 1.0,
                    manganese = 2.0,
                    selenium = 30.0,
                    chromium = 30.0,
                    molybdenum = 50.0,
                    iodine = 220.0
                ),
                otherIngredients = listOf("DHA 200mg", "Choline"),
                targetGender = "female",
                targetAge = "18-45",
                warnings = listOf("For pregnant and lactating women only")
            ),

            // Jamieson Vitamin D3 (Canada)
            Supplement(
                id = "jamieson-d3-1000",
                name = "Vitamin D3 1000 IU",
                brand = "Jamieson",
                category = "Single Vitamin",
                description = "Helps maintain bone and immune health",
                servingSize = "1 tablet",
                servingsPerContainer = 375,
                barcode = "064642020130",
                dpn = "80001227",
                vitamins = VitaminContent(
                    vitaminD = 25.0 // 1000 IU
                ),
                minerals = MineralContent(),
                certifications = listOf("NPN Approved", "TRU-ID Certified")
            ),

            // Nordic Naturals Omega-3 (USA/Canada)
            Supplement(
                id = "nordic-naturals-omega3",
                name = "Ultimate Omega",
                brand = "Nordic Naturals",
                category = "Omega-3",
                description = "High-concentration omega-3 fish oil",
                servingSize = "2 softgels",
                servingsPerContainer = 60,
                barcode = "768990017605",
                vitamins = VitaminContent(),
                minerals = MineralContent(),
                otherIngredients = listOf(
                    "EPA 650mg",
                    "DHA 450mg",
                    "Other Omega-3s 180mg"
                ),
                certifications = listOf("Third-Party Tested", "Non-GMO", "Friend of the Sea")
            ),

            // Kirkland Signature Multi (Costco - USA/Canada)
            Supplement(
                id = "kirkland-multi",
                name = "Daily Multi",
                brand = "Kirkland Signature",
                category = "Multivitamin",
                description = "USP verified daily multivitamin",
                servingSize = "1 tablet",
                servingsPerContainer = 500,
                barcode = "096619756346",
                vitamins = VitaminContent(
                    vitaminA = 1050.0,
                    vitaminC = 60.0,
                    vitaminD = 10.0,
                    vitaminE = 13.5,
                    vitaminK = 25.0,
                    thiamine = 1.5,
                    riboflavin = 1.7,
                    niacin = 20.0,
                    vitaminB6 = 2.0,
                    folate = 400.0,
                    vitaminB12 = 6.0,
                    biotin = 30.0,
                    pantothenicAcid = 10.0
                ),
                minerals = MineralContent(
                    calcium = 160.0,
                    iron = 18.0,
                    magnesium = 100.0,
                    phosphorus = 125.0,
                    zinc = 11.0,
                    copper = 0.9,
                    manganese = 2.3,
                    selenium = 55.0,
                    chromium = 35.0,
                    molybdenum = 45.0,
                    iodine = 150.0
                ),
                certifications = listOf("USP Verified")
            ),

            // Magnesium Bisglycinate (Canada)
            Supplement(
                id = "canprev-magnesium",
                name = "Magnesium Bisglycinate 200",
                brand = "CanPrev",
                category = "Single Mineral",
                description = "Gentle magnesium for better absorption",
                servingSize = "1 capsule",
                servingsPerContainer = 120,
                barcode = "886646502173",
                dpn = "80077834",
                vitamins = VitaminContent(),
                minerals = MineralContent(
                    magnesium = 200.0
                ),
                certifications = listOf("NPN Approved", "Third-Party Tested")
            ),

            // Nature Made Multi For Her (USA)
            Supplement(
                id = "nature-made-her",
                name = "Multi For Her",
                brand = "Nature Made",
                category = "Multivitamin",
                description = "Women's multivitamin with iron",
                servingSize = "1 tablet",
                servingsPerContainer = 90,
                barcode = "031604026585",
                vitamins = VitaminContent(
                    vitaminA = 750.0,
                    vitaminC = 120.0,
                    vitaminD = 25.0,
                    vitaminE = 15.0,
                    vitaminK = 90.0,
                    thiamine = 1.1,
                    riboflavin = 1.1,
                    niacin = 14.0,
                    vitaminB6 = 1.3,
                    folate = 665.0,
                    vitaminB12 = 2.4,
                    biotin = 30.0,
                    pantothenicAcid = 5.0
                ),
                minerals = MineralContent(
                    calcium = 300.0,
                    iron = 18.0,
                    magnesium = 50.0,
                    zinc = 8.0,
                    selenium = 55.0,
                    copper = 0.9,
                    manganese = 1.8,
                    chromium = 25.0,
                    molybdenum = 45.0,
                    iodine = 150.0
                ),
                targetGender = "female",
                certifications = listOf("USP Verified")
            ),

            // Webber Naturals B Complex (Canada)
            Supplement(
                id = "webber-b-complex",
                name = "B Complex 50",
                brand = "Webber Naturals",
                category = "B Complex",
                description = "High potency B vitamin complex",
                servingSize = "1 tablet",
                servingsPerContainer = 60,
                barcode = "625273030068",
                dpn = "02246123",
                vitamins = VitaminContent(
                    thiamine = 50.0,
                    riboflavin = 50.0,
                    niacin = 50.0,
                    vitaminB6 = 50.0,
                    folate = 400.0,
                    vitaminB12 = 50.0,
                    biotin = 50.0,
                    pantothenicAcid = 50.0
                ),
                minerals = MineralContent(),
                otherIngredients = listOf("Inositol 50mg", "Choline 50mg"),
                certifications = listOf("NPN Approved")
            ),

            // USER'S PERSONAL SUPPLEMENTS

            // One A Day Women's (Personal)
            Supplement(
                id = "one-a-day-womens-personal",
                name = "Women's Multivitamin",
                brand = "One A Day",
                category = "Multivitamin",
                description = "Complete women's multivitamin",
                servingSize = "1 tablet",
                servingsPerContainer = null,
                barcode = "016500535669",
                dpn = null,
                vitamins = VitaminContent(
                    vitaminA = 700.0,
                    vitaminC = 90.0,
                    vitaminD = 25.0,
                    vitaminE = 15.0,
                    thiamine = 2.4,
                    riboflavin = 1.95,
                    niacin = 24.0,
                    vitaminB6 = 3.4,
                    folate = 665.0,
                    vitaminB12 = 9.6,
                    biotin = 45.0,
                    pantothenicAcid = 7.5
                ),
                minerals = MineralContent(
                    calcium = 130.0,
                    iron = 18.0,
                    magnesium = 42.0,
                    zinc = 8.0,
                    copper = 1.35,
                    selenium = 41.0,
                    iodine = 150.0
                ),
                targetGender = "female"
            ),

            // Wild Fish Oil Blend (Personal)
            Supplement(
                id = "wild-fish-oil-personal",
                name = "Wild Fish Oil Blend",
                brand = "Generic",
                category = "Omega-3",
                description = "High potency wild fish oil (anchovy, sardine, herring, mackerel)",
                servingSize = "2 tablets",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(),
                minerals = MineralContent(),
                otherIngredients = listOf(
                    "Total Omega-3: 2600mg",
                    "EPA: 900mg",
                    "DHA: 600mg"
                )
            ),

            // Enhanced Fish Oil with Plant Sterols (Personal)
            Supplement(
                id = "enhanced-fish-oil-personal",
                name = "Enhanced Fish Oil with Plant Sterols",
                brand = "Generic",
                category = "Omega-3",
                description = "Fish oil concentrate with plant sterols and CoQ10",
                servingSize = "3 softgels",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(),
                minerals = MineralContent(),
                otherIngredients = listOf(
                    "Fish Oil Concentrate: 1251mg",
                    "Total Omega-3: 675mg",
                    "EPA: 450mg",
                    "DHA: 225mg",
                    "Plant Sterols: 1110mg",
                    "Coenzyme Q10: 150mg"
                )
            ),

            // Collagen Peptides (Personal)
            Supplement(
                id = "collagen-peptides-personal",
                name = "Collagen Peptides",
                brand = "Generic",
                category = "Protein",
                description = "Basic collagen peptide supplement",
                servingSize = "2 scoops (10g)",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(),
                minerals = MineralContent(sodium = 35.0),
                otherIngredients = listOf(
                    "Calories: 35",
                    "Protein: 9g"
                )
            ),

            // Enhanced Collagen Protein (Personal)
            Supplement(
                id = "enhanced-collagen-personal",
                name = "Enhanced Collagen Protein",
                brand = "Generic",
                category = "Protein",
                description = "Whey protein isolate + hydrolyzed bovine collagen with probiotics",
                servingSize = "26g",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(vitaminC = 110.0),
                minerals = MineralContent(
                    calcium = 75.0,
                    iron = 0.1,
                    magnesium = 60.0,
                    phosphorus = 350.0,
                    potassium = 150.0,
                    sodium = 110.0
                ),
                otherIngredients = listOf(
                    "Calories: 80",
                    "Protein: 20g",
                    "Multiple probiotic strains",
                    "Magnesium citrate",
                    "Potassium citrate"
                )
            ),

            // Magnesium Citrate (Personal)
            Supplement(
                id = "magnesium-citrate-personal",
                name = "Magnesium Citrate",
                brand = "Generic",
                category = "Single Mineral",
                description = "High absorption magnesium citrate",
                servingSize = "2 teaspoons (5g)",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(),
                minerals = MineralContent(magnesium = 410.0),
                otherIngredients = listOf()
            ),

            // SuperBelly Probiotic (Personal)
            Supplement(
                id = "superbelly-probiotic",
                name = "Strawberry Hibiscus Probiotic",
                brand = "SuperBelly",
                category = "Probiotic",
                description = "Probiotic with apple cider vinegar and prebiotics",
                servingSize = "1 packet (4g)",
                servingsPerContainer = null,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(vitaminC = 9.0),
                minerals = MineralContent(sodium = 65.0),
                otherIngredients = listOf(
                    "Calories: 10",
                    "Probiotics: 1 billion CFU Bacillus coagulans GBI-30 6086",
                    "Inulin (prebiotic): 1g",
                    "Apple cider vinegar powder"
                )
            ),

            // EstroSmart (Personal)
            Supplement(
                id = "estrosmart",
                name = "EstroSmart",
                brand = "Smart Solutions",
                category = "Hormone Support",
                description = "Supports estrogen balance and hormone detoxification",
                servingSize = "2 capsules",
                servingsPerContainer = 30,
                barcode = null,
                dpn = null,
                vitamins = VitaminContent(),
                minerals = MineralContent(),
                otherIngredients = listOf(
                    "Calcium D-glucarate: 150mg",
                    "Indole-3-carbinol: 150mg",
                    "Green Tea Extract: 100mg",
                    "Turmeric Extract: 50mg",
                    "DIM (Diindolylmethane): 50mg",
                    "Rosemary Extract: 25mg",
                    "Broccoli Extract: 50mg"
                ),
                targetGender = "female",
                certifications = listOf("No wheat", "No soy", "Gluten-free")
            )
        )
    }

    // Search functions
    fun searchByBarcode(barcode: String): Supplement? {
        return supplements.value.find { it.barcode == barcode }
    }

    fun searchByDPN(dpn: String): Supplement? {
        return supplements.value.find { it.dpn == dpn }
    }

    fun searchByName(name: String): List<Supplement> {
        val searchTerm = name.lowercase()
        return supplements.value.filter {
            it.name.lowercase().contains(searchTerm) ||
            it.brand.lowercase().contains(searchTerm)
        }
    }

    fun searchByCategory(category: String): List<Supplement> {
        return supplements.value.filter {
            it.category.equals(category, ignoreCase = true)
        }
    }

    fun searchByGender(gender: String): List<Supplement> {
        return supplements.value.filter {
            it.targetGender == null || it.targetGender.equals(gender, ignoreCase = true)
        }
    }

    fun getCategories(): List<String> {
        return supplements.value.map { it.category }.distinct().sorted()
    }

    fun addCustomSupplement(supplement: Supplement) {
        _supplements.value = _supplements.value + supplement
    }
}