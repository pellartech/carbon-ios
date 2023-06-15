// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/
//

import Foundation
import CoreData


extension Tokens {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tokens> {
        return NSFetchRequest<Tokens>(entityName: "Tokens")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var symbol: String?
    @NSManaged public var address: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var isAdded: Bool
    @NSManaged public var network: NSSet?

}

// MARK: Generated accessors for network
extension Tokens {

    @objc(addNetworkObject:)
    @NSManaged public func addToNetwork(_ value: Networks)

    @objc(removeNetworkObject:)
    @NSManaged public func removeFromNetwork(_ value: Networks)

    @objc(addNetwork:)
    @NSManaged public func addToNetwork(_ values: NSSet)

    @objc(removeNetwork:)
    @NSManaged public func removeFromNetwork(_ values: NSSet)

}

extension Tokens : Identifiable {

}
