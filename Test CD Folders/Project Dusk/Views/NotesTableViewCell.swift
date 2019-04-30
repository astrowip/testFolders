//
//  FolderTableViewController.swift
//  Project Dusk
//
//  Created by AstroWIP
//  Copyright © 2019 AstroWIP. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notesCellLabel: UILabel!
    
    func update(with notes: Note) {
        notesCellLabel.text = notes.name
    }
}


//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
