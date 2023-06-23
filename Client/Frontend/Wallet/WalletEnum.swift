//
//  WalletEnum.swift
//  Client
//
//  Created by Ashok on 14/06/23.
//

import Foundation
enum NetworkEnum : String,CaseIterable {
    //Ethereum
    case Ethereum = "Ethereum"
    case EthereumGoerliTest = "Ethereum Goerli Testnet"
    case EthereumSepoliaTest = "Ethereum Sepolia Testnet"

    //BinanceSmartChain
    case BinanceSmartChain = "Binance Smart Chain"
    case BinanceSmartChainTest = "Binance Smart Chain Testnet"
    
    //Solana
    case Solana = "Solana"
    
    //KucoinCommunityChain
    case KucoinCommunityChain = "Kucoin Community Chain"

    //OkexChain
    case OkexChain = "Okex Chain"

    //Polygon
    case Polygon = "Polygon"
    case PolygonTest = "Polygon Mumbai Testnet"

}

enum NetworkSymbolEnum : String {
    case Ethereum = "ETH"
    case EthereumGoerliTest = "GETH"
    case EthereumSepoliaTest = "SETH"
    case BinanceSmartChain = "BNB"
    case BinanceSmartChainTest = "TBNB"
    case Solana = "SOL"
    case KucoinCommunityChain = "KCC"
    case OkexChain = "OKC"
    case OkexChainTest = "OKT"
    case Polygon = "MATIC"

}
