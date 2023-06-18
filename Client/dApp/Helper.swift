//
//  Helper.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//

import Foundation
import WebKit
import BigInt
import Combine

struct BrowserViewModelInput {
    let progress: AnyPublisher<Double, Never>
    let decidePolicy: AnyPublisher<DecidePolicy, Never>
}

struct BrowserViewModelOutput {
    let universalLink: AnyPublisher<URL, Never>
    let recordUrl: AnyPublisher<Void, Never>
    let dappAction: AnyPublisher<(action: DappAction, callbackId: Int), Never>
}

struct Keys {
    static let developerExtrasEnabled = "developerExtrasEnabled"
    static let ClientName = "Carbon"
}

public final class ScriptMessageProxy: NSObject, WKScriptMessageHandler {
    
    private weak var delegate: WKScriptMessageHandler?
    
    public init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

struct HackToAllowUsingSafaryExtensionCodeInDappBrowser {
    private static func javaScriptForSafaryExtension() -> String {
        var js = String()
        
        if let filepath = Bundle.main.path(forResource: "config", ofType: "js"), let content = try? String(contentsOfFile: filepath) {
            js += content
        }
        if let filepath = Bundle.main.path(forResource: "helpers", ofType: "js"), let content = try? String(contentsOfFile: filepath) {
            js += content
        }
        return js
    }
    
    static func injectJs(to webViewConfig: WKWebViewConfiguration) {
        func encodeStringTo64(fromString: String) -> String? {
            let plainData = fromString.data(using: .utf8)
            return plainData?.base64EncodedString(options: [])
        }
        var js = javaScriptForSafaryExtension()
        js += """
                const overridenElementsForAlphaWalletExtension = new Map();
                function runOnStart() {
                    function applyURLsOverriding(options, url) {
                        let elements = overridenElementsForAlphaWalletExtension.get(url);
                        if (typeof elements != 'undefined') {
                            overridenElementsForAlphaWalletExtension(elements)
                        }
        
                        overridenElementsForAlphaWalletExtension.set(url, retrieveAllURLs(document, options));
                    }
        
                    const url = document.URL;
                    applyURLsOverriding(optionsByDefault, url);
                }
        
                if(document.readyState !== 'loading') {
                    runOnStart();
                } else {
                    document.addEventListener('DOMContentLoaded', function() {
                        runOnStart()
                    });
                }
        """
        
        let jsStyle = """
            javascript:(function() {
            var parent = document.getElementsByTagName('body').item(0);
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.innerHTML = window.atob('\(encodeStringTo64(fromString: js)!)');
            parent.appendChild(script)})()
        """
        
        let userScript = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webViewConfig.userContentController.addUserScript(userScript)
    }
}

public struct UnconfirmedTransaction {
    public let value: BigUInt
    public let recipient: String?
    public let contract: String?
    public let data: Data
    public let gasLimit: BigUInt?
    public let gasPrice: GasPrice?
    public let nonce: BigUInt?
    
    public init(
        value: BigUInt,
        recipient: String?,
        contract: String?,
        data: Data = Data(),
        gasLimit: BigUInt? = nil,
        gasPrice: GasPrice? = nil,
        nonce: BigUInt? = nil) {
            
            self.value = value
            self.recipient = recipient
            self.contract = contract
            self.data = data
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            self.nonce = nonce
        }
}

public struct DappCommand: Decodable {
    public let name: Method
    public let id: Int
    public let object: [String: DappCommandObjectValue]
}

public struct DappCommandWithOptionalObjectValues: Decodable {
    public let name: Method
    public let id: Int
    public let object: [String: DappCommandObjectValue?]
    
    public var toCommand: DappCommand {
        return DappCommand(name: name, id: id, object: object.compactMapValues { $0 })
    }
}

public struct AddCustomChainCommand: Decodable {
    public enum Method: String, Decodable {
        case walletAddEthereumChain
        
        public init?(string: String) {
            if let s = Method(rawValue: string) {
                self = s
            } else {
                return nil
            }
        }
    }
    
    public let name: Method
    public let id: Int
    public let object: WalletAddEthereumChainObject
}

public struct SwitchChainCommand: Decodable {
    public enum Method: String, Decodable {
        case walletSwitchEthereumChain
        
        public init?(string: String) {
            if let s = Method(rawValue: string) {
                self = s
            } else {
                return nil
            }
        }
    }
    
    public let name: Method
    public let id: Int
    public let object: WalletSwitchEthereumChainObject
}

public struct DappCallback {
    public let id: Int
    public let value: DappCallbackValue
    
    public init(id: Int, value: DappCallbackValue) {
        self.id = id
        self.value = value
    }
}

public struct DappCommandObjectValue: Decodable {
    public var value: String = ""
    
    
    public init(from coder: Decoder) throws {
        let container = try coder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = String(boolValue)
        } else {
            
        }
    }
}

public struct WalletAddEthereumChainObject: Decodable, CustomStringConvertible {
    public struct NativeCurrency: Decodable, CustomStringConvertible {
        public let name: String
        public let symbol: String
        public let decimals: Int
        
        public var description: String {
            return "{name: \(name), symbol: \(symbol), decimals:\(decimals) }"
        }
        public init(name: String, symbol: String, decimals: Int) {
            self.name = name
            self.symbol = symbol
            self.decimals = decimals
        }
    }
    
    public struct ExplorerUrl: Decodable {
        let name: String
        let url: String
        
        enum CodingKeys: CodingKey {
            case name
            case url
        }
        
        public init(name: String, url: String) {
            self.url = url
            self.name = name
        }
        
        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                url = try container.decode(String.self)
                name = String()
            } catch {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                name = try container.decode(String.self, forKey: .name)
                url = try container.decode(String.self, forKey: .url)
            }
        }
    }
    
    public let nativeCurrency: NativeCurrency?
    public var blockExplorerUrls: [ExplorerUrl]?
    public let chainName: String?
    public let chainId: String
    public let rpcUrls: [String]?
    
    public var server: RPCServer? {
        return Int(chainId0xString: chainId).flatMap { RPCServer(chainIdOptional: $0) }
    }
    
    public init(nativeCurrency: NativeCurrency?, blockExplorerUrls: [ExplorerUrl]?, chainName: String?, chainId: String, rpcUrls: [String]?) {
        self.nativeCurrency = nativeCurrency
        self.blockExplorerUrls = blockExplorerUrls
        self.chainName = chainName
        self.chainId = chainId
        self.rpcUrls = rpcUrls
    }
    
    public var description: String {
        return "{ blockExplorerUrls: \(String(describing: blockExplorerUrls)), chainName: \(String(describing: chainName)), chainId: \(String(describing: chainId)), rpcUrls: \(String(describing: rpcUrls)), nativeCurrency: \(String(describing: nativeCurrency)) }"
    }
}

public struct WalletSwitchEthereumChainObject: Decodable, CustomStringConvertible {
    public let chainId: String
    public var server: RPCServer? {
        return Int(chainId0xString: chainId).flatMap { RPCServer(chainIdOptional: $0) }
    }
    
    public var description: String {
        return "chainId: \(chainId)"
    }
}
