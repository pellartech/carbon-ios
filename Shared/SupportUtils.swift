// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import Foundation
import UIKit

/// Utility functions related to SUMO and Webcompat
public struct SupportUtils {
    public static func URLForTopic(_ topic: String) -> URL? {
        return URL(string: "https://carbon.website/changelog/")
    }

    public static func URLForReportSiteIssue(_ siteUrl: String?) -> URL? {
        // Construct a NSURL pointing to the webcompat.com server to report an issue.
        //
        // It specifies the source as mobile-reporter. This helps the webcompat server to classify the issue.
        // It also adds browser-firefox-ios to the labels in the URL to make it clear
        // that this about Firefox on iOS. It makes it easier for webcompat people doing triage and diagnostics.
        // It adds a device-type label to help discriminating in between tablet and mobile devices.
        let deviceType: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "device-tablet"
        } else {
            deviceType = "device-mobile"
        }
        guard let escapedUrl = siteUrl?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        else {
            return nil
        }
        return URL(string: "https://webcompat.com/issues/new?src=mobile-reporter&label=browser-firefox-ios&label=\(deviceType)&url=\(escapedUrl)")
    }
}
