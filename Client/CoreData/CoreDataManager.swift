import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "carbon")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Fatal error : \($0)") }
        })
        return container
    }()
    
    // MARK: - Save network
    func saveNetwork(name: String, isTest: Bool, nativeSymbol: String,isDefault: Bool) -> Networks {
        let network = Networks(context: persistentContainer.viewContext)
        network.name = name
        network.isTest = isTest
        network.nativeSymbol = nativeSymbol
        network.isDefault = isDefault
        return network
    }
    
    // MARK: - Save token
    func saveToken(tokensData:[TokensData],network: Networks) {
           let context = persistentContainer.viewContext
           do {
               if #available(iOS 15.0, *) {
                   try   context.performAndWait {
                       tokensData.forEach{ eachToken in
                           let token = Tokens(context: persistentContainer.viewContext)
                           token.id = eachToken.id
                           token.name = eachToken.name
                           token.address = eachToken.address
                           token.symbol = eachToken.symbol
                           token.isAdded = eachToken.isAdded ?? false
                           token.imageUrl = eachToken.imageUrl
                           network.addToTokens(token)
                       }
                       try context.save()
                   }
               }
           } catch {
               print(error)
           }
       }
       
    
    // MARK: - Fetch network
    func fetchNetworks() -> [Networks] {
        let request: NSFetchRequest<Networks> = Networks.fetchRequest()
        var fetchedNetworkss: [Networks] = []
        
        do {
            fetchedNetworkss = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching networks \(error)")
        }
        return fetchedNetworkss
    }
    
    // MARK: - Fetch tokens
    func fetchTokens(network: Networks) -> [Tokens] {
        let request: NSFetchRequest<Tokens> = Tokens.fetchRequest()
        request.predicate = NSPredicate(format: "ANY network = %@", network)
        var fetchedTokenss: [Tokens] = []
        do {
            fetchedTokenss = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching tokens \(error)")
        }
        return fetchedTokenss
    }
    
    // MARK: - Core Data Saving support
    func save () {
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
    
    // MARK: - Delete token from core data
    func deleteTokens(token: Tokens) {
        let context = persistentContainer.viewContext
        context.delete(token)
        save()
    }
    
    // MARK: - Delete network from core data
    func deleteNetworks(network: Networks) {
        let context = persistentContainer.viewContext
        context.delete(network)
        save()
    }
}
