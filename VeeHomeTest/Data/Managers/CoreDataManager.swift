//
//  CoreDataManager.swift
//  VeeHomeTest
//
//  Created by Idan Moshe on 03/09/2020.
//  Copyright © 2020 Idan Moshe. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    // MARK: - Properties(public)
    
    static let shared = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext {
        return AppDelegate.sharedDelegate().persistentContainer.viewContext
    }
    
    // MARK: - Methods(public)
    
    func getNotes(isArchived: Bool) -> [Note] {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isArchived == %@", argumentArray: [NSNumber(booleanLiteral: isArchived)])
        
        do {
            let results: [Note] = try self.managedObjectContext.fetch(fetchRequest)
            return results
        } catch let error {
            debugPrint(#function, error)
        }
        
        return []
    }
    
    func saveContext() {
        do {
            try self.managedObjectContext.save()
        } catch let error {
            debugPrint(#function, error)
        }
    }
    
    func insertNewObject(title: String? = nil,
                         content: String? = nil,
                         completionHandler: @escaping (_: Bool, _: Error?) -> Void) {
        let note = Note(context: self.managedObjectContext)
        note.createDate = Date()
        note.title = title
        note.content = content
        note.isArchived = false
        
        do {
            try self.managedObjectContext.save()
            completionHandler(true, nil)
        } catch let error {
            debugPrint(#function, error)
            completionHandler(false, error)
        }
    }
    
    func updateExistingObject(createDate: Date,
                              title: String? = nil,
                              content: String? = nil,
                              isArchive: Bool? = nil,
                              completionHandler: @escaping (_: Bool, _: Error?) -> Void) {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createDate == %@", argumentArray: [createDate])
        fetchRequest.fetchBatchSize = 1
        
        do {
            let results: [Note] = try self.managedObjectContext.fetch(fetchRequest)
            if let note: Note = results.first {
                note.title = title
                note.content = content
                
                if let _ = isArchive {
                    note.isArchived = isArchive!
                } else {
                    note.isArchived = false
                }
                
                note.lastEditDate = Date()
                
                do {
                    try self.managedObjectContext.save()
                    completionHandler(true, nil)
                } catch let error {
                    debugPrint(#function, error)
                    completionHandler(false, error)
                }
            }
        } catch let error {
            debugPrint(#function, error)
            completionHandler(false, error)
        }
    }
    
    func deleteNote(_ note: Note, completionHandler: @escaping () -> Void) {
        self.managedObjectContext.delete(note)
        
        do {
            try self.managedObjectContext.save()
        } catch let error {
            debugPrint(#function, error)
        }
        
        completionHandler()
    }
    
}
