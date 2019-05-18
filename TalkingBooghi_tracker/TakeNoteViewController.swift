//
//  TakeNoteViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 19/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import Cosmos
import Speech
import Firebase
import Toast_Swift

class TakeNoteViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    var dateFormatter = DateFormatter()
    let dateFormatter1: DateFormatter = DateFormatter()
    
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    lazy var noteTypeArray = ["질문", "관찰", "발달상황"]
    var titleArray = ["의사소통 주제", "발달 속도", "기타"]
    
    var cardRecord: Record?
    var ref = String()
    
    @objc func mainSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        print(Int(mainSegmentControl!.index))
    }
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var secondSegmentControl: BetterSegmentedControl! {
        didSet {
            secondSegmentControl.segments = LabelSegment.segments(withTitles: titleArray, normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0,                                     weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            secondSegmentControl.setIndex(0)
            secondSegmentControl.addTarget(self, action: #selector(self.secondSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    @IBAction func secondSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index != 2 {
            findTextField.isHidden = true
        } else {
            findTextField.isHidden = false
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.masksToBounds = true
            textView.layer.cornerRadius = 10
        }
    }
    
    var db = Firestore.firestore()
    
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var recognizeButton: UIButton!
    
    @IBOutlet weak var clickRecordButton: UIButton! {
        didSet {
            clickRecordButton.layer.masksToBounds = true
            clickRecordButton.layer.cornerRadius = 10
        }
    }
    
    @IBAction func clickRecordButtonClicked(_ sender: UIButton) {
        db = Firestore.firestore()
        
        let isGood = Int(mainSegmentControl.index) == 0 ? true : false
        
        
        var interventiontype = String()
        
        if Int(secondSegmentControl.index) == 2 {
            interventiontype = findTextField.text ?? ""
        } else {
            interventiontype = titleArray[Int(secondSegmentControl.index)]
        }
        let dateComponents = Calendar.current.dateComponents([.weekOfYear, .month], from: Date())
        
        if let record = cardRecord {
            let array = ["carddata": record.carddata, "cardname": record.cardname, "cardtype": record.cardtype, "created": dateFormatter.string(from: Date()), "creator": experimentRole, "isGood": isGood, "status": "init", "type": "communication", "interventiontype": interventiontype, "description": textView.text, "date": dateFormatter1.string(from: Date()), "weekofyear": String(dateComponents.weekOfYear ?? 0), "month": String(dateComponents.month ?? 0)] as [String : Any]
            db.collection("\(experimentID)_intervention").addDocument(data: array) { (err) in
                if err == nil {
                    self.view.makeToast("기록이 완료되었습니다")
                } else {
                    self.view.makeToast(err?.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognizeButton.setImage(UIImage(named:"ready"), for: .normal)
        } else {
            startRecording()
            recognizeButton.setImage(UIImage(named:"recognizing"), for: .normal)
        }
    }
    
    @IBOutlet weak var mainSegmentControl: BetterSegmentedControl! {
        didSet {
            mainSegmentControl.segments = LabelSegment.segments(withTitles: ["발전한 것 같아요", "문제가 생겼어요"], normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0,                                     weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            mainSegmentControl.setIndex(1)
            mainSegmentControl.addTarget(self, action: #selector(self.mainSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var cardImage: UIImageView! {
        didSet {
            cardImage.image = UIImage(named: "routine")?.withRenderingMode(.alwaysTemplate)
        }
    }
    @IBOutlet weak var cardName: UILabel! {
        didSet {
            cardName.layer.masksToBounds = true
            cardName.layer.cornerRadius = 7
        }
    }
    @IBOutlet weak var cardDetail: UITextView! {
        didSet {
            cardDetail.layer.cornerRadius = 7
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        
        requestSpeechAuthorization()
        
        if let record = cardRecord {
            cardImage.image = UIImage(named: record.cardtype)!.withRenderingMode(.alwaysTemplate)
            cardName.text = record.cardname
            var text = ""
            for (index, item) in record.carddata.enumerated() {
                if index != 0 {
                    text += "   \(item)"
                } else {
                    text += item
                }
            }
            cardDetail.text = text
        }
    }
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recognizeButton.isEnabled = true
                case .denied:
                    self.recognizeButton.isEnabled = false
                case .restricted:
                    self.recognizeButton.isEnabled = false
                case .notDetermined:
                    self.recognizeButton.isEnabled = false
                }
            }
        }
    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        recognitionRequest!.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recognizeButton.setImage(UIImage(named:"ready"), for: .normal)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
}
