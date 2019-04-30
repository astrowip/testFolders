//
//  FolderTableViewController.swift
//  Project Dusk
//
//  Created by AstroWIP
//  Copyright © 2019 AstroWIP. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class NotesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: CoreData
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Note>!
    private var query = ""
    
    //MARK: Local Variables
    var folder: Folder!
    var isMasterFolder = false
    
    //MARK: Local Outlets
    @IBOutlet weak var notesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    private func refresh() {
        do {
            let request = Note.fetchRequest() as NSFetchRequest<Note>
            if isMasterFolder == true {
//                request.predicate = NSPredicate(format: "name CONTAINS[cd] %@")
            } else if query.isEmpty {
                request.predicate = NSPredicate(format: "owner = %@", folder)
            } else {
                request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND owner = %@", query, folder)
            }
            
            
            let sort = NSSortDescriptor(key: #keyPath(Note.name), ascending: false, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            
            request.sortDescriptors = [sort]
            do {
                fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                try fetchedRC.performFetch()
                fetchedRC.delegate = self
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    //MARK: — Tableview Setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        let count = fetchedRC.fetchedObjects?.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesTableViewCell
        let notes = fetchedRC.object(at: indexPath)
        cell.update(with: notes)
        return cell
    }

    //MARK: — Tableview slide to delete
    func tableView(_ tableView: UITableView, commit
        editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:
        IndexPath) {
        if editingStyle == .delete {
            let note = fetchedRC.object(at: indexPath)
            confirmDelete(note: note)
        }
    }
    
    private func confirmDelete(note: Note) {
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to permanently delete the note \(note.name!)?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (action) -> Void in
            self.context.delete(note)
            self.appDelegate.saveContext()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Segues
    struct PropertyKeys {
        static let addNoteSegue = "AddNote"
        static let editNoteSegue = "EditNote"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case PropertyKeys.addNoteSegue:
            print("Add Note Segue happened")
            let destination = segue.destination as! NoteViewController
            let test = folder
            destination.folder = test
            destination.isNewNote = true
            
        case PropertyKeys.editNoteSegue:
            if let indexPath = notesTableView.indexPathForSelectedRow {
                print("Edit Note Segue happened")
                let destination = segue.destination as! NoteViewController
                let note = fetchedRC.object(at: indexPath)
                let test = folder
                destination.note = note
                destination.folder = test
            }
        default: print("Unknown segue")
        }
    }
    
    @IBAction func unwindToNotesTableViewController(segue: UIStoryboardSegue) {
        print("Unwind to Notes List Table View Controller")
        let source = segue.source as? NoteViewController
        self.folder = source?.folder
    }
}

//MARK: Allows Tableview to automatically update with new items/deleted items
extension NotesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.notesTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.notesTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            self.notesTableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            self.notesTableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
}
