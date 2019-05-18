//
//  ObservationViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 09/05/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Speech
import Firebase
import BetterSegmentedControl

class ObservationViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var db = Firestore.firestore()
    
    var dateFormatter = DateFormatter()
    
    let dateFormatter1: DateFormatter = DateFormatter()
    
    var titleArray = ["신체": ["손 움직임", "청각", "기타"], "시각": ["카드 크기", "화면 밝기", "기타"], "인지": ["카드 크기", "카테고리", "기타"]]
    
    var name = String()
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @objc func mainSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        print(Int(mainSegmentControl!.index))
    }
    @IBOutlet weak var mainSegmentControl: BetterSegmentedControl! {
        didSet {
            mainSegmentControl.segments = LabelSegment.segments(withTitles: ["발전한 것 같아요", "문제가 생겼어요"], normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0,                                     weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            mainSegmentControl.setIndex(0)
            mainSegmentControl.addTarget(self, action: #selector(self.mainSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    @IBOutlet weak var secondSegmentControl: BetterSegmentedControl! {
        didSet {
            secondSegmentControl.segments = LabelSegment.segments(withTitles: titleArray[name]!, normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0,                                     weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            secondSegmentControl.setIndex(0)
            secondSegmentControl.addTarget(self, action: #selector(self.secondSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var findTextField: UITextField!
    
    @IBAction func secondSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index != 2 {
            findTextField.isHidden = true
        } else {
            findTextField.isHidden = false
        }
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var clickRecordButton: UIButton! {
        didSet {
            clickRecordButton.layer.masksToBounds = true
            clickRecordButton.layer.cornerRadius = 10
        }
    }
    
    @IBAction func clickRecordButtonClicked(_ sender: UIButton) {
        db = Firestore.firestore()
        
        let isGood = Int(mainSegmentControl.index) == 0 ? true : false
        
        var recordType = String()
        
        switch name {
        case "육체":
            recordType = "physical"
        case "시각":
            recordType = "visual"
        default:
            recordType = "cognitive"
        }
        
        var interventiontype = String()

        if Int(secondSegmentControl.index) == 2 {
            interventiontype = findTextField.text ?? ""
        } else {
            interventiontype = titleArray[name]![Int(secondSegmentControl.index)]
        }
        let dateComponents = Calendar.current.dateComponents([.weekOfYear, .month], from: Date())
        
        let array = ["carddata": [], "cardname": "", "cardtype": "nil", "created": dateFormatter.string(from: Date()), "creator": experimentRole, "isGood": isGood, "status": "init", "type": recordType, "interventiontype": interventiontype, "description": textView.text, "date": dateFormatter1.string(from: Date()), "weekofyear": String(dateComponents.weekOfYear ?? 0), "month": String(dateComponents.month ?? 0)] as [String : Any]
        db.collection("\(experimentID)_intervention").addDocument(data: array) { (err) in
            if err == nil {
                self.view.makeToast("기록이 완료되었습니다")
            } else {
                self.view.makeToast(err?.localizedDescription)
            }
        }
    }
    @IBOutlet weak var recognizeButton: UIButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(name)적 능력 관찰"
        typeLabel.text = "아이의 \(name)적 능력이 어떤 것 같나요?"
    
        requestSpeechAuthorization()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        
        findTextField.isHidden = true
        
        switch name {
        case "신체": findTextField.placeholder = "ex) 손 움직임, 화면 조작, 음성 속도"
        case "시각": findTextField.placeholder = "ex) 카드 크기, 화면 밝기"
        default: findTextField.placeholder = "ex) 홈화면 종류, 카테고리"
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
