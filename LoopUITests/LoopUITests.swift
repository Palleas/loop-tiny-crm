//
//  LoopUITests.swift
//  LoopUITests
//
//  Created by Romain Pouclet on 2017-06-21.
//  Copyright © 2017 Perfectly-Cooked. All rights reserved.
//

import XCTest

class LoopUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testThatItStartsTheAuthWithTwitterFlow() {

    }
}
