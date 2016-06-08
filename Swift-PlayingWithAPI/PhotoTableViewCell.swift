//
//  PhotoTableViewCell.swift
//  Swift-PlayingWithAPI
//
//  Created by Dipen Panchasara on 07/06/16.
//  Copyright © 2016 Company Name. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblTitle.font = UIFont(name: "Helvetica", size: 14)
        self.imgView.contentMode = .ScaleAspectFill
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
