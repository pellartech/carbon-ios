//
//  CoreDataManager.swift
//  Client
//
//  Created by Ashok on 06/06/23.
//

import Foundation
import CoreData

let entire_name = "Tokens"

class CoreDataManager {
    
    //MARK: -Properties
    static let shared = CoreDataManager()
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
        return TokensData(id: tokens.id, name: tokens.name, symbol: tokens.symbol, created_time: tokens.created_time, expiry_time: tokens.expiry_time,isUserToken: tokens.isUserToken, address: tokens.address,imageUrl: tokens.imageUrl)
    }
    
    //MARK: - Method: save all changes into core data
    func saveDataToCoreData(tokensData:[TokensData]) {
        let context = persistentContainer.newBackgroundContext()
        do {
            if #available(iOS 15.0, *) {
                try   context.performAndWait {
                    _ = tokensData.map { $0.toManagedObject(in: context) }
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
