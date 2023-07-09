//
//  enum.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//

import Foundation
import BigInt

public enum DappAction {
    case signMessage(String)
    case signPersonalMessage(String)
    case signTransaction(UnconfirmedTransaction)
    case sendTransaction(UnconfirmedTransaction)
    case sendRawTransaction(String)
    case ethCall(from: String, to: String, value: String?, data: String)
    case walletAddEthereumChain(WalletAddEthereumChainObject)
    case walletSwitchEthereumChain(WalletSwitchEthereumChainObject)
    case unknown
}

public enum WebViewType {
    case dappBrowser(RPCServer)
    case tokenScriptRenderer
}

public enum Method: String, Decodable {
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case signTypedMessage
    case ethCall
    case unknown
    
    public init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}

enum TransactionsSource {
    case etherscan(apiKey: String?, apiUrl: URL)
    case blockscout(apiKey: String?, apiUrl: URL)
    case covalent(apiKey: String?)
    case oklink(apiKey: String?)
    case unknown
}

public enum RPCServerWithEnhancedSupport {
    case main
    case xDai
    case polygon
    case binance_smart_chain
    case heco
    case rinkeby
    case arbitrum
    case klaytnCypress
    case klaytnBaobabTestnet
}

public enum GasPrice: Hashable, Equatable, Codable {
    case legacy(gasPrice: BigUInt)
    case eip1559(maxFeePerGas: BigUInt, maxPriorityFeePerGas: BigUInt)
    
    public var max: BigUInt {
        switch self {
        case .legacy(let gasPrice): return gasPrice
        case .eip1559(let maxFeePerGas, _): return maxFeePerGas
        }
    }
    
    enum LegacyCodingKeys: CodingKey {
        case gasPrice
    }
    
    enum Eip1559CodingKeys: CodingKey {
        case maxFeePerGas
        case maxPriorityFeePerGas
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: LegacyCodingKeys.self)
            let gasPriceString = try container.decode(String.self, forKey: .gasPrice)
            
            let gasPrice = BigUInt(gasPriceString.drop0x, radix: 16) ?? .zero
            
            self = .legacy(gasPrice: gasPrice)
        } catch {
            let container = try decoder.container(keyedBy: Eip1559CodingKeys.self)
            let maxFeePerGasString = try container.decode(String.self, forKey: .maxFeePerGas)
            let maxPriorityFeePerGasString = try container.decode(String.self, forKey: .maxPriorityFeePerGas)
            
            let maxFeePerGas = BigUInt(maxFeePerGasString.drop0x, radix: 16) ?? .zero
            let maxPriorityFeePerGas = BigUInt(maxPriorityFeePerGasString.drop0x, radix: 16) ?? .zero
            
            self = .eip1559(maxFeePerGas: maxFeePerGas, maxPriorityFeePerGas: maxPriorityFeePerGas)
        }
    }
}

public enum DappCallbackValue {
    case signTransaction(Data)
    case sentTransaction(Data)
    case signMessage(Data)
    case signPersonalMessage(Data)
    case ethCall(String)
    case walletAddEthereumChain
    case walletSwitchEthereumChain
    
    public var object: String {
        switch self {
        case .signTransaction(let data):
            return data.hexEncoded
        case .sentTransaction(let data):
            return data.hexEncoded
        case .signMessage(let data):
            return data.hexEncoded
        case .signPersonalMessage(let data):
            return data.hexEncoded
        case .ethCall(let value):
            return value
        case .walletAddEthereumChain:
            return ""
        case .walletSwitchEthereumChain:
            return ""
        }
    }
}

public enum DappOrWalletCommand {
    case eth(DappCommand)
    case walletAddEthereumChain(AddCustomChainCommand)
    case walletSwitchEthereumChain(SwitchChainCommand)
    
    public var id: Int {
        switch self {
        case .eth(let command):
            return command.id
        case .walletAddEthereumChain(let command):
            return command.id
        case .walletSwitchEthereumChain(let command):
            return command.id
        }
    }
}

public enum TokenScript {
}

public enum PromiseError: Error {
    case some(error: Error)

    public init(error: Error) {
        if let e = error as? PromiseError {
            self = e
        } else {
            self = .some(error: error)
        }
    }
    
    public var embedded: Error {
        switch self {
        case .some(let error):
            return error
        }
    }
}
