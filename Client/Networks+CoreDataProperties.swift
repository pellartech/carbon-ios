// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/
//

import Foundation
import CoreData


extension Networks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Networks> {
        return NSFetchRequest<Networks>(entityName: "Networks")
    }

    @NSManaged public var name: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var isTest: Bool
    @NSManaged public var tokens: NSSet?

}

// MARK: Generated accessors for tokens
extension Networks {

    @objc(addTokensObject:)
    @NSManaged public func addToTokens(_ value: Tokens)

    @objc(removeTokensObject:)
    @NSManaged public func removeFromTokens(_ value: Tokens)

    @objc(addTokens:)
    @NSManaged public func addToTokens(_ values: NSSet)

    @objc(removeTokens:)
    @NSManaged public func removeFromTokens(_ values: NSSet)

}

extension Networks : Identifiable {

}
