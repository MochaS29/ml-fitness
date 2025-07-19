import SwiftUI

// MARK: - Mocha's Mindful Tech Brand Colors
extension Color {
    // Core Brand Colors
    static let mochaBrown = Color(red: 139/255, green: 69/255, blue: 19/255)      // #8B4513
    static let mindfulTeal = Color(red: 74/255, green: 155/255, blue: 155/255)    // #4A9B9B
    static let wellnessGreen = Color(red: 127/255, green: 176/255, blue: 105/255) // #7FB069
    static let softCream = Color(red: 249/255, green: 247/255, blue: 244/255)     // #F9F7F4
    
    // Supporting Neutrals
    static let warmWhite = Color(red: 254/255, green: 254/255, blue: 254/255)     // #FEFEFE
    static let lightGray = Color(red: 232/255, green: 230/255, blue: 227/255)     // #E8E6E3
    static let deepCharcoal = Color(red: 44/255, green: 44/255, blue: 44/255)     // #2C2C2C
    
    // App Specific Colors (matching brand psychology)
    static let primaryAccent = mochaBrown        // Headers, Navigation, Primary Branding
    static let secondaryAccent = mindfulTeal     // Focus features, Secondary CTAs
    static let successGreen = wellnessGreen      // Health features, Success states
    static let background = softCream            // Main background
    static let cardBackground = warmWhite        // Card surfaces
    static let primaryText = deepCharcoal        // Primary text
    
    // Nutrient status colors (aligned with brand)
    static let adequateGreen = wellnessGreen
    static let deficientOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let excessiveRed = Color(red: 204/255, green: 65/255, blue: 37/255)
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.mochaBrown)
            .foregroundColor(.warmWhite)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.mindfulTeal)
            .foregroundColor(.warmWhite)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.lightGray.opacity(0.3))
            .foregroundColor(.deepCharcoal)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Card Styles
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.lightGray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Text Styles (Following Mocha's Mindful Tech Typography)
extension Text {
    func brandTitleStyle() -> some View {
        self
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.mochaBrown)
    }
    
    func headlineStyle() -> some View {
        self
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(.deepCharcoal)
    }
    
    func subheadlineStyle() -> some View {
        self
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.mindfulTeal)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.deepCharcoal)
    }
    
    func captionStyle() -> some View {
        self
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(.lightGray)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func primaryButton() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryButton() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }
    
    func tertiaryButton() -> some View {
        buttonStyle(TertiaryButtonStyle())
    }
    
    func brandBackground() -> some View {
        self.background(Color.softCream)
    }
}

// MARK: - Input Field Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.warmWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
    }
}

// MARK: - Health Status Colors (Wellness-focused)
extension Color {
    static func nutrientStatusColor(for percentage: Double) -> Color {
        switch percentage {
        case 0..<50: return deficientOrange
        case 50..<75: return mindfulTeal
        case 75..<125: return wellnessGreen
        case 125..<150: return mindfulTeal
        default: return excessiveRed
        }
    }
}