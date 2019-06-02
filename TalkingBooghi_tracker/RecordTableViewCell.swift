//
//  RecordTableViewCell.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 03/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    var ref = String()
    
    @IBOutlet weak var cardView: UIView! {
        didSet {
            cardView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var contentCell: UITextView! {
        didSet {
            contentCell.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.layer.masksToBounds = true
            titleLabel.layer.cornerRadius = 7
        }
    }
    
    @IBOutlet weak var cardImage: UIImageView!
    
    @IBOutlet weak var dateField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
