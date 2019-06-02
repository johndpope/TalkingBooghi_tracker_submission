//
//  DashboardViewController.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 03/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import UIKit
import Charts
import BetterSegmentedControl
import Firebase
import CodableFirebase
import RevealingSplashView

class DashboardViewController: UIViewController {
    
    var db: Firestore!
    
    let dateFormatter : DateFormatter = DateFormatter()
    
    var totalEntries: [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0),ChartDataEntry(x: 1, y: 0),ChartDataEntry(x: 2, y: 0),ChartDataEntry(x: 3, y: 0),ChartDataEntry(x: 4, y: 0)]
    var totalEntriesDone = [false,false,false,false,false]
    
    var todayEntries = [BarChartDataEntry(x: 0, y: 0),BarChartDataEntry(x: 1, y: 0),BarChartDataEntry(x: 2, y: 0)]
    
    var caregiversBarEntries = [BarChartDataEntry(x: 0, y: 0), BarChartDataEntry(x: 1, y: 0), BarChartDataEntry(x: 2, y: 0), BarChartDataEntry(x: 3, y: 0), BarChartDataEntry(x: 4, y: 0)]
    var caregiversGoodEntries = [ChartDataEntry(x: 0, y: 0), ChartDataEntry(x: 1, y: 0), ChartDataEntry(x: 2, y: 0), ChartDataEntry(x: 3, y: 0), ChartDataEntry(x: 4, y: 0)]
    var caregiversBadEntries = [ChartDataEntry(x: 0, y: 0), ChartDataEntry(x: 1, y: 0), ChartDataEntry(x: 2, y: 0), ChartDataEntry(x: 3, y: 0), ChartDataEntry(x: 4, y: 0)]
    
    @objc func mainSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        populateRecent(Int(mainSegmentControl!.index))
    }
    @objc func observeSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        populateCaregivers(Int(observeSegmentControl!.index))
    }
    
    @IBOutlet weak var view1: UIView! {
        didSet {
            view1.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var view2: UIView! {
        didSet {
            view2.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var view3: UIView! {
        didSet {
            view3.layer.cornerRadius = 15
        }
    }
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_launch")!, iconInitialSize: CGSize(width: 240, height: 166), backgroundImage: UIImage(named: "main")!)
    
    func setupViews() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        revealingSplashView.startAnimation()
    }
    
    @IBOutlet weak var mainSegmentControl: BetterSegmentedControl! {
        didSet {
            mainSegmentControl.segments = LabelSegment.segments(withTitles: ["일별", "주별", "월별"], normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            mainSegmentControl.setIndex(0)
            mainSegmentControl.addTarget(self, action: #selector(self.mainSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    @IBOutlet weak var observeSegmentControl: BetterSegmentedControl! {
        didSet {
            observeSegmentControl.segments = LabelSegment.segments(withTitles: ["일별", "주별", "월별"], normalBackgroundColor: UIColor.clear, normalFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), normalTextColor: .white, selectedBackgroundColor: .white, selectedFont: UIFont.systemFont(ofSize: 14.0, weight: .bold), selectedTextColor: .white)
            observeSegmentControl.setIndex(0)
            observeSegmentControl.addTarget(self, action: #selector(self.observeSegmentedControlValueChanged(_:)), for: .valueChanged)
        }
    }
    
    
    @IBOutlet weak var progressChartView: CombinedChartView! {
        didSet {
            progressChartView.layer.masksToBounds = false
            progressChartView.clipsToBounds = false
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var todayView: BarChartView!
    @IBOutlet weak var caregiversChart: CombinedChartView! {
        didSet {
            caregiversChart.layer.masksToBounds = false
            caregiversChart.clipsToBounds = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        db = Firestore.firestore()
        
        setupViews()
        
        setBadge(self, db)

        let image = UIImage(named: "NavLogo_eng")!
        let imageView = UIImageView(image: image)
        let bannerWidth = navigationController!.navigationBar.frame.size.width
        let bannerHeight = navigationController!.navigationBar.frame.size.height
        navigationController!.navigationBar.tintColor = UIColor.white
        imageView.frame = CGRect(x: 0, y: 0, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        setupCombinedChart(Int(mainSegmentControl!.index))
        setupTodayChart()
        setupCaregiversChart(0)
        populateToday()
        populateRecent(Int(mainSegmentControl!.index))
        populateCaregivers(Int(mainSegmentControl!.index))
        
        let firstHeight = (view1.frame.width-20)*347/394
        
        scrollView.contentSize.height = firstHeight * 4 + 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateToday()
        populateRecent(Int(mainSegmentControl!.index))
        populateCaregivers(Int(mainSegmentControl!.index))
        
        setBadge(self, db)
    }
    
    func setupTodayChart() {
        
        todayView.chartDescription?.enabled = false
        todayView.drawGridBackgroundEnabled = false
        todayView.drawBordersEnabled = false
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.minimumIntegerDigits = 1
        leftAxisFormatter.negativeSuffix = " %"
        leftAxisFormatter.positiveSuffix = " %"
        
        let leftAxis = todayView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 15, weight: .semibold)
        leftAxis.labelTextColor = UIColor.white
        leftAxis.labelCount = 5
        leftAxis.labelPosition = .outsideChart
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.gridColor = .clear
        
        todayView.rightAxis.enabled = false
        
        let xAxis = todayView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 15, weight: .semibold)
        xAxis.labelTextColor = UIColor.white
        xAxis.gridColor = .clear
        xAxis.labelCount = 3
        xAxis.granularityEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["대상+행동", "요구하기", "경험 나누기"])
        xAxis.granularity = 1
        
        todayView.pinchZoomEnabled = false
        todayView.doubleTapToZoomEnabled = false
        todayView.legend.enabled = false
        
        
        let dataSet = BarChartDataSet(values: todayEntries, label: "")
        
        let valueFormatter = NumberFormatter()
        valueFormatter.positiveSuffix = "%"
        valueFormatter.maximumFractionDigits = 0
        
        dataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        dataSet.valueFont = .systemFont(ofSize: 15, weight: .semibold)
        dataSet.valueTextColor = UIColor.white
        
        dataSet.colors = [UIColor.white]
        todayView.data = BarChartData(dataSet: dataSet)
        
        todayView.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
    }
    
    func setupCombinedChart(_ type: Int) {
        
        progressChartView.chartDescription?.enabled = false
        progressChartView.drawGridBackgroundEnabled = false
        progressChartView.drawBordersEnabled = false
        
        
        let leftAxis = progressChartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 15, weight: .semibold)
        leftAxis.labelTextColor = UIColor.white
        leftAxis.labelCount = 5
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0
        leftAxis.gridColor = .clear
        
        progressChartView.rightAxis.enabled = false
        
        progressChartView.pinchZoomEnabled = false
        progressChartView.doubleTapToZoomEnabled = false
        progressChartView.legend.enabled = false
        
        let xAxis = progressChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 13, weight: .semibold)
        xAxis.labelTextColor = UIColor.white
        xAxis.gridColor = .lightGray
        xAxis.labelCount = 5
        xAxis.granularityEnabled = true
        
        switch type {
        case 0:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4일 전", "3일 전", "2일 전", "1일 전", "오늘"])
        case 1:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4주 전", "3주 전", "2주 전", "1주 전", "이번 주"])
        default:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4개월 전", "3개월 전", "2개월 전", "1개월 전", "이번 달"])
            
        }
        
        xAxis.granularity = 1
        
        
        let dataSet = LineChartDataSet(values: totalEntries, label: "")
        dataSet.lineDashLengths = [5, 2.5]
        dataSet.highlightLineDashLengths = [5, 2.5]
        dataSet.setColor(UIColor.white)
        dataSet.lineWidth = 5
        dataSet.drawCirclesEnabled = false
        dataSet.valueFont = .systemFont(ofSize: 9)
        dataSet.formLineDashLengths = [5, 2.5]
        dataSet.formLineWidth = 1
        dataSet.formSize = 15
        dataSet.fillAlpha = 1
        dataSet.fill = Fill(CGColor: UIColor.white.cgColor)
        dataSet.drawFilledEnabled = false
        
        let valueFormatter = NumberFormatter()
        valueFormatter.maximumFractionDigits = 0
        
        dataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        dataSet.valueFont = .systemFont(ofSize: 15, weight: .semibold)
        dataSet.valueTextColor = UIColor.white
        
        
        let data = CombinedChartData()
        
        data.lineData = LineChartData(dataSet: dataSet)
        
        progressChartView.data = data
        
        progressChartView.leftAxis.axisMaximum = data.yMax + 5
        
        if data.yMin >= 5 {
            progressChartView.leftAxis.axisMinimum = data.yMin - 4
        }
        
        progressChartView.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
    }
    
    func setupCaregiversChart(_ type: Int) {
        caregiversChart.chartDescription?.enabled = false
        caregiversChart.drawGridBackgroundEnabled = false
        caregiversChart.drawBordersEnabled = false
        
        let leftAxis = caregiversChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 15, weight: .semibold)
        leftAxis.labelTextColor = UIColor.white
        leftAxis.labelCount = 5
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0
        leftAxis.gridColor = .clear
        
        caregiversChart.rightAxis.enabled = false
        
        caregiversChart.pinchZoomEnabled = false
        caregiversChart.doubleTapToZoomEnabled = false
        caregiversChart.legend.enabled = false
        
        let xAxis = caregiversChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 13, weight: .semibold)
        xAxis.labelTextColor = UIColor.white
        xAxis.gridColor = .lightGray
        xAxis.labelCount = 5
        xAxis.granularityEnabled = false
        
        switch type {
        case 0:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4일 전", "3일 전", "2일 전", "1일 전", "오늘"])
        case 1:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4주 전", "3주 전", "2주 전", "1주 전", "이번 주"])
        default:
            xAxis.valueFormatter = IndexAxisValueFormatter(values: ["4개월 전", "3개월 전", "2개월 전", "1개월 전", "이번 달"])
            
        }
        
        
        xAxis.granularity = 1
        
        let caregiversDataSet = BarChartDataSet(values: caregiversBarEntries, label: "")
        
        
        
        let valueFormatter = NumberFormatter()
        valueFormatter.maximumFractionDigits = 0
        
        caregiversDataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        caregiversDataSet.valueFont = .systemFont(ofSize: 15, weight: .semibold)
        caregiversDataSet.valueTextColor = UIColor.white
        caregiversDataSet.colors = [UIColor.white]
        
        
        let caregiversGoodDataSet = LineChartDataSet(values: caregiversGoodEntries, label: "")
        caregiversGoodDataSet.lineDashLengths = [5, 2.5]
        caregiversGoodDataSet.highlightLineDashLengths = [5, 2.5]
        caregiversGoodDataSet.setColor(UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1))
        caregiversGoodDataSet.lineWidth = 5
        caregiversGoodDataSet.drawCirclesEnabled = false
        caregiversGoodDataSet.valueFont = .systemFont(ofSize: 9)
        caregiversGoodDataSet.formLineDashLengths = [5, 2.5]
        caregiversGoodDataSet.formLineWidth = 1
        caregiversGoodDataSet.formSize = 15
        caregiversGoodDataSet.fillAlpha = 1
        caregiversGoodDataSet.fill = Fill(CGColor: UIColor.white.cgColor)
        caregiversGoodDataSet.drawFilledEnabled = false
        
        
        caregiversGoodDataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        caregiversGoodDataSet.valueFont = .systemFont(ofSize: 0, weight: .semibold)
        caregiversGoodDataSet.valueTextColor = UIColor.white
        
        
        
        let caregiversBadDataSet = LineChartDataSet(values: caregiversBadEntries, label: "")
        caregiversBadDataSet.lineDashLengths = [5, 2.5]
        caregiversBadDataSet.highlightLineDashLengths = [5, 2.5]
        caregiversBadDataSet.setColor(UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1))
        caregiversBadDataSet.lineWidth = 5
        caregiversBadDataSet.drawCirclesEnabled = false
        caregiversBadDataSet.valueFont = .systemFont(ofSize: 9)
        caregiversBadDataSet.formLineDashLengths = [5, 2.5]
        caregiversBadDataSet.formLineWidth = 1
        caregiversBadDataSet.formSize = 15
        caregiversBadDataSet.fillAlpha = 1
        caregiversBadDataSet.fill = Fill(CGColor: UIColor.white.cgColor)
        caregiversBadDataSet.drawFilledEnabled = false
        
        
        caregiversBadDataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
        caregiversBadDataSet.valueFont = .systemFont(ofSize: 0, weight: .semibold)
        caregiversBadDataSet.valueTextColor = UIColor.white
        
        let data = CombinedChartData()
        
        data.lineData = LineChartData(dataSets: [caregiversGoodDataSet, caregiversBadDataSet])
        data.barData = BarChartData(dataSet: caregiversDataSet)
        
        caregiversChart.data = data
        
        caregiversChart.leftAxis.axisMaximum = data.yMax + 5
        
        if data.yMin >= 5 {
            caregiversChart.leftAxis.axisMinimum = data.yMin - 4
        }
        
        caregiversChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
    }
    
    func populateRecent(_ type: Int) {
        totalEntriesDone = [false,false,false,false,false]
        switch type {
        case 2:
            db.collection("\(experimentID)_usage").whereField("month", isEqualTo: String(Date().month)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[4] = ChartDataEntry(x: 4, y: Double(todayNum))
                    self.totalEntriesDone[4] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("month", isEqualTo: String(Date().month-1)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[3] = ChartDataEntry(x: 3, y: Double(todayNum))
                    self.totalEntriesDone[3] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("month", isEqualTo: String(Date().month-2)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[2] = ChartDataEntry(x: 2, y: Double(todayNum))
                    self.totalEntriesDone[2] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("month", isEqualTo: String(Date().month-3)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[1] = ChartDataEntry(x: 1, y: Double(todayNum))
                    self.totalEntriesDone[1] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("month", isEqualTo: String(Date().month-4)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[0] = ChartDataEntry(x: 0, y: Double(todayNum))
                    self.totalEntriesDone[0] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
        case 1:
            db.collection("\(experimentID)_usage").whereField("weekofyear", isEqualTo: String(Date().week)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[4] = ChartDataEntry(x: 4, y: Double(todayNum))
                    self.totalEntriesDone[4] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("weekofyear", isEqualTo: String(Date().week-1)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[3] = ChartDataEntry(x: 3, y: Double(todayNum))
                    self.totalEntriesDone[3] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("weekofyear", isEqualTo: String(Date().week-2)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[2] = ChartDataEntry(x: 2, y: Double(todayNum))
                    self.totalEntriesDone[2] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("weekofyear", isEqualTo: String(Date().week-3)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[1] = ChartDataEntry(x: 1, y: Double(todayNum))
                    self.totalEntriesDone[1] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("weekofyear", isEqualTo: String(Date().week-4)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[0] = ChartDataEntry(x: 0, y: Double(todayNum))
                    self.totalEntriesDone[0] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
        default:
            db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date())).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[4] = ChartDataEntry(x: 4, y: Double(todayNum))
                    self.totalEntriesDone[4] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date.yesterday)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[3] = ChartDataEntry(x: 3, y: Double(todayNum))
                    self.totalEntriesDone[3] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date.yesterday.dayBefore)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[2] = ChartDataEntry(x: 2, y: Double(todayNum))
                    self.totalEntriesDone[2] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[1] = ChartDataEntry(x: 1, y: Double(todayNum))
                    self.totalEntriesDone[1] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
            db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore.dayBefore)).getDocuments { (snapshot, error) in
                if error == nil {
                    let todayNum = snapshot!.documents.count
                    self.totalEntries[0] = ChartDataEntry(x: 0, y: Double(todayNum))
                    self.totalEntriesDone[0] = true
                    if self.totalEntriesDone == [true,true,true,true,true] {
                        self.setupCombinedChart(Int(self.mainSegmentControl!.index))
                    }
                }
            }
        }
    }
    
    func populateToday() {
        db.collection("\(experimentID)_usage").whereField("date", isEqualTo: dateFormatter.string(from: Date())).getDocuments { (snapshot, err) in
            self.todayEntries = [BarChartDataEntry(x: 0, y: 0),BarChartDataEntry(x: 2, y: 0),BarChartDataEntry(x: 2, y: 0)]
            var defaultNum = 0
            var routineNum = 0
            var sortedNum = 0
            for item in snapshot!.documents {
                let instance = try! FirestoreDecoder().decode(Record.self, from: item.data())
                switch instance.cardtype
                {
                case "default":
                    defaultNum += 1
                case "routine":
                    routineNum += 1
                default:
                    sortedNum += 1
                }
            }
            print(defaultNum)
            print(routineNum)
            print(sortedNum)
            let tot = defaultNum + routineNum + sortedNum
            if tot != 0 {
                self.todayEntries = [BarChartDataEntry(x: 0, y: Double(defaultNum)/Double(tot)*100), BarChartDataEntry(x: 1, y: Double(sortedNum)/Double(tot)*100), BarChartDataEntry(x: 2, y: Double(routineNum)/Double(tot)*100)]
                print(self.todayEntries)
            }
            self.setupTodayChart()
        }
    }
    func populateCaregivers(_ type: Int) {
        var totalArray = [Intervention]()
        db.collection("\(experimentID)_intervention").getDocuments { (snapshot, error) in
            if error == nil {
                totalArray = []
                for item in snapshot!.documents {
                    let instance = try! FirestoreDecoder().decode(Intervention.self, from: item.data())
                    totalArray.append(instance)
                }
                switch type {
                case 0:
                    let fourdaysago = totalArray.filter({$0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore.dayBefore)}).count
                    let threedaysago = totalArray.filter({$0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore)}).count
                    let twodaysago = totalArray.filter({$0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore)}).count
                    let yesterday = totalArray.filter({$0.date == self.dateFormatter.string(from: Date.yesterday)}).count
                    let today = totalArray.filter({$0.date == self.dateFormatter.string(from: Date())}).count
                    let fourdaysagogood = totalArray.filter({$0.isGood == true && $0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore.dayBefore)}).count
                    let threedaysagogood = totalArray.filter({$0.isGood == true && $0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore.dayBefore)}).count
                    let twodaysagogood = totalArray.filter({$0.isGood == true && $0.date == self.dateFormatter.string(from: Date.yesterday.dayBefore)}).count
                    let yesterdaygood = totalArray.filter({$0.isGood == true && $0.date == self.dateFormatter.string(from: Date.yesterday)}).count
                    let todaygood = totalArray.filter({$0.isGood == true && $0.date == self.dateFormatter.string(from: Date())}).count
                    
                    self.caregiversBarEntries = [BarChartDataEntry(x: 0, y: Double(fourdaysago)), BarChartDataEntry(x: 1, y: Double(threedaysago)), BarChartDataEntry(x: 2, y: Double(twodaysago)), BarChartDataEntry(x: 3, y: Double(yesterday)), BarChartDataEntry(x: 4, y: Double(today))]
                    self.caregiversGoodEntries = [ChartDataEntry(x: 0, y: Double(fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterdaygood)), ChartDataEntry(x: 4, y: Double(todaygood))]
                    self.caregiversBadEntries = [ChartDataEntry(x: 0, y: Double(fourdaysago - fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysago - threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysago - twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterday - yesterdaygood)), ChartDataEntry(x: 4, y: Double(today - todaygood))]
                case 1:
                    var fourdaysago = totalArray.filter({$0.weekofyear == String(Date().week-4)}).count
                    var threedaysago = totalArray.filter({$0.weekofyear == String(Date().week-3)}).count
                    var twodaysago = totalArray.filter({$0.weekofyear == String(Date().week-2)}).count
                    var yesterday = totalArray.filter({$0.weekofyear == String(Date().week-1)}).count
                    var today = totalArray.filter({$0.weekofyear == String(Date().week)}).count
                    var fourdaysagogood = totalArray.filter({$0.isGood == true && $0.weekofyear == String(Date().week-4)}).count
                    var threedaysagogood = totalArray.filter({$0.isGood == true && $0.weekofyear == String(Date().week-3)}).count
                    var twodaysagogood = totalArray.filter({$0.isGood == true && $0.weekofyear == String(Date().week-2)}).count
                    var yesterdaygood = totalArray.filter({$0.isGood == true && $0.month == String(Date().week-1)}).count
                    var todaygood = totalArray.filter({$0.isGood == true && $0.weekofyear == String(Date().week)}).count
                    
                    self.caregiversBarEntries = [BarChartDataEntry(x: 0, y: Double(fourdaysago)), BarChartDataEntry(x: 1, y: Double(threedaysago)), BarChartDataEntry(x: 2, y: Double(twodaysago)), BarChartDataEntry(x: 3, y: Double(yesterday)), BarChartDataEntry(x: 4, y: Double(today))]
                    self.caregiversGoodEntries = [ChartDataEntry(x: 0, y: Double(fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterdaygood)), ChartDataEntry(x: 4, y: Double(todaygood))]
                    self.caregiversBadEntries = [ChartDataEntry(x: 0, y: Double(fourdaysago - fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysago - threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysago - twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterday - yesterdaygood)), ChartDataEntry(x: 4, y: Double(today - todaygood))]
                default:
                    var fourdaysago = totalArray.filter({$0.month == String(Date().month-4)}).count
                    var threedaysago = totalArray.filter({$0.month == String(Date().month-3)}).count
                    var twodaysago = totalArray.filter({$0.month == String(Date().month-2)}).count
                    var yesterday = totalArray.filter({$0.month == String(Date().month-1)}).count
                    var today = totalArray.filter({$0.month == String(Date().month)}).count
                    var fourdaysagogood = totalArray.filter({$0.isGood == true && $0.month == String(Date().month-4)}).count
                    var threedaysagogood = totalArray.filter({$0.isGood == true && $0.month == String(Date().month-3)}).count
                    var twodaysagogood = totalArray.filter({$0.isGood == true && $0.month == String(Date().month-2)}).count
                    var yesterdaygood = totalArray.filter({$0.isGood == true && $0.month == String(Date().month-1)}).count
                    var todaygood = totalArray.filter({$0.isGood == true && $0.month == String(Date().month)}).count
                    
                    self.caregiversBarEntries = [BarChartDataEntry(x: 0, y: Double(fourdaysago)), BarChartDataEntry(x: 1, y: Double(threedaysago)), BarChartDataEntry(x: 2, y: Double(twodaysago)), BarChartDataEntry(x: 3, y: Double(yesterday)), BarChartDataEntry(x: 4, y: Double(today))]
                    self.caregiversGoodEntries = [ChartDataEntry(x: 0, y: Double(fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterdaygood)), ChartDataEntry(x: 4, y: Double(todaygood))]
                    self.caregiversBadEntries = [ChartDataEntry(x: 0, y: Double(fourdaysago - fourdaysagogood)), ChartDataEntry(x: 1, y: Double(threedaysago - threedaysagogood)), ChartDataEntry(x: 2, y: Double(twodaysago - twodaysagogood)), ChartDataEntry(x: 3, y: Double(yesterday - yesterdaygood)), ChartDataEntry(x: 4, y: Double(today - todaygood))]
                    
                }
                self.setupCaregiversChart(type)
                self.caregiversChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
            }
        }
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var week: Int {
        return Calendar.current.component(.weekOfYear,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

extension UIColor {
    static let tbColor = UIColor(red: 111/255.0, green: 112/255.0, blue: 119/255.0, alpha: 1)
}
