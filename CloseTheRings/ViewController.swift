//
//  ViewController.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 10/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit
import HealthKitUI
import AVFoundation
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var ringView: HKActivityRingView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var date = Date()
    
    @IBOutlet weak var videoButton: RoundedButton!
    @IBOutlet weak var gifButton: RoundedButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadingLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayRing()
        setDateLabel()
        clearTmpDir()
        checkTip()
    }
    
    @IBOutlet weak var tipHeart: UILabel!
    
    func checkTip() {
        tipHeart.alpha = 0
        guard let tipAmountString = KeychainSwift().get(kTipAmount) else {
            return
        }
        guard let tipDouble = Double(tipAmountString) else {
            return
        }
        if tipDouble > 0 {
            self.tipHeart.alpha = 1
        }
    }
    
    func displayRing() {
        HealthManager.main.getPermission { (success, error) in
            if success {
                HealthManager.main.getTodayRing(date: self.date ,completion: { (summary) in
                    self.ringView.setActivitySummary(summary, animated: true)
                    self.setPercentages()
                })
            }
        }
    }
    
    @IBAction func dateButtonTapped(_ sender: Any) {
        SoundManager.playPop()
        DatePickerDialog().show("Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.date, minimumDate: nil, maximumDate: Date(), datePickerMode: .date) { (date) in
            if let dt = date {
                self.date = dt
                self.displayRing()
                self.setDateLabel()
            }
        }
    
        
    }
    
    func setPercentages() {
//        if UserDefaults.standard.bool(forKey: "EnablePercent") {
            let percentFormatter            = NumberFormatter()
            percentFormatter.numberStyle    = .percent
            percentFormatter.multiplier     = 100
            percentFormatter.minimumFractionDigits = 0
            percentFormatter.maximumFractionDigits = 0
            percentFormatter.percentSymbol = " %"
            DispatchQueue.main.async { [unowned self] in
                self.redLabel.text = percentFormatter.string(for: HealthManager.main.energyProgress)
                self.greenLabel.text =  percentFormatter.string(for: HealthManager.main.exerciseProgress)
                self.blueLabel.text = "\(Int(HealthManager.main.standProgress)) hr"
            }
//        } else {
//            DispatchQueue.main.async { [unowned self] in
//                self.redLabel.text = ""
//                self.greenLabel.text = ""
//                self.blueLabel.text = ""
//            }
//        }
        
    }
    
    func setDateLabel() {
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = DateFormatter.Style.medium
        
        let now = dateformatter.string(from: date)
        
        dateLabel.text = now
    }
    
    func recordingState(enter: Bool, generating: String = "Video") {
//        UIView.animate(withDuration: 0.4) {
            if enter {
                self.gifButton.alpha = 0.1
                self.videoButton.alpha  = 0.1
                self.calendarButton.alpha = 0.1
                self.activitySpinner.startAnimating()
                self.loadingLabel.text = "Generating \(generating)..."
                self.infoButton.alpha = 0.1
                
                self.gifButton.isUserInteractionEnabled = false
                self.videoButton.isUserInteractionEnabled = false
                self.calendarButton.isUserInteractionEnabled = false
                self.infoButton.isUserInteractionEnabled = false
                self.tipHeart.alpha = 0
            } else {
                self.gifButton.alpha = 1.0
                self.videoButton.alpha  = 1.0
                self.calendarButton.alpha = 1.0
                self.activitySpinner.stopAnimating()
                self.loadingLabel.text = ""
                self.infoButton.alpha = 1.0
                
                self.gifButton.isUserInteractionEnabled = true
                self.videoButton.isUserInteractionEnabled = true
                self.calendarButton.isUserInteractionEnabled = true
                self.infoButton.isUserInteractionEnabled = true
                checkTip()
            }
//        }
        
    }
    
    
    @IBAction func gifButtonTapped(_ sender: Any) {
        SoundManager.playPop()
        recordingState(enter: true, generating: "GIF")
        let glimpse = Glimpse()
        let time = Int(HealthManager.main.time)
        if time > 5 {
            glimpse.glimpseFramesPerSecond = 15
        } else {
            glimpse.glimpseFramesPerSecond = 30
        }
        containerView.layer.borderColor = UIColor.clear.cgColor
        HealthManager.main.getTodayRing(date: self.date, completion: { (summary) in
            DispatchQueue.main.async { [unowned self] in
                glimpse.startRecording(self.containerView) { (url) in
                    
                    let frameCount = 60
                    let delayTime  = Float(0.06)
                    
                    Regift.createGIFFromSource(url!, frameCount: frameCount, delayTime: delayTime) { (result) in
                        DispatchQueue.main.async { [unowned self] in
                            
                            let items = [result!]
                            let shareable = UIActivityViewController(activityItems: items, applicationActivities: nil)
                            self.present(shareable, animated: true, completion: {
                                self.recordingState(enter: false)
                                SoundManager.playWhistle()
                            })
                            shareable.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                                if !completed {
                                    // User canceled
                                    return
                                }
                                // User completed activity
                                SKStoreReviewController.requestReview()
                                self.clearTmpDir()
                            }
                        }
                    }
                    
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(time), execute: {
                    glimpse.stop()
                })
                self.ringView.setActivitySummary(nil, animated: false)
                self.ringView.setActivitySummary(summary, animated: true)
                
            }
            
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        SoundManager.playPop()
        recordingState(enter: true, generating: "Video")
        let glimpse = Glimpse()
        let time = Int(HealthManager.main.time)
        if time > 5 {
            glimpse.glimpseFramesPerSecond = 15
        } else {
            glimpse.glimpseFramesPerSecond = 30
        }
        containerView.layer.borderColor = UIColor.clear.cgColor
        HealthManager.main.getTodayRing(date: self.date, completion: { (summary) in
            DispatchQueue.main.async { [unowned self] in
                glimpse.startRecording(self.containerView) { (url) in

                    DispatchQueue.main.async { [unowned self] in
                        let items = [url!]
                        let shareable = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(shareable, animated: true, completion: {
                            self.recordingState(enter: false)
                            SoundManager.playWhistle()
                        })
                        shareable.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                            if !completed {
                                // User canceled
                                return
                            }
                            // User completed activity
                            SKStoreReviewController.requestReview()
                            self.clearTmpDir()
                        }
                    }
                    
                    
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(time), execute: {
                    glimpse.stop()
                })
                self.ringView.setActivitySummary(nil, animated: false)
                self.ringView.setActivitySummary(summary, animated: true)
                
            }
            
        })
        
    }
    
//    SKStoreReviewController.requestReview()
    
    func clearTmpDir(){
        
        var removed: Int = 0
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print("\(tmpFiles.count) temporary files found")
            for url in tmpFiles {
                removed += 1
                try FileManager.default.removeItem(at: url)
            }
            print("\(removed) temporary files removed")
        } catch {
            print(error)
            print("\(removed) temporary files removed")
        }
    }
    
    @IBAction func unwindToVC(segue:UIStoryboardSegue) { }
    
    

}





