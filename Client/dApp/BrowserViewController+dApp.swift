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
