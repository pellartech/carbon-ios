// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

@testable import Client

import Shared
import Storage
import XCTest

private class RandomError: MaybeErrorType {
    var description = "random_error"
}

class SyncStatusResolverTests: XCTestCase {
   

    func testAllCompleted() {
       
    }

    func testAllCompletedExceptOneDisabledRemotely() {
        
    }

    func testAllCompletedExceptNotStartedBecauseNoAccount() {
        
    }

    func testAllCompletedExceptNotStartedBecauseOffline() {
        
    }

    func testOfflineAndNoAccount() {
      
    }

    func testAllPartial() {
      
    }

    func testRandomFailure() {
       
    }
}
