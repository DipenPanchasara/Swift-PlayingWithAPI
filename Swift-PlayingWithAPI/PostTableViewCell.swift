//
//  PostTableViewCell.swift
//  Swift-PlayingWithAPI
//
//  Created by Dipen Panchasara on 07/06/16.
//  Copyright © 2016 Company Name. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var lblId:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblBody:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblId.font = UIFont(name: "Helvetica", size: 30)
        self.lblId.textAlignment = .Center
        self.lblTitle.font = UIFont(name: "Helvetica-Bold", size: 16)
        self.lblBody.font = UIFont(name: "Helvetica", size: 14)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
