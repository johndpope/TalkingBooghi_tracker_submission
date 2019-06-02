//
//  NoRecordTableViewCell.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 09/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit

class NoRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView! {
        didSet {
            cardView.layer.cornerRadius = 10
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
