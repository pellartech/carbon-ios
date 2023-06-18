//
//  Extension.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//

import Foundation
import WebKit
import JavaScriptCore
import UIKit
import BigInt
extension Constants {
    public enum Credentials {
        private static var cachedDevelopmentCredentials: [String: String]? = readDevelopmentCredentialsFile()
        
        private static func readDevelopmentCredentialsFile() -> [String: String]? {
            guard let sourceRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] else {
                print("[Credentials] No .credentials file found for development because SOURCE_ROOT is not set")
                return nil
            }
            let fileName = "\(sourceRoot)/.credentials"
            guard let fileContents = try? String(contentsOfFile: fileName) else {
                print("[Credentials] No .credentials file found for development at \(fileName)")
                return nil
            }
            let lines = fileContents.components(separatedBy: .newlines)
            let keyValues: [(String, String)] = lines.compactMap { line -> (String, String)? in
                Constants.Credentials.functional.extractKeyValueCredentials(line)
            }
            let dict = Dictionary(uniqueKeysWithValues: keyValues)
            print("[Credentials] Loaded .credentials file found for development with key count: \(dict.count)")
            return dict
        }
        
        private static func env(_ name: String) -> String? {
            if let value = ProcessInfo.processInfo.environment[name], !value.isEmpty {
                return value
            } else {
                return nil
            }
            
        }
        public static let analyticsKey = ""
        public static let mailChimpListSpecificKey = ""
        public static let walletConnectProjectId = env("WALLETCONNECTPROJECTID") ?? "8ba9ee138960775e5231b70cc5ef1c3a"
        static let infuraKey = env("INFURAKEY") ?? "ad6d834b7a1e4d03a7fde92020616149"
        static let oklinkKey = env("OKLINKKEY") ?? "5698875f-1b76-45a1-8790-e1671f14cdeb"
        static let etherscanKey = env("ETHERSCANKEY") ?? "1PX7RG8H4HTDY8X55YRMCAKPZK476M23ZR"
        static let binanceSmartChainExplorerApiKey: String? = env("BINANCESMARTCHAINEXPLORERAPIKEY")
        static let polygonScanExplorerApiKey: String? = env("POLYGONSCANEXPLORERAPIKEY")
        static let avalancheExplorerApiKey = env("AVALANCHEEXPLORERAPIKEY")
        static let arbiscanExplorerApiKey = env("ARBISCANEXPLORERAPIKEY")
        static let xDaiExplorerKey = env("XDAIEXPLORERKEY")
        static let paperTrail = (host: env("PAPERTRAILHOST") ?? "", port: (env("PAPERTRAILPORT") ?? "").toInt() ?? 0)
        static let openseaKey = env("OPENSEAKEY") ?? nil
        static let rampApiKey = env("RAMPAPIKEY") ?? "j5wr7oqktym7z69yyf84bb8a6cqb7qfu5ynmeyvn"
        static let coinbaseAppId = env("COINBASEAPPID") ?? ""
        static let enjinUserName = env("ENJINUSERNAME")
        static let enjinUserPassword = env("ENJINUSERPASSWORD")
        static let unstoppableDomainsV2ApiKey = env("UNSTOPPABLEDOMAINSV2KEY") ?? "Bearer rLuujk_dLBN-JDE6Xl8QSCg-FeIouRKM"
        static let blockscanChatProxyKey = env("BLOCKSCHATPROXYKEY") ?? ""
        static let covalentApiKey = env("COVALENTAPIKEY") ?? "ckey_7ee61be7f8364ba784f697510bd"
        static let klaytnRpcNodeCypressKey = env("KLAYTNRPCNODECYPRESSKEY") ?? ""
        static let klaytnRpcNodeBaobabKey = env("KLAYTNRPCNODEBAOBABKEY") ?? ""
        public static let notificationsApiKey = env("NOTIFICATIONSAPIKEY")
    }
}

extension String {
    public func toInt() -> Int? {
        return Int(self)
    }
}

extension Constants.Credentials {
    public enum functional {}
}

extension Constants.Credentials.functional {
    public static func extractKeyValueCredentials(_ line: String) -> (key: String, value: String)? {
        let keyValue = line.components(separatedBy: "=")
        if keyValue.count == 2 {
            return (keyValue[0], keyValue[1])
        } else if keyValue.count > 2 {
            return (keyValue[0], keyValue[1..<keyValue.count].joined(separator: "="))
        } else {
            return nil
        }
    }
}

