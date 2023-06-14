// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import CoreData

struct TokensData: Codable {
    var id:  String?
    var name: String?
    var symbol: String?
    var created_time: Int64?
    var isUserToken: Bool?
    var address: String?
    var imageUrl: String?

    // MARK: - Helper method: Convert managed objects to objects
    func toManagedObject(in context: NSManagedObjectContext, network: Networks) -> Tokens? {
        let entity = Tokens.entity()
        let tokens = Tokens(entity: entity, insertInto: context)
        tokens.id = id
        tokens.name = name
        tokens.symbol = symbol
        tokens.address = address
        tokens.imageUrl = imageUrl
        tokens.isUserToken = isUserToken ?? false
        tokens.created_time = created_time ?? 0
        network.token = tokens
        return tokens
    }
}
