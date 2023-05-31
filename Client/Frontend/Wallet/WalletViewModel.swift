//
//  WalletViewModel.swift
//  Client
//
//  Created by Ashok on 13/05/23.
//

import Foundation
import UIKit
import ParticleConnect
import ConnectCommon
import ParticleWalletAPI
import RxSwift
import SVProgressHUD
import ParticleAuthService
import ParticleNetworkBase
import ConnectEVMAdapter
import ConnectPhantomAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter

public class WalletViewModel {
    
    public static var shared = WalletViewModel()
    private var data: [ConnectWalletModel] = []
    let bag = DisposeBag()
    private var tokensModel = [TokenModel]()
    
    ///Wallet Login
    func walletLogin(vc: UIViewController, walletType: WalletType, completed : @escaping (Result<ConnectWalletModel, Error>) -> Void) {
        let adapters = ParticleConnect.getAdapters(chainType: .solana) + ParticleConnect.getAdapters(chainType: .evm)
        var single: Single<Account?>
        var adapter: ConnectAdapter = adapters[0]
        switch walletType {
        case .metaMask:
            adapter = adapters.first {$0.walletType == .metaMask}!
        case .particle:
            adapter = adapters.first {$0.walletType == .particle}!
        case .rainbow:
            adapter = adapters.first {$0.walletType == .rainbow}!
        case .trust:
            adapter = adapters.first {$0.walletType == .trust}!
        case .imtoken:
            adapter = adapters.first {$0.walletType == .imtoken}!
        case .bitkeep:
            adapter = adapters.first {$0.walletType == .bitkeep}!
        case .phantom:
            adapter = adapters.first {$0.walletType == .phantom}!
        case .walletConnect:
            adapter = adapters.first {$0.walletType == .walletConnect}!
        case .gnosis:
            adapter = adapters.first {$0.walletType == .gnosis}!
        case .custom(let adapterInfo):
            adapter = adapters.first {$0.walletType == .custom(info: adapterInfo)}!
        default:
            break
        }
        if adapter.readyState == .notDetected {
            completed(.failure("Error - You haven't installed this wallet"))
            return
        }
        if adapter.readyState == .unsupported {
            completed(.failure("Error - The wallet is not support current chain"))
            return
        }
        if walletType == .walletConnect {
            single = (adapter as! WalletConnectAdapter).connectWithQrCode(from: vc)
        } else if walletType == .particle {
            single = adapter.connect(ParticleConnectConfig(loginType: .email))
        } else {
            single = adapter.connect(ConnectConfig.none)
        }
        
        single.subscribe { result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let account):
                if let account = account {
                    let connectWalletModel = ConnectWalletModel(publicAddress: account.publicAddress, name: account.name, url: account.url, icons: account.icons, description: account.description, isSelected: false, walletType: account.walletType, chainId: ConnectManager.getChainId())
                    WalletManager.shared.updateWallet(connectWalletModel)
                    completed(.success(connectWalletModel))
                }
            }
        }.disposed(by: bag)
    }
    
    
    /// This method will add the pre defined tokens to the user account
    func addTokenToUserAccount(address:String,tokens:[String],completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().addCustomTokens(address: address, tokenAddresses: tokens)//
            .subscribe { result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let tokenModels):
                completed(.success(tokenModels))
            }
        }.disposed(by: bag)
    }
    
    /// This method will fetch the native tokens which belongs to user account
    func getUserTokenListsForNativeTokens(address: String, tokenArray : [TokenModel],completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().getTokens(by: address, tokenAddresses: tokenArray)//
            .subscribe { result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let tokens):
                let token = tokens.tokens as [TokenModel]
                completed(.success(token + tokenArray))
            }
        }.disposed(by: bag)
    }
    
    /// This method will fetch the ERC20 tokens which belongs to user account
    func getUserTokenListsForERC20Tokens(address: String, tokenArray : [TokenModel],completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().getTokens(by: address, tokenAddresses: [])//
            .subscribe {result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let tokens):
                let token = tokens.tokens as [TokenModel]
                completed(.success(token + tokenArray))
            }
        }.disposed(by: bag)
    }
    
    /// This method will send the native tokens  to  user account
    func sendNativeEVM(amountString: String,sender:String,receiver: String,completed : @escaping (Result<String, Error>) -> Void) {
        let amount = BDouble((Double(amountString) ?? 0.0) * pow(10, 18)).rounded()
        let sende = ParticleAuthService.getAddress()
        ParticleWalletAPI.getEvmService().createTransaction(from:sende, to: receiver, value: amount.toHexString(), data: "0x").flatMap {
            transaction -> Single<String> in
            print("transaction = \(transaction)")
            return ParticleAuthService.signAndSendTransaction(transaction)
        }.subscribe { result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let signature):
                completed(.success(signature))
            }
        }.disposed(by: bag)
    
    }
    
    /// This method will send the ERC20 tokens  to  user account
    func sendERC20Token(amountString: String,sender:String,receiver: String,filterToken: TokenModel,completed : @escaping (Result<String, Error>) -> Void) {
        let amount = BDouble((Double(amountString) ?? 0.0) * pow(10, 18)).rounded()
        let contractParams = ContractParams.erc20Transfer(contractAddress: filterToken.address, to: receiver, amount: amount)
        ParticleWalletAPI.getEvmService().createTransaction(from: sender,to: receiver,contractParams: contractParams).flatMap {
            transaction -> Single<String> in
            return ParticleAuthService.signAndSendTransaction(transaction)
        }.subscribe {result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let signature):
                completed(.success(signature))
            }
        }.disposed(by: bag)
    
    }
    
    /// Wallet Logout
    func walletLogout(completed : @escaping (Result<String, Error>) -> Void){
        WalletManager.shared.removeAllWallet()
        ParticleAuthService.logout()//
            .subscribe {result in
            switch result {
            case .failure(let error):
                completed(.failure(error))
            case .success(let logout):
                completed(.success(logout))
            }
        }.disposed(by: bag)
    }
}
