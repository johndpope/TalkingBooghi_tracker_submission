//
//  MessageTotalViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 12/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit

class MessageTotalViewController: UIViewController {
    
    var path = String()
    var intervention: Intervention?
    
    let conversationViewController = MessageInProgressViewController()
    
    /// Required for the `MessageInputBar` to be visible
    override var canBecomeFirstResponder: Bool {
        return conversationViewController.canBecomeFirstResponder
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        conversationViewController.path = path
        conversationViewController.intervention = intervention
        conversationViewController.willMove(toParentViewController: self)
        addChildViewController(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParentViewController: self)
        
        title = intervention?.description
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        conversationViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
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
