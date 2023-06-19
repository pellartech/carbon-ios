//  Constants.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//

import Foundation
import BigInt

public typealias TokenId = BigUInt
public typealias AttributeId = String

public struct Constants {
    static let xdaiDropPrefix = Data.init([0x58, 0x44, 0x41, 0x49, 0x44, 0x52, 0x4F, 0x50]).hex()
    static let mainnetMagicLinkHost = "aw.app"
    static let legacyMagicLinkHost = "app.awallet.io"
    static let classicMagicLinkHost = "classic.aw.app"
    static let callistoMagicLinkHost = "callisto.aw.app"
    static let xDaiMagicLinkHost = "xdai.aw.app"
    static let goerliMagicLinkHost = "goerli.aw.app"
    static let binanceMagicLinkHost = "binance.aw.app"
    static let binanceTestMagicLinkHost = "test-binance.aw.app"
    static let hecoMagicLinkHost = "heco.aw.app"
    static let hecoTestMagicLinkHost = "test-heco.aw.app"
    static let customMagicLinkHost = "custom.aw.app"
    static let fantomMagicLinkHost = "fantom.aw.app"
    static let fantomTestMagicLinkHost = "test-fantom.aw.app"
    static let avalancheMagicLinkHost = "avalanche.aw.app"
    static let avalancheTestMagicLinkHost = "test-avalanche.aw.app"
    static let maticMagicLinkHost = "polygon.aw.app"
    static let mumbaiTestMagicLinkHost = "test-polygon.aw.app"
    static let optimisticMagicLinkHost = "optimistic.aw.app"
    static let cronosMagicLinkHost = "cronos.aw.app"
    static let cronosTestMagicLinkHost = "test-cronos.aw.app"
    static let arbitrumMagicLinkHost = "arbitrum.aw.app"
    static let palmMagicLinkHost = "palm.aw.app"
    static let palmTestnetMagicLinkHost = "palmTestnet.aw.app"
    static let klaytnCypressMagicLinkHost = "klaytnCypress.aw.app"
    static let klaytnBaobabTestnetMagicLinkHost = "klaytnBaobabTestnet.aw.app"
    static let ioTeXMagicLinkHost = "ioTeX.aw.app"
    static let ioTeXTestnetMagicLinkHost = "ioTeXTestnet.aw.app"
    static let optimismGoerliMagicLinkHost = "optimismGoerli.aw.app"
    static let arbitrumGoerliMagicLinkHost = "arbitrumGoerli.aw.app"
    static let okxMagicLinkHost = "okx.aw.app"
    static let sepoliaMagicLinkHost = "sepolia.aw.app"
    public static let legacyMagicLinkPrefix = "https://app.awallet.io/"
    static let paymentServerBaseUrl = URL(string: "https://paymaster.stormbird.sg")!
    public static let nullTokenId = "0x0000000000000000000000000000000000000000000000000000000000000000"
    public static let nullTokenIdBigUInt = BigUInt(0)
    public static let burnAddressString = "0x000000000000000000000000000000000000dEaD"
    public static let nullAddress = "0x0000000000000000000000000000000000000000"
    public static let nativeCryptoAddressInDatabase = nullAddress
    public static let ticketContractAddress = "0xA66A3F08068174e8F005112A8b2c7A507a822335"
    static let ticketContractAddressRopsten =  "0xD8e5F58DE3933E1E35f9c65eb72cb188674624F3"
    static let uefaMainnet = ( "0x89D142Bef8605646881C68dcD48cDAF17FE597dC", RPCServer.main)
    static let gnoGnosis = ("0x9c58bacc331c9aa871afd802db6379a98e80cedb", RPCServer.xDai)
    static let unstoppableDomainsV2API = URL(string: "https://resolve.unstoppabledomains.com")!
    static let unstoppableDomainsRecordKeys = ["crypto.MATIC.version.MATIC.address", "crypto.ETH.address", "crypto.MATIC.version.ERC20.address"]
    static let katContractAddress = "0x06012c8cf97bead5deae237070f9587f8e7a266d"
    public static let katNameFallback = "AlphaWallet.katNameFallback"
    static let xDaiBridge = URL(string: "https://bridge.xdaichain.com/")!
    static let arbitrumBridge = URL(string: "https://bridge.arbitrum.io/")!
    static func buyWithRampUrl(asset: String) -> String? {
        return "https://buy.ramp.network/?hostApiKey=\(Constants.Credentials.rampApiKey)&hostLogoUrl=https%3A%2F%2Falphawallet.com%2Fwp-content%2Fthemes%2Falphawallet%2Fimg%2Flogo-horizontal-new.svg&hostAppName=AlphaWallet&swapAsset=\(asset)&userAddress=\(walletAddress)"
    }
    static func buyWithCoinbaseUrl(blockchain: String) -> String? {
        let base = "https://pay.coinbase.com/buy/select-asset?appId=\(Constants.Credentials.coinbaseAppId)"
        return base + ("&destinationWallets=[{\"address\": \"\(walletAddress)\",\"blockchains\":[\"\(blockchain)\"]}]".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    }
    
    static let highStandardEthereumMainnetGasThresholdGwei = BigInt(130)
    static let legacy875Addresses = [ "0x830e1650a87a754e37ca7ed76b700395a7c61614",
                                      "0xa66a3f08068174e8f005112a8b2c7a507a822335"]
    static let legacy721Addresses = [
        "0x06012c8cf97bead5deae237070f9587f8e7a266d",
        "0xabc7e6c01237e8eef355bba2bf925a730b714d5f",
        "0x71c118b00759b0851785642541ceb0f4ceea0bd5",
        "0x7fdcd2a1e52f10c28cb7732f46393e297ecadda1"
    ]
    
    static let ensContractOnMainnet = "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85"
    public static let defaultEnabledServers: [RPCServer] = [.main, .xDai, .polygon]
    public static let defaultEnabledTestnetServers: [RPCServer] = [.goerli]
    enum TokenScript {
        static let urlSchemeForResources = "tokenscript-resource:///"
        static let validatorAPI = "https://aw.app/api/v1/verifyXMLDSig"
    }
    
    enum Enjin {
        static let apiUrl = URL(string: "https://cloud.enjin.io/graphql/default")!
    }
    
    enum BlockscanChat {
        static let blockscanChatWebUrl = URL(string: "https://chat.blockscan.com/login")!
        static let unreadCountBaseUrl = URL(string: "https://blockscan-chat-proxy.herokuapp.com")!
    }
    
    enum Coingecko {
        static let baseUrl = URL(string: "https://api.coingecko.com")!
    }
    
    enum OneInch {
        static let exchangeUrl = URL(string: "https://api.1inch.exchange")!
    }
    
    enum HoneySwap {
        static let exchangeUrl = URL(string: "https://tokens.honeyswap.org/")!
    }
    
    enum Ramp {
        static let exchangeUrl = URL(string: "https://api-instant.ramp.network")!
    }
    
    enum Covalent {
        static let apiBaseUrl = URL(string: "https://api.covalenthq.com")!
        static let newlyAddedTransactionUpdateInterval: TimeInterval = 15
        static let newlyAddedTransactionsPerPage = 100
        static let oldestTransactionUpdateInterval: TimeInterval = 25
        static let oldestAddedTransactionsPerPage = 500
        static let pendingTransactionUpdateInterval: TimeInterval = 5
    }
    
    enum BlockNumberProvider {
        static let getChainStateInterval: TimeInterval = 6
    }
    
    enum Ens {
        static let recordExpiration: TimeInterval = -(2 * 24 * 60 * 60)
    }
    
    enum Image {
        static let numberOfCharactersOfSymbolToShowInIcon = 4
    }
    
    public static let formatterFractionDigits = 2
    
    public static let etherFormatterFractionDigits = 4
    
}
