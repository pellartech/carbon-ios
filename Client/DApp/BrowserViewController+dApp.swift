//
//  ViewController.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//
import UIKit
import WebKit
import Combine
import ParticleNetworkBase
import APIKit
import Combine
import BigInt
import CryptoSwift
import secp256k1
import PromiseKit

var walletAddress = ""
protocol BrowserViewControllerDelegate: AnyObject {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab)
}
public typealias APIKitSession = APIKit.Session
typealias DecisionHandler = (WKNavigationActionPolicy) -> Void
typealias DecidePolicy = (navigationAction: WKNavigationAction, decisionHandler: DecisionHandler)
let dappActionSubject = PassthroughSubject<(action: DappAction, callbackId: Int), Never>()
let recordUrlSubject = PassthroughSubject<Void, Never>()
let decidePolicy = PassthroughSubject<DecidePolicy, Never>()
var cancellable = Set<AnyCancellable>()
let universalLinkSubject = PassthroughSubject<URL, Never>()
var server = RPCServer.allCases[5]
let WALLET_SWITCH = "wallet-switch"

extension TabManager: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab) {
        if !UserDefaults.standard.bool(forKey: WALLET_SWITCH) {
            var chainInfo : Chain?
            switch action {
            case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
                self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
            case .walletAddEthereumChain:
                self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
            case .ethCall(from: let from , to: let to, value: let value, data: let data):
                requestEthCall(from: from, to: to, value: value, data: data)
                    .sink(receiveCompletion: { [self] result in
                        guard case .failure(let error) = result else { return }
                        
                        if case JSONRPCError.responseError(let code, let message, _) = error.embedded {
                            self.notifyFinish(callbackId: callbackId, value: .failure(.init(code: code, message: message)))
                        } else {
                            //TODO better handle. User didn't cancel
                            self.notifyFinish(callbackId: callbackId, value: .failure(.responseError))
                        }
                        
                    }, receiveValue: { [self] value in
                        let callback = DappCallback(id: callbackId, value: .ethCall(value))
                        self.notifyFinish(callbackId: callbackId, value: .success(callback))
                    }).store(in: &cancellable)
                
            case .walletSwitchEthereumChain(let chain):
                switch chain.server?.chainID {
                    
                case 1 : ///Main-Ethereum
                    server = RPCServer.allCases[0]
                    chainInfo  = .ethereum(EthereumNetwork(rawValue:EthereumNetwork.mainnet.rawValue)!)
                    
                case 11155111 :///Sepolia-Ethereum Testnet
                    server = RPCServer.allCases[25]
                    chainInfo  = .ethereum(EthereumNetwork(rawValue: EthereumNetwork.sepolia.rawValue)!)
                    
                case 5 :///Goerli-Ethereum Testnet
                    server = RPCServer.allCases[3]
                    chainInfo  = .ethereum(EthereumNetwork(rawValue: EthereumNetwork.goerli.rawValue)!)
                    
                case 56 :///BinanceSmartChain
                    server = RPCServer.allCases[5]
                    chainInfo  = .bsc(BscNetwork(rawValue:BscNetwork.mainnet.rawValue)!)
                    
                case 97 :///BinanceSmartChain Testnet
                    server = RPCServer.allCases[4]
                    chainInfo  = .bsc(BscNetwork(rawValue:BscNetwork.testnet.rawValue)!)
                    
                case 66 : ///OkexChain
                    server = RPCServer.allCases[24]
                    chainInfo  = .okc(OKCNetwork(rawValue: OKCNetwork.mainnet.rawValue)!)
                    
                case 137 : ///Polygon
                    server = RPCServer.allCases[11]
                    chainInfo  = .polygon(PolygonNetwork(rawValue: PolygonNetwork.mainnet.rawValue)!)
                    
                case 80001 : ///Polygon-Mumbai Testnet
                    server = RPCServer.allCases[13]
                    chainInfo  = .polygon(PolygonNetwork(rawValue: PolygonNetwork.mumbai.rawValue)!)
                    
                default :
                    server = RPCServer.allCases[5]
                    chainInfo  = .bsc(BscNetwork(rawValue:BscNetwork.mainnet.rawValue)!)
                }
                if let chainInfoDetails = chainInfo{
                    guard let currentTab = tabManager.selectedTab else { return }
                    tabManager.removeTab(currentTab)
                    tabManager.selectTab(tabManager.addTab(URLRequest(url: currentTab.url!), isPrivate: false))
                    ParticleNetwork.setChainInfo(chainInfoDetails)
                    UserDefaults.standard.set(true, forKey: WALLET_SWITCH)
                }
            }
        }
    }
    
    public func call(from: String?, to: String?, value: String?, data: String) -> AnyPublisher<String, SessionTaskError> {
        let request = EtherServiceRequest(server: server, batch: BatchFactory().create(EthCallRequest(from: from, to: to, value: value, data: data)))
        print(request)
        return APIKitSession.sendPublisher(request, server: server)
    }
    
    func requestEthCall(from: String?,
                        to: String?,
                        value: String?,
                        data: String) -> AnyPublisher<String, PromiseError> {
        
        return call(from: from, to: to, value: value, data: data)
            .receive(on: RunLoop.main)
            .mapError { PromiseError(error: $0) }
            .eraseToAnyPublisher()
    }
    
}

extension APIKitSession {

    class func sendPublisher<Request: APIKit.Request>(_ request: Request, server: RPCServer, callbackQueue: CallbackQueue? = nil) -> AnyPublisher<Request.Response, SessionTaskError> {
        sendImplPublisher(request, server: server, callbackQueue: callbackQueue)
            .retry(2).eraseToAnyPublisher()
    }

    private class func sendImplPublisher<Request: APIKit.Request>(_ request: Request, server: RPCServer, callbackQueue: CallbackQueue? = nil) -> AnyPublisher<Request.Response, SessionTaskError> {
        var sessionTask: SessionTask?
        let publisher = Deferred {
            Future<Request.Response, SessionTaskError> { seal in
                sessionTask = APIKitSession.send(request, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let result):
                        seal(.success(result))
                    case .failure(let error):
                       seal(.failure(error))
                        
                    }
                }
            }
        }.handleEvents(receiveCancel: {
            sessionTask?.cancel()
        })

        return publisher
            .eraseToAnyPublisher()
    }
    static func logRpcNodeError(_ rpcNodeError: RpcNodeRetryableRequestError) {
        switch rpcNodeError {
        case .rateLimited(let server, let domainName):
           print(domainName)
            print(server)
        case .invalidApiKey(let server, let domainName):
            print(domainName)
             print(server)
        case .possibleBinanceTestnetTimeout, .networkConnectionWasLost, .invalidCertificate, .requestTimedOut:
            return
        }
    }

}
