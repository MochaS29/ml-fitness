import SwiftUI

struct DataSourcesView: View {
    var body: some View {
        List {
            Section("Nutrition Data") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("USDA FoodData Central")
                        .font(.headline)
                    Text("Nutritional information in this app is sourced from the USDA FoodData Central database, which contains data on over 600,000 foods.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Link("fdc.nal.usda.gov", destination: URL(string: "https://fdc.nal.usda.gov")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }

            Section("Activity & Exercise Guidelines") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("WHO Physical Activity Guidelines")
                        .font(.headline)
                    Text("Exercise recommendations are based on the World Health Organization's global guidelines on physical activity and sedentary behaviour.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Link("who.int/physical-activity", destination: URL(string: "https://www.who.int/news-room/fact-sheets/detail/physical-activity")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("USDA Dietary Guidelines for Americans")
                        .font(.headline)
                    Text("Daily calorie, macro, and hydration targets are informed by the USDA Dietary Guidelines for Americans (2020–2025).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Link("dietaryguidelines.gov", destination: URL(string: "https://www.dietaryguidelines.gov")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }

            Section("Supplements & Vitamins") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NIH Office of Dietary Supplements")
                        .font(.headline)
                    Text("Recommended Daily Allowance (RDA) values for vitamins and minerals are based on the National Institutes of Health Office of Dietary Supplements.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Link("ods.od.nih.gov", destination: URL(string: "https://ods.od.nih.gov")!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }

            Section("Health Disclaimer") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Not Medical Advice")
                        .font(.headline)
                    Text("MindLab Fitness is a general wellness and nutrition tracking app. The information provided is for informational purposes only and is not intended as a substitute for professional medical advice, diagnosis, or treatment.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Always seek the guidance of a qualified health provider with any questions you may have regarding your health, diet, or fitness goals.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Data Sources")
        .navigationBarTitleDisplayMode(.inline)
    }
}