extension WKWebViewConfiguration {
    public static func make(forType type: WebViewType, messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let webViewConfig = WKWebViewConfiguration()
        var js = ""
        
        switch type {
        case .dappBrowser(let server):
            
            if let filepath = Bundle.main.path(forResource: "AlphaWallet-min", ofType: "js") {
                do {
                    js += try String(contentsOfFile: filepath)
                } catch { }
            }
            js += javaScriptForDappBrowser(server: server)
        case .tokenScriptRenderer:
            js += javaScriptForTokenScriptRenderer()
            js += """
                  \n
                  web3.tokens = {
                      data: {
                          currentInstance: {
                          },
                          token: {
                          },
                          card: {
                          },
                      },
                      dataChanged: (old, updated, tokenCardId) => {
                        console.log(\"web3.tokens.data changed. You should assign a function to `web3.tokens.dataChanged` to monitor for changes like this:\\n    `web3.tokens.dataChanged = (old, updated, tokenCardId) => { //do something }`\")
                      }
                  }
                  """
        }
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webViewConfig.userContentController.addUserScript(userScript)
        
        switch type {
        case .dappBrowser:
            break
        case .tokenScriptRenderer:
            webViewConfig.setURLSchemeHandler(webViewConfig, forURLScheme: "tokenscript-resource")
        }
        
        HackToAllowUsingSafaryExtensionCodeInDappBrowser.injectJs(to: webViewConfig)
        webViewConfig.userContentController.add(messageHandler, name: Method.sendTransaction.rawValue)
        webViewConfig.userContentController.add(messageHandler, name: Method.signTransaction.rawValue)
        webViewConfig.userContentController.add(messageHandler, name: Method.signPersonalMessage.rawValue)
        webViewConfig.userContentController.add(messageHandler, name: Method.signMessage.rawValue)
        webViewConfig.userContentController.add(messageHandler, name: Method.ethCall.rawValue)
        webViewConfig.userContentController.add(messageHandler, name: Browser.locationChangedEventName)
        webViewConfig.userContentController.add(messageHandler, name: TokenScript.SetProperties.setActionProps)
        return webViewConfig
    }
    
