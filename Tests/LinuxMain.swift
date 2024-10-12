import XCTest

import systemdTests

var tests = [XCTestCaseEntry]()
tests += systemdTests.allTests()
XCTMain(tests)
