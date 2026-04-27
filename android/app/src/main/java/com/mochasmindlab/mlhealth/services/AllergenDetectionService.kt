package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.FoodAllergy
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Stateless service that detects allergens in food names / ingredient lists.
 *
 * Mirrors iOS AllergenDetectionService keyword-search approach.
 * Detection is case-insensitive substring matching against a hardcoded
 * keyword map.  Only allergens the user has selected are checked — so the
 * call-site passes the saved [Set<FoodAllergy>] from [PreferencesManager].
 */
@Singleton
class AllergenDetectionService @Inject constructor() {

    // ── Keyword map ───────────────────────────────────────────────────────────
    // Each entry covers the most common synonyms / product terms seen on labels.
    // Source: FDA top-9 + EU-14 allergen guidance, mirroring iOS keywords.
    private val keywords: Map<FoodAllergy, List<String>> = mapOf(
        FoodAllergy.MILK to listOf(
            "milk", "dairy", "cheese", "butter", "cream", "yogurt", "yoghurt",
            "whey", "casein", "lactose", "ghee", "curd", "kefir", "paneer"
        ),
        FoodAllergy.EGGS to listOf(
            "egg", "eggs", "albumin", "mayonnaise", "mayo", "meringue",
            "egg white", "egg yolk", "ovalbumin", "ovomucin"
        ),
        FoodAllergy.FISH to listOf(
            "fish", "salmon", "tuna", "cod", "tilapia", "bass", "trout",
            "halibut", "anchovy", "anchovies", "sardine", "mackerel",
            "herring", "pollock", "catfish", "flounder", "snapper", "mahi"
        ),
        FoodAllergy.SHELLFISH to listOf(
            "shellfish", "shrimp", "crab", "lobster", "crayfish", "crawfish",
            "prawn", "scallop", "oyster", "mussel", "clam", "barnacle"
        ),
        FoodAllergy.TREE_NUTS to listOf(
            "almond", "cashew", "walnut", "pecan", "pistachio", "brazil nut",
            "hazelnut", "macadamia", "pine nut", "chestnut", "coconut",
            "praline", "marzipan", "nougat"
        ),
        FoodAllergy.PEANUTS to listOf(
            "peanut", "peanuts", "groundnut", "groundnuts", "arachis",
            "peanut butter", "peanut oil", "monkey nuts"
        ),
        FoodAllergy.WHEAT to listOf(
            "wheat", "flour", "bread", "pasta", "noodle", "couscous",
            "spelt", "kamut", "durum", "semolina", "farro", "einkorn",
            "triticale", "cracker", "crouton", "breadcrumb"
        ),
        FoodAllergy.SOYBEANS to listOf(
            "soy", "soya", "soybean", "tofu", "tempeh", "edamame",
            "soy sauce", "tamari", "miso", "natto", "soy lecithin",
            "soy milk", "soy protein"
        ),
        FoodAllergy.SESAME to listOf(
            "sesame", "tahini", "sesame oil", "sesame seed", "benne",
            "gingelly", "til", "tilseed"
        ),
        FoodAllergy.GLUTEN to listOf(
            "gluten", "wheat", "barley", "rye", "malt", "brewer's yeast",
            "triticale", "spelt", "kamut", "semolina", "farro"
        ),
        FoodAllergy.CORN to listOf(
            "corn", "maize", "cornmeal", "corn syrup", "cornstarch",
            "hominy", "polenta", "grits", "popcorn", "high fructose"
        ),
        FoodAllergy.SULFITES to listOf(
            "sulfite", "sulphite", "sulfur dioxide", "sulphur dioxide",
            "sodium bisulfite", "potassium bisulfite",
            "sodium metabisulfite", "potassium metabisulfite",
            "sodium sulfite", "e220", "e221", "e222", "e223", "e224"
        ),
        FoodAllergy.MUSTARD to listOf(
            "mustard", "mustard seed", "mustard oil", "mustard powder",
            "dijon", "mustard flour", "mustard leaves"
        ),
        FoodAllergy.CELERY to listOf(
            "celery", "celeriac", "celery seed", "celery salt",
            "celery root", "celery oil"
        ),
        FoodAllergy.LUPIN to listOf(
            "lupin", "lupine", "lupini", "lupin flour", "lupin seed",
            "lupin bean"
        ),
        FoodAllergy.MOLLUSKS to listOf(
            "squid", "octopus", "snail", "escargot", "abalone",
            "mollusk", "mollusc", "whelk", "periwinkle"
        ),
        FoodAllergy.LATEX to listOf(
            "latex", "natural rubber", "rubber latex"
        ),
        FoodAllergy.RED_MEAT to listOf(
            "beef", "pork", "lamb", "venison", "bison", "buffalo",
            "veal", "goat", "mutton", "bacon", "ham", "sausage",
            "salami", "chorizo", "pepperoni", "lard"
        ),
        FoodAllergy.POULTRY to listOf(
            "chicken", "turkey", "duck", "goose", "quail", "pheasant",
            "poultry", "hen", "fowl"
        ),
        FoodAllergy.CITRUS to listOf(
            "lemon", "lime", "orange", "grapefruit", "tangerine",
            "clementine", "mandarin", "citrus", "citric acid"
        ),
        FoodAllergy.TOMATO to listOf(
            "tomato", "tomatoes", "tomato sauce", "ketchup", "marinara",
            "pizza sauce", "tomato paste", "sun-dried tomato"
        ),
        FoodAllergy.CHOCOLATE to listOf(
            "chocolate", "cocoa", "cacao", "dark chocolate",
            "milk chocolate", "white chocolate", "cocoa butter",
            "cocoa powder", "fudge", "truffle"
        ),
        FoodAllergy.STRAWBERRY to listOf(
            "strawberry", "strawberries"
        )
    )

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Scan an arbitrary [text] string for any of the [allergens] the user has
     * flagged.  Returns the subset that was found.
     */
    fun detect(text: String, allergens: Set<FoodAllergy>): Set<FoodAllergy> {
        if (allergens.isEmpty() || text.isBlank()) return emptySet()
        val lower = text.lowercase()
        return allergens.filter { allergy ->
            keywords[allergy]?.any { keyword -> lower.contains(keyword) } == true
        }.toSet()
    }

    /**
     * Convenience overload that concatenates a [FoodEntry]'s name + brand
     * before scanning.
     */
    fun detectIn(foodEntry: FoodEntry, allergens: Set<FoodAllergy>): Set<FoodAllergy> {
        val text = foodEntry.name + " " + (foodEntry.brand ?: "")
        return detect(text, allergens)
    }

    /**
     * Convenience overload that scans a flat list of ingredient strings.
     * All items are joined into a single string for one-pass detection.
     */
    fun detectInIngredients(ingredients: List<String>, allergens: Set<FoodAllergy>): Set<FoodAllergy> {
        return detect(ingredients.joinToString(" "), allergens)
    }
}
