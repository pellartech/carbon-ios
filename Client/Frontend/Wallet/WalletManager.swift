//
//  WalletManager.swift
//  Client
//
//  Created by Ashok on 14/05/23.
//

import Foundation
import SwiftyUserDefaults
import ConnectCommon

extension DefaultsKeys {
    var connectedWallets: DefaultsKey<[ConnectWalletModel]> {.init(#function, defaultValue: [])}
}
    
class WalletManager {
    static let shared: WalletManager = .init()
        
    func getWallets() -> [ConnectWalletModel] {
        Defaults.connectedWallets
    }
        
    func getWallets(walletType: WalletType) -> [ConnectWalletModel] {
        Defaults.connectedWallets.filter {
            $0.walletType == walletType
        }
    }
        
    func updateWallet(_ model: ConnectWalletModel) {
        Defaults.connectedWallets.appendOrReplace(model)
    }
     
    func removeWallet(_ model: ConnectWalletModel) {
        Defaults.connectedWallets.removeAll {
            $0 == model
        }
    }
}
