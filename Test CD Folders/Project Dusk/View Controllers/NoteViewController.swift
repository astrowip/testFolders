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

class NoteViewController: UIViewController {
    
    //MARK: CoreData
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Note>!
    private var query = ""
    
    //MARK: Local Variables
    var note: Note!
    var folder: Folder!
    var isNewNote = false
    
    //MARK: Local Outlets
    @IBOutlet weak var testNoteText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        print("Folder is \(String(describing: folder))")
        print("Note is \(String(describing: note))")
    }
    
    func updateView() {
        guard let noteSelected = note else {return}
        testNoteText.text = noteSelected.name
    }

    @IBAction func noteBackButtonTapped(_ sender: Any) {
        if isNewNote == true {
            if let test = testNoteText?.text, !test.isEmpty {
                let note = Note(entity: Note.entity(), insertInto: self.context)
                note.owner = folder
                note.name = test
                appDelegate.saveContext()
            }
        } else {
            if let test = testNoteText?.text, !test.isEmpty {
                note.name = test
                appDelegate.saveContext()
            }
        }
        performSegue(withIdentifier: "unwindToNotesTableViewController", sender: self)
    }

    
}

