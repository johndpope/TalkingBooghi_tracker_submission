//
//  ChooseCardViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 09/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import DateToolsSwift

class ChooseCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db: Firestore!
    
    var selectedRef = String()
    
    let dateFormatter : DateFormatter = DateFormatter()
    
    var recordArray = [Record]()
    var refArray = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noRememberCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! RecordTableViewCell
            cell.titleLabel.text = recordArray[indexPath.item-1].cardname
            cell.cardImage.image = UIImage(named: recordArray[indexPath.item-1].cardtype)?.withRenderingMode(.alwaysTemplate)
            var tempStr = ""
            for item in recordArray[indexPath.item-1].carddata {
                tempStr += "\(item) "
            }
            cell.contentCell.text = tempStr
            cell.dateField.text = dateFormatter.date(from: recordArray[indexPath.item-1].totrecord)?.timeAgoSinceNow
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item > 0 {
            selectedRef = refArray[indexPath.item-1]
        }
    }

    @IBOutlet weak var chooseTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        chooseTableView.delegate = self
        chooseTableView.dataSource = self
        
        db = Firestore.firestore()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        fetch()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetch()
    }
    
    func fetch() {
        db.collection("\(experimentID)_usage").order(by: "totrecord", descending: true).getDocuments { (snapshot, err) in
            self.recordArray = []
            self.refArray = []
            if err == nil {
                for item in snapshot!.documents {
                    print(snapshot!.documents)
                    let instance = try! FirestoreDecoder().decode(Record.self, from: item.data())
                    self.recordArray.append(instance)
                    self.refArray.append(item.reference.path)
                    print("nhu")
                    print(instance)
                }
                self.chooseTableView.reloadData()
            } else {
                self.view.makeToast(err?.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWriteCell" {
            let dest = segue.destination as! TakeNoteViewController
            let indexpath = chooseTableView.indexPath(for: sender as! UITableViewCell)
            dest.ref = selectedRef
            dest.cardRecord = recordArray[indexpath!.item-1]
        }
    }
}
