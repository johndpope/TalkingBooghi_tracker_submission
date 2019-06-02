//
//  RecordViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 03/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class RecordViewController: UIViewController {
    
    @IBOutlet var viewCollection: [UIView]! {
        didSet {
            for item in viewCollection {
                item.layer.cornerRadius = 10
            }
        }
    }
    @IBAction func observeClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goObserve", sender: sender)
    }
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        setBadge(self, db)
    }
    override func viewWillAppear(_ animated: Bool) {
        setBadge(self, db)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goObserve" {
            let dest = segue.destination as! ObservationViewController
            if let sendingButton = sender as? UIButton {
                switch sendingButton.tag {
                case 0:
                    dest.name = "신체"
                case 1:
                    dest.name = "시각"
                default:
                    dest.name = "인지"
                }
            }
        }
    }
}

struct Record: Codable {
    var cardtype: String
    var date: String
    var cardname: String
    var carddata = [String]()
    var month: String
    var weekofyear: String
    var time: String
    var totrecord: String
    
    init(cardtype: String, date: String, cardname: String, carddata: [String], month: String, weekofyear: String, time: String, totrecord: String) {
        self.cardtype = cardtype
        self.date = date
        self.cardname = cardname
        self.carddata = carddata
        self.month = month
        self.weekofyear = weekofyear
        self.time = time
        self.totrecord = totrecord
    }
}
struct Intervention: Codable {
    var carddata: [String]
    var cardname: String
    var cardtype: String
    var created: String
    var creator: String
    var description: String
    var result: String
    var isGood: Bool
    var status: String
    var type: String
    var interventiontype: String
    var date: String
    var weekofyear: String
    var month: String
    init(carddata: [String], cardname: String, cardtype: String, created: String, creator: String, description: String, result: String, isGood: Bool, status: String, type: String, interventiontype: String, date: String, weekofyear: String, month: String) {
        self.carddata = carddata
        self.cardname = cardname
        self.cardtype = cardtype
        self.created = created
        self.creator = creator
        self.description = description
        self.result = result
        self.isGood = isGood
        self.status = status
        self.type = type
        self.interventiontype = interventiontype
        self.date = date
        self.weekofyear = weekofyear
        self.month = month
    }
}
