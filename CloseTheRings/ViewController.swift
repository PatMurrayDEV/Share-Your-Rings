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
    
    var date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        DatePickerDialog().show("Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
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
    
    
    @IBAction func gifButtonTapped(_ sender: Any) {
        let glimpse = Glimpse()
        containerView.layer.borderColor = UIColor.clear.cgColor
        HealthManager.main.getTodayRing(date: self.date, completion: { (summary) in
            DispatchQueue.main.async { [unowned self] in
                glimpse.startRecording(self.containerView) { (url) in
                    
                    let frameCount = 60
                    let delayTime  = Float(0.06)
                    
                    Regift.createGIFFromSource(url!, frameCount: frameCount, delayTime: delayTime) { (result) in
                        DispatchQueue.main.async { [unowned self] in
                            self.ringView.setActivitySummary(nil, animated: true)
                            let items = [result!]
                            let shareable = UIActivityViewController(activityItems: items, applicationActivities: nil)
                            self.present(shareable, animated: true, completion: nil)
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
        let glimpse = Glimpse()
        containerView.layer.borderColor = UIColor.clear.cgColor
        HealthManager.main.getTodayRing(date: self.date, completion: { (summary) in
            DispatchQueue.main.async { [unowned self] in
                glimpse.startRecording(self.containerView) { (url) in

                    DispatchQueue.main.async { [unowned self] in
                        self.ringView.setActivitySummary(nil, animated: true)
                        let items = [url!]
                        let shareable = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(shareable, animated: true, completion: nil)
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



