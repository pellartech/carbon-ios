//
//  ViewController.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//
import UIKit
import WebKit
import Combine

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
        switch action {
        case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletAddEthereumChain, .ethCall:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletSwitchEthereumChain(let chain):
            switch chain.server?.chainID {
            case 1 : server = RPCServer.allCases[0]
            case 56 :server = RPCServer.allCases[5]
            default : break
            }
                guard let currentTab = self.selectedTab else { return }
                let request = URLRequest(url:currentTab.url!)
                self.removeTab(currentTab)
                let closedTab = self.addTab(request, afterTab: selectedTab, isPrivate: false)
                self.selectTab(closedTab)
                self.selectedTab?.reloadPage()
        }
    }
}
extension Tab: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab) {
        switch action {
        case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletAddEthereumChain, .ethCall:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletSwitchEthereumChain(let chain):
        print(chain.server?.name ?? "")
        }
    }
}
