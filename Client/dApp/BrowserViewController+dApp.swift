//
//  ViewController.swift
//  dApp
//
//  Created by Ashok on 17/06/23.
//
import UIKit
import WebKit
import Combine

let walletAddress = "0x411D939a8aFAA51Be2bfed5d9C7dc939DDD57C85"
let recipientAddress = "0x411D939a8aFAA51Be2bfed5d9C7dc939DDD57C85"

protocol BrowserViewControllerDelegate: AnyObject {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab)
    func didVisitURL(url: URL, title: String, in viewController: Tab)
    func dismissKeyboard(in viewController: Tab)
    func forceUpdate(url: URL, in viewController: Tab)
    func handleUniversalLink(_ url: URL, in viewController: Tab)
}
typealias DecisionHandler = (WKNavigationActionPolicy) -> Void
typealias DecidePolicy = (navigationAction: WKNavigationAction, decisionHandler: DecisionHandler)
let dappActionSubject = PassthroughSubject<(action: DappAction, callbackId: Int), Never>()
let recordUrlSubject = PassthroughSubject<Void, Never>()
let decidePolicy = PassthroughSubject<DecidePolicy, Never>()
var cancellable = Set<AnyCancellable>()
let universalLinkSubject = PassthroughSubject<URL, Never>()
let server = RPCServer.allCases[0]

extension TabManager: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackId: Int, in viewController: Tab) {
//        guard let session = sessionsProvider.session(for: server) else {
//            self.notifyFinish(callbackId: callbackId, value: .failure(.requestRejected))
//            return
//        }
//        guard let delegate = delegate else {
//            self.notifyFinish(callbackId: callbackId, value: .failure(.requestRejected))
//            return
//        }
//        
        func rejectDappAction() {
            self.notifyFinish(callbackId: callbackId, value: .failure(JsonRpcError.requestRejected))
        }
        switch action {
        case .signTransaction, .sendTransaction, .signMessage, .signPersonalMessage, .unknown, .sendRawTransaction:
            rejectDappAction()
        case .walletAddEthereumChain, .walletSwitchEthereumChain, .ethCall:
        print("=============================call-back============================")
//            performDappAction(action: action, callbackId: callbackId, session: session, delegate: delegate)
        }
    }
    
    func didVisitURL(url: URL, title: String, in viewController: Tab) {
        
    }
    
    func dismissKeyboard(in viewController: Tab) {
        
    }
    
    func forceUpdate(url: URL, in viewController: Tab) {
        
    }
    
    func handleUniversalLink(_ url: URL, in viewController: Tab) {
        
    }
    
//
//    private func performDappAction(action: DappAction,
//                                   callbackId: Int,
//                                   session: WalletSession,
//                                   delegate: DappBrowserCoordinatorDelegate) {
//        switch action {
//        case .signTransaction(let unconfirmedTransaction):
//            requestSignTransaction(
//                session: session,
//                delegate: delegate,
//                callbackId: callbackId,
//                transaction: unconfirmedTransaction)
//        case .sendTransaction(let unconfirmedTransaction):
//            requestSendTransaction(
//                session: session,
//                delegate: delegate,
//                callbackId: callbackId,
//                transaction: unconfirmedTransaction)
//        case .signMessage(let hexMessage):
//            requestSignMessage(
//                session: session,
//                delegate: delegate,
//                message: .message(hexMessage.asSignableMessageData),
//                callbackId: callbackId)
//        case .signPersonalMessage(let hexMessage):
//            requestSignMessage(
//                session: session,
//                delegate: delegate,
//                message: .personalMessage(hexMessage.asSignableMessageData),
//                callbackId: callbackId)
//        case .signTypedMessage(let typedData):
//            requestSignMessage(
//                session: session,
//                delegate: delegate,
//                message: .typedMessage(typedData),
//                callbackId: callbackId)
//        case .signEip712v3And4(let typedData):
//
//            requestSignMessage(
//                session: session,
//                delegate: delegate,
//                message: .eip712v3And4(typedData),
//                callbackId: callbackId)
//        case .ethCall(from: let from, to: let to, value: let value, data: let data):
//            //Must use unchecked form for `Address `because `from` and `to` might be 0x0..0. We assume the dapp author knows what they are doing
//            let from = AlphaWallet.Address(uncheckedAgainstNullAddress: from)
//            let to = AlphaWallet.Address(uncheckedAgainstNullAddress: to)
//            requestEthCall(
//                session: session,
//                delegate: delegate,
//                callbackId: callbackId,
//                from: from,
//                to: to,
//                value: value,
//                data: data)
//        case .walletAddEthereumChain(let customChain):
//            requestAddCustomChain(
//                session: session,
//                delegate: delegate,
//                callbackId: callbackId,
//                customChain: customChain)
//        case .walletSwitchEthereumChain(let targetChain):
//            requestSwitchChain(
//                session: session,
//                delegate: delegate,
//                callbackId: callbackId,
//                targetChain: targetChain)
//        case .unknown, .sendRawTransaction:
//            break
//        }
    }
