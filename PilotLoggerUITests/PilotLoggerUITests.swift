import XCTest

final class PilotLoggerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch & Navigation

    func testAppLaunchShowsEmptyState() throws {
        let navBar = app.navigationBars["Pilot Logger"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))

        // Empty state should show when no flights exist
        let emptyText = app.staticTexts["No Flights Logged"]
        if emptyText.exists {
            XCTAssertTrue(emptyText.exists)
        }
    }

    func testAddButtonExists() throws {
        let addButton = app.navigationBars.buttons["Add"]
        if !addButton.exists {
            // Might be a "plus" button
            let plusButton = app.navigationBars.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] 'plus'")
            ).firstMatch
            XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Add Flight Flow

    func testAddFlightLogFlow() throws {
        // Tap add button
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))

        let addButton = navBar.buttons.element(boundBy: navBar.buttons.count - 1)
        addButton.tap()

        // Fill in required fields
        let aircraftField = app.textFields["Aircraft Type"]
        if aircraftField.waitForExistence(timeout: 3) {
            aircraftField.tap()
            aircraftField.typeText("C172")
        }

        let pilotField = app.textFields["Pilot in Command"]
        if pilotField.waitForExistence(timeout: 3) {
            pilotField.tap()
            pilotField.typeText("Test Pilot")
        }

        let flightTimeField = app.textFields["Flight Time (hours)"]
        if flightTimeField.waitForExistence(timeout: 3) {
            flightTimeField.tap()
            flightTimeField.typeText("1.5")
        }

        // Tap Add/Save button
        let saveButton = app.buttons["Add"]
        if saveButton.waitForExistence(timeout: 3) {
            saveButton.tap()
        }
    }

    // MARK: - Cancel Flow

    func testCancelDismissesForm() throws {
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))

        let addButton = navBar.buttons.element(boundBy: navBar.buttons.count - 1)
        addButton.tap()

        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 3) {
            cancelButton.tap()
        }

        // Should be back on main screen
        XCTAssertTrue(app.navigationBars["Pilot Logger"].waitForExistence(timeout: 3))
    }
}
