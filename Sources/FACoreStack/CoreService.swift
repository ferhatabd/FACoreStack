//
//  CoreService.swift
//  
//
//  Created by Ferhat Abdullahoglu on 16.01.2020.
//


import Foundation
import CoreData

final public class CoreService {
    
    /* ------------------------------------------------------- */
    // MARK: Properties
    /* ------------------------------------------------------- */
    
    
    // MARK: - Private properties
    //
    
    /// Managed object context
    let managedObjectContext: NSManagedObjectContext
    
    /// CoreData handler
    internal let coreDataStack: CoreStack
    
    /// CoreData model URL
    /// will be generated during init
    static internal var storeUrl: URL?
    

    // MARK: - Public properties
    //
    public var moc: NSManagedObjectContext {
        managedObjectContext
    }
    
    
    
    /* ------------------------------------------------------- */
    // MARK: Init
    /* ------------------------------------------------------- */
    /// Initializes a **PersistenceService** handler
    /// - Parameters:
    ///   - bundle: Bundle name to look for the model. If no bundle name is given, the current bundle will be used
    ///   - name: Name of the CoreData model. Don't include the *.sqlite* file extension in the parameter
    ///   - spaceType: Synchronized Contentful space
    ///   - assetType: Synchronized Asset type
    ///   - entryTypes: Models to be synchronized
    internal init(bundle: Bundle,
                  dataModelName name: String) {
        
        
        // get the stor url
        CoreService.storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("\(name).sqlite")
        
        let managedObjectContext = CoreService.setupManagedObjectContext(bundle: bundle, name: name)
        let coreDataStack = CoreStack(context: managedObjectContext)
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
        
    }
    
    
    /* ------------------------------------------------------- */
    // MARK: Methods
    /* ------------------------------------------------------- */
    
    // MARK: - Private methods
    //
    /// Creates and returns an **NSManagedObjectContext** for the given model
    /// - Parameters:
    ///   - bundle: Bundle name to look for the model
    ///   - name: Name of the model
    static private func setupManagedObjectContext(bundle: Bundle, name: String) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let modelUrl = bundle.url(forResource: name, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        

        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                       configurationName: nil,
                                       at: CoreService.storeUrl!,
                                       options: [NSMigratePersistentStoresAutomaticallyOption : true,
                                                 NSInferMappingModelAutomaticallyOption : true])
        } catch {
            fatalError("can't initialize the persistentStoreCoordinator")
        }
        
        managedObjectContext.persistentStoreCoordinator = psc
        return managedObjectContext
    }
    
    // MARK: - Public methods
}

