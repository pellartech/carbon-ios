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
var server = RPCServer.allCases[0]

extension TabManager: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab) {
        switch action {
        case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletAddEthereumChain, .ethCall:
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        case .walletSwitchEthereumChain(let chain):
        print("=============================Switch-chain-call-back============================")
        print(chain.server?.name ?? "")
        print(chain.server?.chainID ?? "")
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