    fileprivate static func javaScriptForDappBrowser(server: RPCServer) -> String {
        return """
               //Space is needed here because it is sometimes cut off by websites.
               
               const addressHex = "\(walletAddress)"
               const rpcURL = "\(server.web3InjectedRpcURL.absoluteString)"
               const chainID = "\(server.chainID)"
             
               function executeCallback (id, error, value) {
                   AlphaWallet.executeCallback(id, error, value)
               }
             
               AlphaWallet.init(rpcURL, {
                   getAccounts: function (cb) { cb(null, [addressHex]) },
                   processTransaction: function (tx, cb){
                       console.log('signing a transaction', tx)
                       const { id = 8888 } = tx
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object":     tx, id: id})
                   },
                   signMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signMessage.postMessage({"name": "signMessage", "object": { data }, id:    id} )
                   },
                   signPersonalMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a personal message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object":  { data }, id: id})
                   },
                   signTypedMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a typed message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signTypedMessage.postMessage({"name": "signTypedMessage", "object":     { data }, id: id})
                   },
                   ethCall: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("eth_call", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.ethCall.postMessage({"name": "ethCall", "object": data, id: id})
                   },
                   walletAddEthereumChain: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("walletAddEthereumChain", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.walletAddEthereumChain.postMessage({"name": "walletAddEthereumChain", "object": data, id: id})
                   },
                   walletSwitchEthereumChain: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("walletSwitchEthereumChain", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.walletSwitchEthereumChain.postMessage({"name": "walletSwitchEthereumChain", "object": data, id: id})
                   },
                   enable: function() {
                      return new Promise(function(resolve, reject) {
                          //send back the coinbase account as an array of one
                          resolve([addressHex])
                      })
                   }
               }, {
                   address: addressHex,
                   networkVersion: "0x" + parseInt(chainID).toString(16) || null
               })
             
               web3.setProvider = function () {
                   console.debug('AlphaWallet Wallet - overrode web3.setProvider')
               }
             
               web3.eth.defaultAccount = addressHex
             
               web3.version.getNetwork = function(cb) {
                   cb(null, chainID)
               }
             
              web3.eth.getCoinbase = function(cb) {
               return cb(null, addressHex)
             }
             window.ethereum = web3.currentProvider
               
             // So we can detect when sites use History API to generate the page location. Especially common with React and similar frameworks
             ;(function() {
               var pushState = history.pushState;
               var replaceState = history.replaceState;
             
               history.pushState = function() {
                 pushState.apply(history, arguments);
                 window.dispatchEvent(new Event('locationchange'));
               };
             
               history.replaceState = function() {
                 replaceState.apply(history, arguments);
                 window.dispatchEvent(new Event('locationchange'));
               };
             
               window.addEventListener('popstate', function() {
                 window.dispatchEvent(new Event('locationchange'))
               });
             })();
             
             window.addEventListener('locationchange', function(){
               webkit.messageHandlers.\(Browser.locationChangedEventName).postMessage(window.location.href)
             })
             """
    }
    fileprivate static func javaScriptForTokenScriptRenderer() -> String {
        return """
               window.web3CallBacks = {}
               window.tokenScriptCallBacks = {}
               
               function executeCallback (id, error, value) {
                   window.web3CallBacks[id](error, value)
                   delete window.web3CallBacks[id]
               }
               
               function executeTokenScriptCallback (id, error, value) {
                   let cb = window.tokenScriptCallBacks[id]
                   if (cb) {
                       window.tokenScriptCallBacks[id](error, value)
                       delete window.tokenScriptCallBacks[id]
                   } else {
                   }
               }
               
               web3 = {
                 personal: {
                   sign: function (msgParams, cb) {
                     const { data } = msgParams
                     const { id = 8888 } = msgParams
                     window.web3CallBacks[id] = cb
                     webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object":  { data }, id: id})
                   }
                 },
                 action: {
                   setProps: function (object, cb) {
                     const id = 8888
                     window.tokenScriptCallBacks[id] = cb
                     webkit.messageHandlers.\(TokenScript.SetProperties.setActionProps).postMessage({"object":  object, id: id})
                   }
                 }
               }
               """
    }
    
    fileprivate static func contentBlockingRulesJson() -> String {
        let whiteListedUrls = [
            "https://unpkg.com/",
            "^tokenscript-resource://",
            "^http://stormbird.duckdns.org:8080/api/getChallenge$",
            "^http://stormbird.duckdns.org:8080/api/checkSignature"
        ]
        var json = """
                   [
                       {
                           "trigger": {
                               "url-filter": ".*"
                           },
                           "action": {
                               "type": "block"
                           }
                       }
                   """
        for each in whiteListedUrls {
            json += """
                    ,
                    {
                        "trigger": {
                            "url-filter": "\(each)"
                        },
                        "action": {
                            "type": "ignore-previous-rules"
                        }
                    }
                    """
        }
        json += "]"
        return json
    }
}

extension WKWebViewConfiguration: WKURLSchemeHandler {
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        if urlSchemeTask.request.url?.path != nil {
            if let fileExtension = urlSchemeTask.request.url?.pathExtension, fileExtension == "otf", let nameWithoutExtension = urlSchemeTask.request.url?.deletingPathExtension().lastPathComponent {
                guard let url = Bundle.main.url(forResource: nameWithoutExtension, withExtension: fileExtension) else { return }
                guard let data = try? Data(contentsOf: url) else { return }
                let response = URLResponse(url: urlSchemeTask.request.url!, mimeType: "font/opentype", expectedContentLength: data.count, textEncodingName: nil)
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
                return
            }
        }
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
}

extension GasPrice: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .legacy(let gasPrice): return "Legacy(\(gasPrice))"
        case .eip1559(let maxFeePerGas, let maxPriorityFeePerGas): return "EIP1559(\(maxFeePerGas),\(maxPriorityFeePerGas))"
        }
    }
}

extension TokenScript {
    public enum SetProperties {
        public static let setActionProps = "setActionProps"
        public typealias Properties = [String: Any]
        
        case action(id: Int, changedProperties: Properties)
        
