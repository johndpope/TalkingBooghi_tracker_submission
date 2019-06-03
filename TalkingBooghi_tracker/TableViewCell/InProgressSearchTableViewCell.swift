//
//  InProgressSearchTableViewCell.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 10/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit

class InProgressSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView! {
        didSet {
            cellView.layer.cornerRadius = 10
            cellView.clipsToBounds = true
        }
    }
    @IBOutlet weak var badgeOne: UILabel! {
        didSet {
            badgeOne.layer.cornerRadius = 5
            badgeOne.layer.borderColor = UIColor(red: 40/255.0, green: 206/255.0, blue: 65/255.0, alpha: 1).cgColor
            badgeOne.layer.borderWidth = 0.5
        }
    }
    @IBOutlet weak var badgeTwo: UILabel!
    @IBOutlet weak var badgeThree: UILabel! {
        didSet {
            badgeThree.layer.cornerRadius = 5
            badgeThree.layer.borderColor = UIColor(red: 40/255.0, green: 206/255.0, blue: 65/255.0, alpha: 1).cgColor
            badgeThree.layer.borderWidth = 0.5
            badgeThree.clipsToBounds = true
        }
    }
    @IBOutlet weak var badgeFour: UILabel! {
        didSet {
            badgeFour.layer.cornerRadius = 5
            badgeFour.layer.borderColor = UIColor(red: 40/255.0, green: 206/255.0, blue: 65/255.0, alpha: 1).cgColor
            badgeFour.layer.borderWidth = 0.5
            badgeFour.clipsToBounds = true
        }
    }
    @IBOutlet weak var creatorImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionField: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
