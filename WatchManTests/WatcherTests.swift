//
//  WatchManTests.swift
//  WatchManTests
//
//  Created by Romain Pouclet on 2015-10-05.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import XCTest
import ReactiveCocoa

class WatchManTests: XCTestCase {
    
    func testAnErrorIsThrownWhenFolderDoesntExist() {
        let directory = NSTemporaryDirectory() + "/IDontExist"
        let expect = expectationWithDescription("Wait until a result is sent")
        
        watchFolder(directory).startWithError { (error) -> () in
            XCTAssertEqual(error, DirectoryWatchingError.DirectoryDoesNotExist(directory))
            expect.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error)
        }
    }

    func testAnErrorIsThrownWhenFolderIsActuallyAFileYouLittleJoker() {
        let invalidDirectory = NSTemporaryDirectory() + "/ImTheMap.dora"
        try! "🐦💣".writeToFile(invalidDirectory, atomically: false, encoding: NSUTF8StringEncoding)
        
        let expect = expectationWithDescription("Wait until a result is sent")
        
        watchFolder(invalidDirectory).startWithError { (error) -> () in
            XCTAssertEqual(error, DirectoryWatchingError.NotADirectory(invalidDirectory))
            expect.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error)
        }
        
    }

}
