import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AuthenticatableRolesTests.allTests),
        testCase(RolesAuthenticationMiddlewareTests.allTests),
        testCase(RolesGroupBuilderTests.allTests),
        testCase(RolesTests.allTests)
    ]
}
#endif
