//
//  Osanyin__Herbal_Remedy_UITestsLaunchTests.swift
//  Osanyin (Herbal Remedy)UITests
//
//  Created by  Yomi Ajayi on 7/28/25.
//

import XCTest

final class Osanyin__Herbal_Remedy_UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
