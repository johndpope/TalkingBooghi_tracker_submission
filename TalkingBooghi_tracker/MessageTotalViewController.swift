//
//  MessageTotalViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 12/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Firebase

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
    @IBAction func buttonClicked(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: "언어치료사에게 공유하기", message: "언어치료사에게 해당 내용을 질문하겠습니까?", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
            let sendPopup = UIAlertController(title: "전송 완료!", message: "언어치료사에게 해당 내용을 전송했습니다", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
            sendPopup.addAction(okButton)
            
            let newMessage = Message(
                member: self.conversationViewController.slpMember,
                text: "언어치료사에게 해당 내용을 보냈어요.",
                messageId: UUID().uuidString, time: self.conversationViewController.dateFormatter.string(from: Date()))
            
            self.conversationViewController.messages.append(newMessage)
            self.conversationViewController.db.collection("\(self.path)/messages").addDocument(data: ["message": newMessage.text, "messageid": newMessage.messageId, "sender": newMessage.member.name, "time": self.conversationViewController.dateFormatter.string(from: Date())]) { (err) in
                if err != nil {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
            self.conversationViewController.messagesCollectionView.reloadData()
            
            self.present(sendPopup, animated: true, completion: nil)
        }
        popup.addAction(cancelButton)
        popup.addAction(okButton)
        self.present(popup, animated: true, completion: nil)
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
