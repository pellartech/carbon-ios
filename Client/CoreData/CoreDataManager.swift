//
//  CoreDataManager.swift
//  Client
//
//  Created by Ashok on 06/06/23.
//

import Foundation
import CoreData

let entire_name = "Tokens"

class CoreDataManagerx {
    
    //MARK: -Properties
    static let shared = CoreDataManagerx()
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: entire_name)
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Fatal error : \($0)") }
        })
        return container
    }()
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Tokens> = {
        let fetchRequest: NSFetchRequest<Tokens> = Tokens.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_time", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    //MARK: - Method: Fetch all data from core data
    func fetchDataFromCoreData() -> [TokensData] {
        var tokensData = [TokensData]()
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
        }
        if let tokens = self.fetchedResultsController.fetchedObjects {
            for token in tokens{
                let tokenDta = self.toModel(tokens:token)
                tokensData.append(tokenDta)
            }
        }
        return tokensData
        
    }
    
    //MARK: - Helper Method: convert coredate properties to model objects
    func toModel(tokens: Tokens) -> TokensData {
        return TokensData(id: tokens.id, name: tokens.name, symbol: tokens.symbol, created_time: tokens.created_time,isUserToken: tokens.isUserToken, address: tokens.address,imageUrl: tokens.imageUrl)
    }
    
    //MARK: - Method: save all changes into core data
    func saveDataToCoreData(tokensData:[TokensData],network: Networks) {
        let context = persistentContainer.newBackgroundContext()
        do {
            if #available(iOS 15.0, *) {
                try   context.performAndWait {
                    _ = tokensData.map { $0.toManagedObject(in: context, network: network) }
                    try context.save()
                }
            } else {
                // Fallback on earlier versions
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: - Method: Clear all data from core data
    func clearDataFromCoreData() {
        let deleteAll = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entire_name))
        do {
            try persistentContainer.viewContext.execute(deleteAll)
        }
        catch {
            print(error)
        }
    }
}

import Foundation
import CoreData

class CoreDataManager {
    //MARK: -Properties
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tokens")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Method: Save networks
//    func saveNetworks(name: String) {
//        let networks = Networks(context: persistentContainer.viewContext)
//        networks.name = name
//    }
    
    //MARK: - Method: Save tokens
//    func saveTokens(id: String, address: String, imageUrl: String, isUserToken: Bool, created_time: Int64 ,symbol : String ,networks: Networks) -> Tokens {
//        let token = Tokens(context: persistentContainer.viewContext)
//        token.id = id
//        token.address = address
//        token.imageUrl = imageUrl
//        token.isUserToken = isUserToken
//        token.created_time = created_time
//        token.symbol = symbol
//        networks.token = token
//        return token
//    }
    func saveNetworks(networks:[Platforms]) {
        let context = persistentContainer.viewContext
        _ = networks.map { $0.toManagedObject(in: context) }
        saveChanges()
    }
    func saveTokens(tokensData:[TokensData],network:Networks) {
        let context = persistentContainer.newBackgroundContext()
        do {
            if #available(iOS 15.0, *) {
                try   context.performAndWait {
                    _ = tokensData.map { $0.toManagedObject(in: context, network: network) }
                    try context.save()
                }
            } else {
                // Fallback on earlier versions
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: - Method: Fetch networks
    func fetchNetworks() -> [Networks] {
        let request: NSFetchRequest<Networks> = Networks.fetchRequest()
        var fetchedNetworkss: [Networks] = []
        
        do {
            fetchedNetworkss = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching networkss \(error)")
        }
        return fetchedNetworkss
    }
    
    //MARK: - Method: Fetch tokens
    func fetchTokens(networks: Networks) -> [TokensData] {
        let request: NSFetchRequest<Tokens> = Tokens.fetchRequest()
        request.predicate = NSPredicate(format: "networks = %@", networks)
        var tokensData: [TokensData] = []
        do {
           let fetchedTokenss = try persistentContainer.viewContext.fetch(request)
            for token in fetchedTokenss{
                let tokenDta = self.toModel(tokens:token)
                tokensData.append(tokenDta)
            }
        } catch let error {
            print("Error fetching tokens \(error)")
        }
       
        return tokensData
    }
    func toModel(tokens: Tokens) -> TokensData {
        return TokensData(id: tokens.id, name: tokens.name, symbol: tokens.symbol, created_time: tokens.created_time,isUserToken: tokens.isUserToken, address: tokens.address,imageUrl: tokens.imageUrl)
    }
    // MARK: - Core Data Saving support
    func saveChanges () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("❗️Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   
    //MARK: - Method: Clear data from core data
    func deleteTokens(token: Tokens) {
        let context = persistentContainer.viewContext
        context.delete(token)
        saveChanges()
    }
    
    func deleteNetworks(networks: Networks) {
        let context = persistentContainer.viewContext
        context.delete(networks)
        saveChanges()
    }
}
