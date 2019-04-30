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

class FolderTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: CoreData
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Folder>!
    private var query = ""
    private let reususeIdentifier = "folderCell"
    
    //MARK: Local Variables
    
    //MARK: Local Outlets
    @IBOutlet weak var folderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //FIXME: Is this needed?
        if let path = folderTableView.indexPathForSelectedRow {
            folderTableView.deselectRow(at: path, animated: true)
        }
        refresh()
    }

    private func refresh() {
        do {
            let request = Folder.fetchRequest() as NSFetchRequest<Folder>
            if !query.isEmpty {
                request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
            }
            let sort = NSSortDescriptor(keyPath: \Folder.name, ascending: true)
            request.sortDescriptors = [sort]
            do {
                fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedRC.delegate = self
                try fetchedRC.performFetch()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    //MARK: — Tableview Setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return fetchedRC.fetchedObjects?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reususeIdentifier, for: indexPath) as! FolderTableViewCell
        switch indexPath.section {
        case 0:
            let folders = folderNames(name: "All Notes", icon: "normalFolder")
            cell.updateAllNotes(with: folders)
        default:
            let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
            let folder = fetchedRC.object(at: adjustedIndexPath)
            cell.update(with: folder)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Master Folders", comment: "mySectionName")
        case 1:
            sectionName = NSLocalizedString("Custom Folders", comment: "myOtherSectionName")
        default:
            sectionName = ""
        }
        return sectionName
    }

    //MARK: — Tableview slide to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit
        editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:
        IndexPath) {
        if editingStyle == .delete {
            let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
            let folder = fetchedRC.object(at: adjustedIndexPath)
            confirmDelete(folder: folder)
        }
    }
    
    private func confirmDelete(folder: Folder) {
        let deleteFolderAlert = UIAlertController(title: "Delete Folder", message: "Are you sure you want to permanently delete the folder \(folder.name)?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (action) -> Void in
            self.context.delete(folder)
            self.appDelegate.saveContext()
        }
        deleteFolderAlert.addAction(UIAlertAction(title: "Cancel", style: .default))
        deleteFolderAlert.addAction(deleteAction)
        present(deleteFolderAlert, animated: true, completion: nil)
    }
    
    //    MARK: — Plus Button Alert Controller
    //    FIXME: Enable submit only when textfield has text
    @IBAction func plusButtonTapped(_ sender: Any) {
        var folderLabelTextField: UITextField?
        let newFolderAlert = UIAlertController( title: "New Folder", message: "Enter a name for this folder", preferredStyle: .alert)
        let submitAction = UIAlertAction(
        title: "Submit", style: .default) {
            (action) -> Void in
            if let folderLabel = folderLabelTextField?.text, !folderLabel.isEmpty {
                let folder = Folder(entity: Folder.entity(), insertInto: self.context)
                folder.name = folderLabel
                folder.icon = "normalFolder"
                self.appDelegate.saveContext()
            } else {
                print("No folder name entered")
            }
        }
        newFolderAlert.addTextField {
            (txtFolderLabel) -> Void in
            folderLabelTextField = txtFolderLabel
            folderLabelTextField!.placeholder = "Folder name"
        }
        newFolderAlert.addAction(UIAlertAction(title: "Cancel", style: .default))
        newFolderAlert.addAction(submitAction)
        present(newFolderAlert, animated: true, completion: nil)
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "foldersToListOfNotes") {
            if let indexPath = folderTableView.indexPathForSelectedRow {
                let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
                switch indexPath.section {
                case 0: let destination = segue.destination as! NotesTableViewController
                destination.isMasterFolder = true
                default:
                    let destination = segue.destination as! NotesTableViewController
                    let folder = fetchedRC.object(at: adjustedIndexPath)
                    destination.folder = folder
                }
            }
        }
    }
    
    @IBAction func unwindToFolderTableViewController(segue: UIStoryboardSegue) {
        print("Unwind to Table View Controller")
    }
}



//MARK: Allows Tableview to automatically update with new items/deleted items
extension FolderTableViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert where newIndexPath?.section == 0:
            guard let newIndexPath = newIndexPath else {
                return
            }
            let adjustedIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            folderTableView.insertRows(at: [adjustedIndexPath], with: .automatic)
        case .delete:
            let adjustedIndexPath = IndexPath(row: indexPath!.row, section: 1)
            folderTableView.deleteRows(at: [adjustedIndexPath], with: .automatic)
        case .update:
            let adjustedIndexPath = IndexPath(row: indexPath!.row, section: 1)
            folderTableView.reloadRows(at: [adjustedIndexPath], with: .automatic)
        case .move:
            let adjustedIndexPath = IndexPath(row: indexPath!.row, section: 1)
            folderTableView.moveRow(at: adjustedIndexPath, to: newIndexPath!)
        default:
            break
        }
    }
}
