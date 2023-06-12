//
//  SelectWalletModel.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//
import ConnectCommon
import Foundation
import UIKit
import SwiftyUserDefaults

class AccountModel {
    
    var title: String?
    var image: String?
    var walletType: WalletType?
    var isConnected: Bool?
    
    init(title: String?,image: String?,isConnected : Bool?, walletType: WalletType?){
        self.title = title
        self.image = image
        self.isConnected = isConnected
        self.walletType = walletType
        
    }
}

class WalletsAddressModel {
    
    var chainName: String?
    var publicAddress: String?
    
    init(chainName: String?,publicAddress: String?){
        self.chainName = chainName
        self.publicAddress = publicAddress
    }
}

extension WalletType: CaseIterable {
    public static var allCases: [WalletType] {
        return [.particle, .metaMask, .rainbow, .trust, .imtoken, .bitkeep, .walletConnect, .phantom, .evmPrivateKey, .solanaPrivateKey, .gnosis]
    }
    
    var name: String {
        return info.name
    }
    
    var imageName: String {
        return self.info.icon
    }
}

struct SelectWalletModel {
    let name: String
    let image: UIImage
}

struct ConnectWalletModel: Codable, Equatable, DefaultsSerializable {
    let publicAddress: String
    let name: String?
    let url: String?
    let icons: [String]
    let description: String?
    var isSelected: Bool
    let walletType: WalletType
    var chainId: Int
    
    public static var _defaults: DefaultsCodableBridge<ConnectWalletModel>
    { return DefaultsCodableBridge<ConnectWalletModel>() }
    
    public static var _defaultsArray: DefaultsCodableBridge<[ConnectWalletModel]>
    { return DefaultsCodableBridge<[ConnectWalletModel]>() }
    
    static func == (lhs: ConnectWalletModel, rhs: ConnectWalletModel) -> Bool {
        if lhs.walletType == .particle && rhs.walletType == .particle {
            return true
        } else {
            return lhs.publicAddress.lowercased() == rhs.publicAddress.lowercased() && lhs.walletType == rhs.walletType
        }
        
    }
}
class Token {
    var id: String?
    var name: String?
    var address: String?
    var symbol: String?
    var icon: UIImage?
    var isAdded: Bool?
    
    init(id: String?,name: String?,address: String?,symbol : String?,icon: UIImage?,isAdded: Bool?){
        self.id = id
        self.name = name
        self.address = address
        self.symbol = symbol
        self.icon = icon
        self.isAdded = isAdded
    }
}
struct TokenList : Decodable{
    var id : String
    var name : String
    var symbol : String
}

struct TokensInfo : Decodable{
    var id : String?
    var name : String?
    var symbol : String?
    var contract_address : String?
    var image : TokenImages?
    var description : TokenDescrip?
    var asset_platform_id: String?
    var platforms : [String:String]?
    var detail_platforms : [String:DetailsPlatforms]?
    var network : String?
}
struct DetailsPlatforms : Decodable{
    var decimal_place : Int?
    var contract_address : String?
}

struct TokenImages : Decodable{
    var large : String?
    var small : String?
    var thumb : String?
}

struct TokenDescrip : Decodable{
    var en : String?
}

class Platforms {
    var name: String?
    var address : String?

    init(name: String?,address: String?){
        self.name = name
        self.address = address
    }
}
