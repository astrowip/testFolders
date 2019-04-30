//
//  FolderTableViewController.swift
//  Project Dusk
//
//  Created by AstroWIP
//  Copyright © 2019 AstroWIP. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var folderCellLabel: UILabel!
    @IBOutlet weak var folderCellImage: UIImageView!

    func update(with folder: Folder) {
        folderCellLabel.text = folder.name
        switch folder.icon {
        case "normalFolder":
            folderCellImage.image =  UIImage(named: "folderIcon")
        default:
            folderCellImage.image = UIImage(named: "folderIcon")
        }
    }
    

    
    func updateAllNotes(with folders: folderNames) {
        folderCellLabel.text = folders.name
        switch folders.icon {
        case "normalFolder":
            folderCellImage.image =  UIImage(named: "folderIcon")
        default:
            folderCellImage.image = UIImage(named: "folderIcon")
        }
}
}

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }


//    If it’s something that’s going to be there during the whole lifecycle of the cell, like a label’s font, put it in the awakeFromNib method.
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }


