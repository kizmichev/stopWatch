//
//  ViewController.swift
//  stopWatch
//
//  Created by Кузьмичев Александр Михайлович on 6/3/2023.
//

import UIKit

protocol TimerAPIDelegate {
    func tickHandler(timePast: Int)
    func resetHandler()
}

class ViewController: UIViewController {
    private enum BtnState {
        case start
        case stop
        case lap
        case reset
    }
    
    public var delegate : TimerAPIDelegate?
    private var countTimer : Timer!
    @IBOutlet weak var rightButton: UIButton!
    private var timePast : Int = 0
    
    @IBOutlet weak var timeLabel: UILabel!
    private var rightBtnState = BtnState.start
    
    @IBOutlet weak var tableView: UITableView!
    private var data: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func onStart(_ sender: Any) {
        if rightBtnState == .start {
            if countTimer == nil {
                countTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
                    self.timePast += 1
                    self.delegate?.tickHandler(timePast: self.timePast)
                })
                
                RunLoop.current.add(countTimer, forMode: RunLoop.Mode.common)
                countTimer.fire()
            } else {
                countTimer.fireDate = Date.distantPast
            }
            
            rightBtnState = .stop
        } else if rightBtnState == .stop {
            self.reset()
            rightBtnState = .start
        }
        
        updateButtonUI()
    }
    
    @IBAction func onLapClick(_ sender: Any) {
        addItem(time: toFormatedTimeString(time: timePast))
    }
    
    func updateButtonUI() {
        if rightBtnState == .start {
            rightButton.setTitle("Start", for: .normal)
        } else if rightBtnState == .stop {
            rightButton.setTitle("Stop", for: .normal)
        }
    }
    
    public func reset() {
        if countTimer != nil {
            countTimer.invalidate()
            countTimer = nil
            timePast = 0
            delegate?.resetHandler()
        }
    }
}

extension ViewController: TimerAPIDelegate {
    func toFormatedTimeString(time: Int) -> String{
        let milSec = time % 100
        let sec = (time / 100) % 60
        let min = (time / 6000) % 60
        
        let formatString = String(format: "%02d:%02d.%02d", min, sec, milSec)
       
        return formatString
    }
    
    func tickHandler(timePast: Int) {
        self.timeLabel.text = toFormatedTimeString(time: timePast)
    }
    
    func resetHandler() {
        self.timeLabel.text = toFormatedTimeString(time: 0)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func addItem(time:String){
        data.append(time)
        tableView.reloadData()
    }
    
}
