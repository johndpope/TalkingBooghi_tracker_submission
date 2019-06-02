//
//  DoneSearchTableViewCell.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 10/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit

class DoneSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView! {
        didSet {
            cellView.layer.cornerRadius = 10
            cellView.clipsToBounds = true
        }
    }
    @IBOutlet weak var badgeOne: UILabel! {
        didSet {
            badgeOne.layer.cornerRadius = 5
            badgeOne.layer.borderColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1).cgColor
            badgeOne.layer.borderWidth = 0.5
        }
    }
    @IBOutlet weak var badgeTwo: UILabel!
    @IBOutlet weak var badgeThree: UILabel! {
        didSet {
            badgeThree.layer.cornerRadius = 5
            badgeThree.layer.borderColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1).cgColor
            badgeThree.layer.borderWidth = 0.5
            badgeThree.clipsToBounds = true
        }
    }
    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var creatorImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var finalField: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
