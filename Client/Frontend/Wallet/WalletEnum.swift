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
    func chainID() -> Int32 {
        switch self {
        case .BinanceSmartChain: return 56
        case .BinanceSmartChainTest:return 97
        case .Ethereum: return 1
        case .EthereumGoerliTest: return 5
        case .EthereumSepoliaTest: return 11155111
        case .KucoinCommunityChain: return 1
        case .OkexChain: return 66
        case .Polygon:  return 137
        case .PolygonTest:  return 80001
        case .Solana: return 1
        }
    }
}
