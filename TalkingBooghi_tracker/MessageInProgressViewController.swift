//
//  MessageInProgressViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 10/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import SwiftyJSON

class MessageInProgressViewController: MessagesViewController {
    
    var db: Firestore!
    
    var messages: [Message] = []
    var meMember: Member!
    var againstMember: Member!
    
    var path = String()
    var intervention: Intervention?
    
    var dateFormatter = DateFormatter()
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.displayName == experimentRole {
            return UIColor.lightGray
        } else {
            return UIColor.lightGray
        }
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12)])
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        fetchMessage(path: path)
        print(path)
        
        if experimentRole == "부모" {
            meMember = Member(name: experimentRole, color: .blue)
            againstMember = Member(name: "교사", color: .lightGray)
        } else {
            meMember = Member(name: experimentRole, color: .blue)
            againstMember = Member(name: "부모", color: .lightGray)
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 50, right: 0)
        messagesCollectionView.backgroundColor = .darkGray
        
        messageInputBar.padding.bottom = 10
        
        messageInputBar.bottomStackView.alignment = .center
        messageInputBar.inputTextView.placeholder = "메시지를 입력하세요"
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let stt = intervention?.status {
            setButtons(type: stt)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    private func makeButton(_ type: Int) -> InputBarButtonItem {
        let button = InputBarButtonItem()
        
        button.setSize(CGSize(width: 100, height: 50), animated: false)
        switch type {
        case 0:
            button.setImage(UIImage(named: "agree_icon"), for: .normal)
        case 1:
            button.setImage(UIImage(named: "pending_icon"), for: .normal)
        default:
            button.setImage(UIImage(named: "redo_icon"), for: .normal)
        }
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 7
        button.tintColor = UIColor(white: 0.8, alpha: 1)
        button.onTouchUpInside { (item) in
            switch type {
            case 0:
                print("agree")
                self.db.document(self.path).updateData(["status": "done"], completion: { (err) in
                    if err == nil {
                        self.view.makeToast("동의를 완료했습니다")
                        self.setButtons(type: "done")
                    } else {
                        self.view.makeToast(err?.localizedDescription)
                    }
                })
            case 1:
                print("holdon")
                self.db.document(self.path).updateData(["status": "holdon"], completion: { (err) in
                    if err == nil {
                        self.view.makeToast("보류를 완료했습니다")
                        self.setButtons(type: "holdon")
                    } else {
                        self.view.makeToast(err?.localizedDescription)
                    }
                })
            default:
                print("resume")
                self.db.document(self.path).updateData(["status": "inprogress"], completion: { (err) in
                    if err == nil {
                        self.view.makeToast("대화를 재개합니다")
                        self.setButtons(type: "inprogress")
                    } else {
                        self.view.makeToast(err?.localizedDescription)
                    }
                })
            }
        }
        
        return button
    }
    func setButtons(type: String) {
        switch type {
        case "done":
            messageInputBar.isHidden = true
            messageInputBar.inputTextView.isHidden = true
            messageInputBar.sendButton.isHidden = true
        case "inprogress":
            messageInputBar.isHidden = false
            messageInputBar.setStackViewItems([.fixedSpace(30),makeButton(0),.flexibleSpace,makeButton(1),.fixedSpace(30)], forStack: .bottom, animated: false)
            messageInputBar.inputTextView.isHidden = false
            messageInputBar.sendButton.isHidden = false
        default:
            messageInputBar.isHidden = false
            messageInputBar.setStackViewItems([makeButton(2)], forStack: .bottom, animated: false)
            messageInputBar.inputTextView.isHidden = true
            messageInputBar.sendButton.isHidden = true
            
        }
    }
    
    func fetchMessage(path: String) {
        db.collection("\(path)/messages").order(by: "time", descending: false).getDocuments { (snapshot, err) in
            print(path)
            if err == nil {
                self.messages = []
                for item in snapshot!.documents {
                    let jsonRaw = try? JSONSerialization.data(withJSONObject: item.data(), options: .prettyPrinted)
                    if let json = try? JSON(data: jsonRaw ?? Data()) {
                        let message = Message(member: Member(name: json["sender"].stringValue, color: .blue), text: json["message"].stringValue, messageId: json["messageid"].stringValue, time: json["time"].stringValue)
                        self.messages.append(message)
                    }
                }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            } else {
                self.view.makeToast(err?.localizedDescription)
            }
        }
    }
}

struct Member {
    let name: String
    let color: UIColor
}

struct Message {
    let member: Member
    let text: String
    let messageId: String
    let time: String
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

extension MessageInProgressViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: meMember.name, displayName: meMember.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
}

extension MessageInProgressViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}
extension MessageInProgressViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
    
        avatarView.initials = message.sender.displayName
    }
}
extension MessageInProgressViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        let newMessage = Message(
            member: meMember,
            text: text,
            messageId: UUID().uuidString, time: dateFormatter.string(from: Date()))
        
        messages.append(newMessage)
        db.collection("\(path)/messages").addDocument(data: ["message": newMessage.text, "messageid": newMessage.messageId, "sender": newMessage.member.name, "time": dateFormatter.string(from: Date())]) { (err) in
            if err != nil {
                self.view.makeToast(err?.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        inputBar.inputTextView.resignFirstResponder()
    }
}