        public static func fromMessage(_ message: WKScriptMessage) -> SetProperties? {
            guard message.name == SetProperties.setActionProps else { return nil }
            guard let body = message.body as? [String: AnyObject] else { return nil }
            guard let changedProperties = body["object"] as? SetProperties.Properties else { return nil }
            guard let id = body["id"] as? Int else { return nil }
            return .action(id: id, changedProperties: changedProperties)
        }
    }
}

public enum Browser { }

extension Browser {
    public static let locationChangedEventName = "locationChanged"
    public enum MessageType {
        case setActionProps(TokenScript.SetProperties)
        
        public static func fromMessage(_ message: WKScriptMessage) -> Browser.MessageType? {
            if let action = TokenScript.SetProperties.fromMessage(message) {
                return .setActionProps(action)
            }
            return nil
        }
    }
}
extension Int {
    
    public func toString() -> String {
        return String(self)
    }
    public  init?(chainId0xString string: String) {
        if string.has0xPrefix {
            if let i = Int(string.drop0x, radix: 16) {
                self = i
            } else {
                return nil
            }
        } else {
            if let i = Int(string) {
                self = i
            } else {
                return nil
            }
        }
    }
}

extension String{
    public var has0xPrefix: Bool {
        return hasPrefix("0x")
    }
    
    public var drop0x: String {
        if count > 2{
            return String(dropFirst(2))
        }
        return self
    }
    
}

extension Data{
    public var hexEncoded: String {
        return "0x" + self.hex()
    }
    public init(_hex value: String) {
        let chunkSize: Int = 100
        if value.count > chunkSize {
            self = value.chunked(into: chunkSize).reduce(NSMutableData()) { result, chunk -> NSMutableData in
                let part = Data.data(from: String(chunk))
                result.append(part)
                
                return result
            } as Data
        } else {
            self = Data.data(from: value)
        }
    }
    private static func data(from hex: String) -> Data {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let from = hex.index(hex.startIndex, offsetBy: i*2)
            let to = hex.index(hex.startIndex, offsetBy: i*2 + 2)
            let bytes = hex[from ..< to]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            }
        }
        return data
    }
    
}
extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    public var jsonString: String? {
        if let dict = (self as AnyObject) as? [String: AnyObject] {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict,
                                                      options: [.prettyPrinted, .sortedKeys])
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                
            }
        }
        return nil
    }
}
extension StringProtocol {
    
    public func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        
        var i = startIndex
        
        while let nextIndex = index(i, offsetBy: size, limitedBy: endIndex) {
            chunks.append(self[i ..< nextIndex])
            i = nextIndex
        }
        
        let finalChunk = self[i ..< endIndex]
        
        if finalChunk.isEmpty == false {
            chunks.append(finalChunk)
        }
        
        return chunks
    }
}
extension Data {
    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
    
    public var bytes: Array<UInt8> {
        Array(self)
    }
    
    public func toHexString() -> String {
        self.bytes.toHexString()
    }
}
extension Array where Element == UInt8 {
    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}

extension Array {
    @inlinable
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    @inlinable
    var slice: ArraySlice<Element> {
        self[self.startIndex ..< self.endIndex]
    }
    
