//
//  FolderTableViewController.swift
//  Project Dusk
//
//  Created by AstroWIP
//  Copyright © 2019 AstroWIP. All rights reserved.
//
import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var name: String?
    @NSManaged public var owner: Folder?

}
