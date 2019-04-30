//
//  FolderTableViewCell.swift
//  Project Dusk
//
//  Created by Leio Ohshima McLaren on 9/4/19.
//  Copyright © 2019 Leio Ohshima McLaren. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var folderCellLabel: UILabel!
    @IBOutlet weak var folderCellImage: UIImageView!
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
    
//    If it’s something that’s going to be there during the whole lifecycle of the cell, like a label’s font, put it in the awakeFromNib method.
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
    

   func update(with folder: Folder) {
       folderCellLabel.text = folder.name
//       folderCellImage.image = folder.icon
   }
}