    @inlinable
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension TokenScript {
    public static let repoServer = "https://repo.tokenscript.org/\(supportedTokenScriptNamespaceVersion)"
    public static let repoClientName = "Carbon"
    public static let repoPlatformName = "iOS"
    public static let tokenScriptNamespacePrefix = "http://tokenscript.org/"
    public static let tokenScriptSite = URL(string: "http://tokenscript.org")!
    public static let oldNoLongerSupportedTokenScriptNamespaceVersions = ["2019/04", "2019/05", "2019/10", "2020/03"].map { "\(tokenScriptNamespacePrefix)\($0)/tokenscript" }
    public static let supportedTokenScriptNamespaceVersion = "2020/06"
    public static let supportedTokenScriptNamespace = "\(tokenScriptNamespacePrefix)\(supportedTokenScriptNamespaceVersion)/tokenscript"
    public static let indicesFileName = "indices"
    public static let defaultBitmask: BigUInt = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", radix: 16)!
}

extension Data{
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func hex(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension DappAction {
    public static func fromCommand(_ command: DappOrWalletCommand, server: RPCServer) -> DappAction {
        switch command {
        case .eth(let command):
            switch command.name {
            case .signTransaction:
                return .signTransaction(DappAction.makeUnconfirmedTransaction(command.object, server: server))
            case .sendTransaction:
                return .sendTransaction(DappAction.makeUnconfirmedTransaction(command.object, server: server))
            case .signMessage:
                let data = command.object["data"]?.value ?? ""
                return .signMessage(data)
            case .signPersonalMessage:
                let data = command.object["data"]?.value ?? ""
                return .signPersonalMessage(data)
            case .ethCall:
                let from = command.object["from"]?.value ?? ""
                let to = command.object["to"]?.value ?? ""
                let data = command.object["data"]?.value ?? ""
                let value: String? = command.object["value"]?.value
                return .ethCall(from: from, to: to, value: value, data: data)
            case .unknown:
                return .unknown
                
            }
        case .walletAddEthereumChain(let command):
            return .walletAddEthereumChain(command.object)
        case .walletSwitchEthereumChain(let command):
            return .walletSwitchEthereumChain(command.object)
        }
    }
    
    private static func makeUnconfirmedTransaction(_ object: [String: DappCommandObjectValue], server: RPCServer) -> UnconfirmedTransaction {
        let value = BigUInt((object["value"]?.value ?? "0").drop0x, radix: 16) ?? BigUInt()
        let nonce: BigUInt? = {
            guard let value = object["nonce"]?.value else { return .none }
            return BigUInt(value.drop0x, radix: 16)
        }()
        let gasLimit: BigUInt? = {
            guard let value = object["gasLimit"]?.value ?? object["gas"]?.value else { return .none }
            return BigUInt((value).drop0x, radix: 16)
        }()
        let gasPrice: GasPrice? = {
            if let value = object["gasPrice"]?.value, let gasPrice = BigUInt(value.drop0x, radix: 16) {
                return .legacy(gasPrice: gasPrice)
            } else if let maxFeePerGasValue = object["maxFeePerGas"]?.value,
                      let maxPriorityFeePerGasValue = object["maxPriorityFeePerGas"]?.value,
                      let maxFeePerGas = BigUInt(maxFeePerGasValue.drop0x, radix: 16),
                      let maxPriorityFeePerGas = BigUInt(maxPriorityFeePerGasValue.drop0x, radix: 16) {
                
                return .eip1559(maxFeePerGas: maxFeePerGas, maxPriorityFeePerGas: maxPriorityFeePerGas)
            } else {
                return nil
            }
        }()
        let data = Data(_hex: object["data"]?.value ?? "0x")
        
        var recipient : String?
        var contract : String?
        
        if data.isEmpty || data.toHexString() == "0x" {
            recipient = recipientAddress
            contract = nil
        } else {
            recipient = nil
            contract = recipientAddress
        }
        
        return UnconfirmedTransaction(
            value: value,
            recipient: recipient,
            contract: contract,
            data: data,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce
        )
    }
    
    public static func fromMessage(_ message: WKScriptMessage) -> DappOrWalletCommand? {
        let decoder = JSONDecoder()
        guard var body = message.body as? [String: AnyObject] else {
            print("[Browser] Invalid body in message: \(message.body)")
            return nil
        }
        if var object = body["object"] as? [String: AnyObject], object["gasLimit"] is [String: AnyObject] {
            object["gasLimit"] = nil
            body["object"] = object as AnyObject
        }
        guard let jsonString = body.jsonString else {
            print("[Browser] Invalid jsonString. body: \(body)")
            return nil
        }
        let data = jsonString.data(using: .utf8)!
        if let command = try? decoder.decode(DappCommand.self, from: data) {
            return .eth(command)
        } else if let commandWithOptionalObjectValues = try? decoder.decode(DappCommandWithOptionalObjectValues.self, from: data) {
            let command = commandWithOptionalObjectValues.toCommand
            return .eth(command)
        } else if let command = try? decoder.decode(AddCustomChainCommand.self, from: data) {
            return .walletAddEthereumChain(command)
        } else if let command = try? decoder.decode(SwitchChainCommand.self, from: data) {
            return .walletSwitchEthereumChain(command)
        } else {
            print("[Browser] failed to parse dapp command with JSON: \(jsonString)")
            return nil
        }
    }
}
