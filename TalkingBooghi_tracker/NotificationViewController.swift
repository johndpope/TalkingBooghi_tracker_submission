//
//  NotificationViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 20/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import Firebase
import CodableFirebase
import DateToolsSwift


protocol AgreeAsk {
    func clicked(sender: UITableViewCell ,isAgree: Bool)
}

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AgreeAsk {
    
    var dateFormatter = DateFormatter()
    
    func clicked(sender: UITableViewCell, isAgree: Bool) {
        if isAgree {
            if let idxPath = self.notificationTableView.indexPath(for: sender) {
                db.document(refArray[idxPath.item]).updateData(["status": "done"])
                notificationArray.remove(at: idxPath.item)
                refArray.remove(at: idxPath.item)
                notificationTableView.deleteRows(at: [idxPath], with: .automatic)
            }
        } else {
            if let idxPath = self.notificationTableView.indexPath(for: sender) {
                db.document(refArray[idxPath.item]).updateData(["status": "inprogress"])
                notificationArray.remove(at: idxPath.item)
                refArray.remove(at: idxPath.item)
                notificationTableView.deleteRows(at: [idxPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let element = notificationArray[indexPath.item]
        var interventionType = String()
        switch element.type {
        case "communication":
            interventionType = "의사소통"
        case "physical":
            interventionType = "신체"
        case "visual":
            interventionType = "시각"
        default:
            interventionType = "인지"
        }
        let cellDate = dateFormatter.date(from: element.created)
        
        switch mainSegmentControl.index {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "undoneNotiCell", for: indexPath) as! UndoneSearchTableViewCell
            cell.badgeOne.text = "대기 중"
            cell.badgeTwo.text = interventionType
            cell.badgeThree.text = element.isGood ? "긍정":"부정"
            if element.isGood {
                cell.badgeThree.textColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 0.05)
            } else {
                cell.badgeThree.textColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 0.05)
            }
            cell.descriptionField.text = element.description
            cell.dateLabel.text = cellDate?.timeAgoSinceNow
            cell.delegate = self
            cell.segmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
            if notificationArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inProgressNotiCell", for: indexPath) as! InProgressSearchTableViewCell
            cell.badgeOne.text = "진행 중"
            cell.badgeTwo.text = interventionType
            cell.badgeThree.text = element.isGood ? "긍정":"부정"
            if element.isGood {
                cell.badgeThree.textColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 0.05)
            } else {
                cell.badgeThree.textColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 0.05)
            }
            cell.descriptionField.text = element.description
            cell.dateLabel.text = cellDate?.timeAgoSinceNow
            if notificationArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "holdonNotiCell", for: indexPath) as! HoldOnSearchTableViewCell
            cell.badgeOne.text = "보류 중"
            cell.badgeTwo.text = interventionType
            cell.badgeThree.text = element.isGood ? "긍정":"부정"
            if element.isGood {
                cell.badgeThree.textColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 0.05)
            } else {
                cell.badgeThree.textColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1)
                cell.badgeThree.layer.borderColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1).cgColor
                cell.badgeThree.backgroundColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 0.05)
            }
            cell.descriptionField.text = element.description
            cell.dateLabel.text = cellDate?.timeAgoSinceNow
            if notificationArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationArray[indexPath.item].status != "init" {
            performSegue(withIdentifier: "goConversation", sender: tableView.cellForRow(at: indexPath))
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    var notificationArray = [Intervention]()
    var refArray = [String]()
    
    var db: Firestore!
    
    
    @IBOutlet weak var mainSegmentControl: BetterSegmentedControl! {
        didSet {
            mainSegmentControl.segments = LabelSegment.segments(withTitles: ["대기중", "진행중", "보류중"], normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            mainSegmentControl.setIndex(0)
            mainSegmentControl.addTarget(self, action: #selector(self.mainSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    @objc func mainSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        print(Int(mainSegmentControl!.index))
        fetch(Int(mainSegmentControl!.index))
    }
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        setBadge(self, db)
        
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko-kr")
        
        fetch(Int(mainSegmentControl.index))
    }
    override func viewWillAppear(_ animated: Bool) {
        setBadge(self, db)
        fetch(Int(mainSegmentControl.index))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goConversation" {
            let vc = segue.destination as! MessageTotalViewController
            if let idxPath = notificationTableView.indexPath(for: sender as! UITableViewCell) {
                vc.path = refArray[idxPath.item]
                vc.intervention = notificationArray[idxPath.item]
            }
        }
    }
    
    func fetch(_ index: Int) {
        switch index {
        case 0:
            db.collection("\(experimentID)_intervention").order(by: "created", descending: true).getDocuments { (snapshot, err) in
                self.notificationArray = []
                self.refArray = []
                if err == nil {
                    for item in snapshot!.documents {
                        print(snapshot!.documents)
                        let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                        if instance.creator != experimentRole && instance.status == "init" {
                            self.notificationArray.append(instance)
                            self.refArray.append(item.reference.path)
                        }
                        print("nhu")
                        print(instance)
                    }
                    self.notificationTableView.reloadData()
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        case 1:
            db.collection("\(experimentID)_intervention").order(by: "created", descending: true).getDocuments { (snapshot, err) in
                self.notificationArray = []
                self.refArray = []
                if err == nil {
                    for item in snapshot!.documents {
                        print(snapshot!.documents)
                        let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                        if instance.status == "inprogress" {
                            self.notificationArray.append(instance)
                            self.refArray.append(item.reference.path)
                        }
                        print("nhu")
                        print(instance)
                    }
                    self.notificationTableView.reloadData()
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        default:
            db.collection("\(experimentID)_intervention").order(by: "created", descending: true).getDocuments { (snapshot, err) in
                self.notificationArray = []
                self.refArray = []
                if err == nil {
                    for item in snapshot!.documents {
                        print(snapshot!.documents)
                        let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                        if instance.status == "holdon" {
                            self.notificationArray.append(instance)
                            self.refArray.append(item.reference.path)
                        }
                        print("nhu")
                        print(instance)
                    }
                    self.notificationTableView.reloadData()
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        }
        print(notificationArray.count)
    }
}

func setBadge(_ vc: UIViewController, _ db: Firestore) {
    if experimentRole == "부모" {
        db.collection("\(experimentID)_intervention").whereField("status", isEqualTo: "init").whereField("creator", isEqualTo: "교사").getDocuments { (snapshot, err) in
            if err == nil {
                if snapshot!.documents.count == 0 {
                    vc.tabBarController?.tabBar.items![2].badgeValue = nil
                } else {
                    vc.tabBarController?.tabBar.items![2].badgeValue = String(snapshot!.documents.count)
                }
            } else {
            }
        }
    } else {
        db.collection("\(experimentID)_intervention").whereField("status", isEqualTo: "init").whereField("creator", isEqualTo: "부모").getDocuments { (snapshot, err) in
            if err == nil {
                if snapshot!.documents.count == 0 {
                    vc.tabBarController?.tabBar.items![2].badgeValue = nil
                } else {
                    vc.tabBarController?.tabBar.items![2].badgeValue = String(snapshot!.documents.count)
                }
            } else {
            }
        }
    }
}
