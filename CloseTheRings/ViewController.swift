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
        clearTempFolder()
    }
    
    func displayRing() {
        HealthManager.main.getPermission { (success, error) in
            if success {
                HealthManager.main.getTodayRing(date: self.date ,completion: { (summary) in
                    self.ringView.setActivitySummary(summary, animated: true)
                })
            }
        }
    }
    
    @IBAction func dateButtonTapped(_ sender: Any) {
        
        DatePickerDialog().show("Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.date, minimumDate: nil, maximumDate: Date(), datePickerMode: .date) { (date) in
            if let dt = date {
                self.date = dt
                self.displayRing()
                self.setDateLabel()
            }
        }
    
        
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
            }
//        }
        
    }
    
    
    @IBAction func gifButtonTapped(_ sender: Any) {
        recordingState(enter: true, generating: "GIF")
        let glimpse = Glimpse()
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
                            })
                        }
                    }
                    
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    glimpse.stop()
                })
                self.ringView.setActivitySummary(nil, animated: false)
                self.ringView.setActivitySummary(summary, animated: true)
                
            }
            
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        recordingState(enter: true, generating: "Video")
        let glimpse = Glimpse()
        containerView.layer.borderColor = UIColor.clear.cgColor
        HealthManager.main.getTodayRing(date: self.date, completion: { (summary) in
            DispatchQueue.main.async { [unowned self] in
                glimpse.startRecording(self.containerView) { (url) in

                    DispatchQueue.main.async { [unowned self] in
                        let items = [url!]
                        let shareable = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(shareable, animated: true, completion: {
                            self.recordingState(enter: false)
                        })
                    }
                    
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    glimpse.stop()
                })
                self.ringView.setActivitySummary(nil, animated: false)
                self.ringView.setActivitySummary(summary, animated: true)
                
            }
            
        })
        
    }
    
    func clearTempFolder() {
        let fileNameToDelete = "myFileName.txt"
        var filePath = ""
        
        // Fine documents directory on device
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + fileNameToDelete)
            print("Local path = \(filePath)")
            
        } else {
            print("Could not find local directory to store file")
            return
        }
        
        
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    

}



