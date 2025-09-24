import XCTest

class AppScreenshots: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app) // If using Fastlane Snapshot
        app.launch()
    }
    
    func testCaptureScreenshots() {
        let app = XCUIApplication()
        
        // Dashboard
        takeScreenshot(named: "01_Dashboard")
        
        // Navigate to Food Tracking
        app.tabBars.buttons["Food"].tap()
        takeScreenshot(named: "02_FoodTracking")
        
        // Navigate to Exercise
        app.tabBars.buttons["Exercise"].tap()
        takeScreenshot(named: "03_Exercise")
        
        // Navigate to More
        app.tabBars.buttons["More"].tap()
        takeScreenshot(named: "04_More")
        
        // Add more screens as needed
    }
    
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}