//
//  FACoreStack.swift
//
//
//  Created by Ferhat Abdullahoglu on 16.01.2020.
//

import Foundation
import CoreData


public final class CoreStack: PersistenceStore {
    
    
    // MARK: - Properties
    //
    
    
    // MARK: - Private properties
    
    /// Managed object context
    fileprivate let context: NSManagedObjectContext
    
    
    // MARK: - Public properties
    
    
    
    
    // MARK: - Initialization
    //
    
    /**
     Initialize a new CoreData persistence store
     
     - parameter context: The managed object context used for querying and
     
     - returns: An initialised instance of this class
     */
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    // MARK: - Methods
    //
    
    
    // MARK: - Private methods
    
    
    // MARK: - Public methods
    
    /// Fetch request for any type
    /// - Parameters:
    ///   - type: Type to fetch
    ///   - predicate: Predicate
    public func fetchRequest(for type: Any.Type, predicate: NSPredicate) throws -> NSFetchRequest<NSFetchRequestResult> {
        guard let `class` = type as? AnyClass else {
            throw Errors.invalidType(type: type)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: `class`))
        request.predicate = predicate
        return request
    }
    
    // MARK: <PersistenceStore>
    
    /**
     Create a new object of the given type.
     
     - parameter type: The type of which a new object should be created
     
     - throws: If a invalid type was specified
     
     - returns: A newly created object of the given type
     */
    public func create<T>(type: Any.Type) throws -> T {
        guard let `class` = type as? AnyClass else {
            throw Errors.invalidType(type: type)
        }
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: `class`), into: context)
        
        guard let managedObject = object as? T else {
            throw Errors.invalidType(type: Swift.type(of: object))
        }
        
        return managedObject
    }
    
    /**
     Delete objects of the given type which also match the predicate.
     
     - parameter type:      The type of which objects should be deleted
     - parameter predicate: The predicate used for matching objects to delete
     
     - throws: If an invalid type was specified
     */
    public func delete(type: Any.Type, predicate: NSPredicate) throws {
        let managedObjects: [NSManagedObject] = try fetchAll(type: type, predicate: predicate)
        
        for managedObject in managedObjects {
            context.delete(managedObject)
        }
    }
    
    /**
     Fetches all objects of a specific type which also match the predicate.
     
     - parameter type:      The type of which objects should be fetched
     - parameter predicate: The predicate used for matching object to fetch
     
     - throws: If an invalid type was specified
     
     - returns: An array of matching objects
     */
    public func fetchAll<T>(type: Any.Type, predicate: NSPredicate = NSPredicate(value: true), context requiredContext: NSManagedObjectContext? = nil) throws -> [T] {
        let request = try fetchRequest(for: type, predicate: predicate)
        request.returnsObjectsAsFaults = false
        let items: [T] = try (requiredContext ?? context).fetch(request) as! [T]
        return items
    }
    
    /**
     Returns an array of names of properties the given type stores persistently.
     
     This should omit any properties returned by `relationshipsFor(type:)`.
     
     - parameter type: The type of which properties should be returned for
     
     - throws: If an invalid type was specified
     
     - returns: An array of property names representing system native types.
     */
    public func properties(for type: Any.Type) throws -> [String] {
        let description = try entityDescription(for: type)
        let propertyAndRelationshipNames = description.propertiesByName.map { $0.0 }
        let relationshipNames = try relationships(for: type)
        
        let propertyNames = propertyAndRelationshipNames.filter { relationshipNames.contains($0) == false }
        return propertyNames
    }
    
    /**
     Returns an array of property names for any relationship the given type stores persistently.
     
     - parameter type: The type of which properties should be returned for
     
     - throws: If an invalid type was specified
     
     - returns: An array of property names representing related entities.
     */
    public func relationships(for type: Any.Type) throws -> [String] {
        let description = try entityDescription(for: type)
        return description.relationshipsByName.map { $0.0 }
    }
    
    /**
     Performs the actual save to the persistence store.
     
     - throws: If any error occured during the save operation
     */
    @discardableResult
    public func save() -> Bool {
        do {
            try context.save()
            return true
        }
        catch {
            return false
        }
    }
    
    // MARK: - Helper methods
    
    fileprivate func entityDescription(for type: Any.Type) throws -> NSEntityDescription {
        if let `class` = type as? AnyClass, let description = NSEntityDescription.entity(forEntityName: String(describing: `class`), in: context) {
            return description
        }
        
        throw Errors.invalidType(type: type)
    }
    
    public func performBlock(block: @escaping () -> Void) {
        switch context.concurrencyType {
        case .confinementConcurrencyType:
            block()
        case .mainQueueConcurrencyType, .privateQueueConcurrencyType:
            context.perform {
                block()
            }
        @unknown default:
            print("Handle all concurrency types @FACoreStack.CoreStack file")
        }
    }
    
    public func performAndWait(block: @escaping () -> Void) {
        switch context.concurrencyType {
        case .confinementConcurrencyType:
            block()
        case .mainQueueConcurrencyType, .privateQueueConcurrencyType:
            context.performAndWait {
                block()
            }
        @unknown default:
            print("Handle all concurrency types @FACoreStack.CoreStack file")
        }
    }
}

public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
