//
//  Note+CoreDataProperties.swift
//  NotesClone
//
//  Created by Selin Kayar on 25.07.24.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID!
    @NSManaged public var isPinned: Bool
    @NSManaged public var lastUpdated: Date!
    @NSManaged public var textData: Data!
    @NSManaged public var searchableText: String!

}

extension Note : Identifiable {

}
