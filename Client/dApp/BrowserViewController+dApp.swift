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

var walletAddress = "0xe2B3BD7174B6069C892448AdCC539392E936DAE0"
protocol BrowserViewControllerDelegate: AnyObject {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab)
}
typealias DecisionHandler = (WKNavigationActionPolicy) -> Void
typealias DecidePolicy = (navigationAction: WKNavigationAction, decisionHandler: DecisionHandler)
let dappActionSubject = PassthroughSubject<(action: DappAction, callbackId: Int), Never>()
let recordUrlSubject = PassthroughSubject<Void, Never>()
let decidePolicy = PassthroughSubject<DecidePolicy, Never>()
var cancellable = Set<AnyCancellable>()
let universalLinkSubject = PassthroughSubject<URL, Never>()
var server = RPCServer.allCases[5]
extension TabManager: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab) {
        if !UserDefaults.standard.bool(forKey: "ExecuteOnce") {
            var chainInfo : Chain?
            switch action {
            case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
                self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
            case .walletAddEthereumChain, .ethCall:
                self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
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
                    
                default : break
                }
                guard let currentTab = tabManager.selectedTab else { return }
                tabManager.removeTab(currentTab)
                
                tabManager.selectTab(tabManager.addTab(URLRequest(url: currentTab.url!), isPrivate: false))
                ParticleNetwork.setChainInfo(chainInfo!)
                UserDefaults.standard.set(true, forKey: "ExecuteOnce")
            }
        }
    }
}

