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
    case EthereumGoerliTest = "Ethereum-Goerli Testnet"
    case EthereumSepoliaTest = "Ethereum-Sepolia Testnet"

    //BinanceSmartChain
    case BinanceSmartChain = "BinanceSmartChain"
    case BinanceSmartChainTest = "BinanceSmartChain Testnet"
    
    //Solana
    case Solana = "Solana"
    
    //KucoinCommunityChain
    case KucoinCommunityChain = "KucoinCommunityChain"

    //OkexChain
    case OkexChain = "OkexChain"

    //Polygon
    case Polygon = "Polygon Mainnet"
    case PolygonTest = "Polygon-Mumbai Testnet"

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
