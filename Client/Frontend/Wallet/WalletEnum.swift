//
//  WalletEnum.swift
//  Client
//
//  Created by Ashok on 14/06/23.
//

import Foundation
enum NetworkEnum : String,CaseIterable {
    
    //BinanceSmartChain
    case BinanceSmartChain = "Binance Smart Chain"
    case BinanceSmartChainTest = "Binance Smart Chain Testnet"
    
    //Ethereum
    case Ethereum = "Ethereum"
    case EthereumGoerliTest = "Ethereum Goerli Testnet"
    case EthereumSepoliaTest = "Ethereum Sepolia Testnet"
    
    //KucoinCommunityChain
    case KucoinCommunityChain = "Kucoin Community Chain"
    
    //OkexChain
    case OkexChain = "Okex Chain"
    
    //Polygon
    case Polygon = "Polygon"
    case PolygonTest = "Polygon Mumbai Testnet"
    
    //Solana
    case Solana = "Solana"
    
    func isTest() -> Bool {
        switch self {
        case .EthereumGoerliTest, .EthereumSepoliaTest, .BinanceSmartChainTest, .PolygonTest:
            return  true
        default:
            return false
        }
    }
    
    func nativeSymbol() -> String {
        switch self {
        case .BinanceSmartChain,.BinanceSmartChainTest:
            return "BNB"
        case .Ethereum:
            return "ETH"
        case .EthereumGoerliTest:
            return "GETH"
        case .EthereumSepoliaTest:
            return "SETH"
        case .KucoinCommunityChain:
            return "KCC"
        case .OkexChain:
            return "OKC"
        case .Polygon, .PolygonTest:
            return "MATIC"
        case .Solana:
            return "SOL"
        }
    }
}
