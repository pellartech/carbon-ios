//// This Source Code Form is subject to the terms of the Mozilla Public
//// License, v. 2.0. If a copy of the MPL was not distributed with this
//// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import Client
import Storage
import Shared
import MozillaAppServices

import Foundation
import XCTest

import Glean

class MockSyncDelegate {
    func displaySentTab(for url: URL, title: String, from deviceName: String?) {
    }
}

class MockBrowserSyncManager: BrowserProfile.BrowserSyncManager {
    override func getProfileAndDeviceId() -> (MozillaAppServices.Profile, String) {
        return (MozillaAppServices.Profile(
            uid: "test",
            email: "test@test.test",
            displayName: nil,
            avatar: "",
            isDefaultAvatar: true
        ), "test")
    }
}

class GleanTelemetryTests: XCTestCase {
    override func setUp() {
        Glean.shared.resetGlean(clearStores: false)
        Glean.shared.enableTestingMode()

    }

    func testSyncPingIsSentOnSyncOperation() throws {
        let profile = MockBrowserProfile(localName: "GleanTelemetryTests")
        let syncManager = MockBrowserSyncManager(profile: profile)

        let syncPingWasSent = expectation(description: "The tempSync ping was sent")

        waitForExpectations(timeout: 5.0)
    }
}
