//
//  SettingsViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 20/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Toast_Swift

class SettingsViewController: UIViewController {
    @IBOutlet weak var abortButton: UIButton! {
        didSet {
            abortButton.layer.cornerRadius = 10
        }
    }
    @IBAction func abortButtonClicked(_ sender: UIButton) {
        exit(0)
    }
    
    @IBOutlet weak var childName: UITextField!
    @IBOutlet weak var childNameButton: UIButton! {
        didSet {
            childNameButton.layer.masksToBounds = true
            childNameButton.layer.cornerRadius = 10
        }
    }
    @IBAction func childNameButtonClicked(_ sender: UIButton) {
        if childName.text != "" {
            experimentID = childName.text!
        } else {
            experimentID = "john"
        }
        self.view.makeToast("등록 완료")
    }
    
    
    @IBOutlet weak var role: UITextField!
    @IBOutlet weak var roleButton: UIButton! {
        didSet {
            roleButton.layer.masksToBounds = true
            roleButton.layer.cornerRadius = 10
        }
    }
    @IBAction func roleButtonClicked(_ sender: UIButton) {
        if role.text != "" {
            experimentRole = role.text!
        } else {
            experimentRole = "부모"
        }
        self.view.makeToast("등록 완료")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setField()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setField()
    }
    
    func setField() {
        if experimentID != "john" {
            childName.text = experimentID
        } else {
            childName.text = "john"
        }
        if experimentRole != "부모" {
            role.text = experimentRole
        } else {
            role.text = "부모"
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
