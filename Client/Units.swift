// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
public struct Units {
  
  public let bytes: Int64
  
  public var kilobytes: Double {
    return Double(bytes)
  }
  
  public var megabytes: Double {
    return kilobytes / 1_024
  }
  
  public var gigabytes: Double {
    return megabytes / 1_024
  }
  
  public init(bytes: Int64) {
    self.bytes = bytes
  }
  
  public func getReadableUnit() -> String {
    
    switch bytes {
    case 0..<1_024:
        return "\(String(format: "%.2f", kilobytes))KB"
    case 1_024..<(1_024 * 1_024):
      return "\(String(format: "%.2f", megabytes))MB"
    case 1_024..<(1_024 * 1_024 * 1_024):
      return "\(String(format: "%.2f", gigabytes))GB"
    default:
      return "\(bytes)KB"
    }
  }
}
