//
//  InfoViewController.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 11/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit


class InfoViewController: UIViewController {
   
    @IBOutlet weak var madeByLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewAppsTapped(_ sender: Any) {
        SoundManager.playPop()
        if let url = URL(string: "https://itunes.apple.com/us/developer/patrick-murray/id406128112?uo=4"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func nameTapped(_ sender: Any) {
        SoundManager.playPop()
        if let url = URL(string: "https://patmurray.co"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }


}
