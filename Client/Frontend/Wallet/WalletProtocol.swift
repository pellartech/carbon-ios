//
//  WalletProtocol.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//
import Foundation

/// Wallet authentication protocol
protocol ConnectProtocol{
    func accountPublicAddress(address: String)
    func logout()
}
/// Add wallet after authentication protocol
protocol AddWalletProtocol{
    func addWalletDelegate()
}

/// Token enable protocol
protocol SwitchDelegate{
    func switchTapped(value: Bool,index:Int)
    
}
/// Add token protocol
protocol AddTokenDelegate{
    func initiateAddToken()
}

/// Change Network protocol
protocol ChangeNetwork {
    func changeNetworkDelegate(platforms: Platforms)
}
