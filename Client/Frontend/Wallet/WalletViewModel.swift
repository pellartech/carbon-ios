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

public let tokenAddresses: [String] = ["0xb16f35c0ae2912430dac15764477e179d9b9ebea","0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f","0x969D499507B4f437953Db24A4980FdEEDa6Db8a1"]

public class WalletViewModel {
    
    public static var shared = WalletViewModel()
    private var data: [ConnectWalletModel] = []
    let bag = DisposeBag()
    private var tokensModel = [TokenModel]()
    
    /// This method will add the pre defined tokens to the user account
    func addCustomTokenToUserAccount(address:String,completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().addCustomTokens(address: address, tokenAddresses: tokenAddresses).subscribe { result in
            switch result {
            case .failure(let error):
                print(error)
                completed(.failure(error))
            case .success(let tokenModels):
                print(tokenModels)
                completed(.success(tokenModels))
            }
        }.disposed(by: bag)
    }
    
    /// This method will fetch the native tokens which belongs to user account
    func getUserTokenListsForNativeTokens(address: String, tokenArray : [TokenModel],completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().getTokens(by: address, tokenAddresses: []).subscribe { result in
            switch result {
            case .failure(let error):
                print(error)
                completed(.failure(error))
            case .success(let tokens):
                let token = tokens.tokens as [TokenModel]
                completed(.success(token + tokenArray))
            }
        }.disposed(by: bag)
    }
    
    /// This method will fetch the ERC20 tokens which belongs to user account
    func getUserTokenListsForERC20Tokens(address: String, tokenArray : [TokenModel],completed : @escaping (Result<[TokenModel], Error>) -> Void) {
        ParticleWalletAPI.getEvmService().getTokens(by: address, tokenAddresses: []).subscribe {result in
            switch result {
            case .failure(let error):
                print(error)
                completed(.failure(error))
            case .success(let tokens):
                let token = tokens.tokens as [TokenModel]
                completed(.success(token + tokenArray))
            }
        }.disposed(by: bag)
    }
    
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
                print(error)
                completed(.failure(error))
            case .success(let signature):
                completed(.success(signature))
            }
        }.disposed(by: bag)
    
    }

    func sendERC20Token(amountString: String,sender:String,receiver: String,filterToken: TokenModel,completed : @escaping (Result<String, Error>) -> Void) {
        let amount = BDouble((Double(amountString) ?? 0.0) * pow(10, 18)).rounded()
        let contractParams = ContractParams.erc20Transfer(contractAddress: filterToken.address, to: receiver, amount: amount)
        ParticleWalletAPI.getEvmService().createTransaction(from: sender,to: receiver,contractParams: contractParams).flatMap {
            transaction -> Single<String> in
            print("transaction = \(transaction)")
            return ParticleAuthService.signAndSendTransaction(transaction)
        }.subscribe {result in
            switch result {
            case .failure(let error):
                print(error)
                completed(.failure(error))

            case .success(let signature):
                completed(.success(signature))
            }
        }.disposed(by: bag)
    
    }
}
