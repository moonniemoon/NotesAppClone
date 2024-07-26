//
//  CoreDataManager.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "NotesClone")
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load() {
        persistentContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
                fatalError("Failed to load Core Data stack: \(error!.localizedDescription)")
            }
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
                viewContext.rollback()
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
