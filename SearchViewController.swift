//
//  SearchViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 03/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import TagListView
import DateToolsSwift

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AgreeAsk {
    
    func clicked(sender: UITableViewCell, isAgree: Bool) {
        if isAgree {
            if let idxPath = self.searchTableView.indexPath(for: sender) {
                db.document(refArray[idxPath.item]).updateData(["status": "done"])
                searchArray.remove(at: idxPath.item)
                refArray.remove(at: idxPath.item)
                searchTableView.deleteRows(at: [idxPath], with: .automatic)
            }
        } else {
            if let idxPath = self.searchTableView.indexPath(for: sender) {
                db.document(refArray[idxPath.item]).updateData(["status": "inprogress"])
                searchArray.remove(at: idxPath.item)
                refArray.remove(at: idxPath.item)
                searchTableView.deleteRows(at: [idxPath], with: .automatic)
            }
        }
        setBadge(self, db)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var db: Firestore!
    
    var dateFormatter = DateFormatter()
    
    var searchArray = [Intervention]()
    var refArray = [String]()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetch(searchBar.text ?? "", searchBar.selectedScopeButtonIndex == 0)
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        fetch(searchBar.text ?? "", selectedScope == 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let element = searchArray[indexPath.item]
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
        
        switch element.status {
        case "init":
            let cell = tableView.dequeueReusableCell(withIdentifier: "undoneCell", for: indexPath) as! UndoneSearchTableViewCell
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
            if searchArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        case "inprogress":
            let cell = tableView.dequeueReusableCell(withIdentifier: "inProgressCell", for: indexPath) as! InProgressSearchTableViewCell
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
            if searchArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        case "done":
            let cell = tableView.dequeueReusableCell(withIdentifier: "doneCell", for: indexPath) as! DoneSearchTableViewCell
            cell.badgeOne.text = "해결완료"
            cell.badgeTwo.text = interventionType
            cell.badgeThree.text = element.isGood ? "긍정":"부정"
            cell.finalField.text = element.result
            if element.creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            cell.doneImage.isHidden = (element.result == "")
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
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "holdonCell", for: indexPath) as! HoldOnSearchTableViewCell
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
            if searchArray[indexPath.item].creator == "부모" {
                cell.creatorImage.image = UIImage(named: "parents_icon")
            } else {
                cell.creatorImage.image = UIImage(named: "teacher_icon")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goConversation1", sender: tableView.cellForRow(at: indexPath))
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    @IBOutlet weak var searchTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        db = Firestore.firestore()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        searchBar.delegate = self
        
        fetch(searchBar.text ?? "", searchBar.selectedScopeButtonIndex == 0)
        
        setBadge(self, db)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetch(searchBar.text ?? "", searchBar.selectedScopeButtonIndex == 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goConversation1" {
            let vc = segue.destination as! MessageTotalViewController
            if let idxPath = searchTableView.indexPath(for: sender as! UITableViewCell) {
                vc.path = refArray[idxPath.item]
                vc.intervention = searchArray[idxPath.item]
            }
        }
    }
    
    func fetch(_ query: String, _ isDone: Bool) {
        if isDone {
            db.collection("\(experimentID)_intervention").order(by: "created", descending: true).getDocuments { (snapshot, err) in
                if err == nil {
                    self.searchArray = []
                    self.refArray = []
                    for item in snapshot!.documents {
                        print(snapshot!.documents)
                        let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                        if instance.status == "done" {
                            if query == "" {
                                self.searchArray.append(instance)
                                self.refArray.append(item.reference.path)
                                print(instance)
                            } else {
                                if (instance.description + instance.interventiontype).contains(query) {
                                    self.searchArray.append(instance)
                                    self.refArray.append(item.reference.path)
                                    print(instance)
                                }
                            }
                        }
                    }
                    self.searchTableView.reloadData()
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        } else {
            db.collection("\(experimentID)_intervention").order(by: "created", descending: true).getDocuments { (snapshot, err) in
                if err == nil {
                    self.searchArray = []
                    self.refArray = []
                    for item in snapshot!.documents {
                        print(snapshot!.documents)
                        let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                        if instance.status != "init" || instance.creator != experimentRole {
                            if query == "" {
                                self.searchArray.append(instance)
                                self.refArray.append(item.reference.path)
                                print(instance)
                            } else {
                                if (instance.description + instance.interventiontype + instance.result).contains(query) {
                                    self.searchArray.append(instance)
                                    self.refArray.append(item.reference.path)
                                    print(instance)
                                }
                            }
                        }
                    }
                    self.searchTableView.reloadData()
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        }
    }
}
