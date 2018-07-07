//
//  IntroViewController.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 11/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var grantPermissionButton: RoundedButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stackView.alpha = 0
        stackView.isUserInteractionEnabled = false
        grantPermissionButton.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func grantPermissionButtonTapped(_ sender: Any) {
        SoundManager.playPop()
        HealthManager.main.getPermission { (success, error) in
            if success {
                HealthManager.main.setPermission()
                DispatchQueue.main.async { [unowned self] in
                    SoundManager.playWhistle()
                    self.performSegue(withIdentifier: "startApp", sender: self)
                }
            } else {
                
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let status = HealthManager.main.checkPermission()
        
        if !status {
            performAnimation(transition: false)
            self.showPermissions()
        } else {
            performAnimation(transition: true)
        }
        
    }
    
    func showPermissions() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
            self.stackView.alpha = 1
            self.stackView.isUserInteractionEnabled = true
            self.grantPermissionButton.isUserInteractionEnabled = true
        }) { (completed) in
            
        }
    }
    
    func performAnimation(transition: Bool) {
        self.leadingConstraint.constant = -100
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
            self.view.layoutIfNeeded()
            self.imageView.alpha = 0.0
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }) { (completed) in
            if transition {
                self.performSegue(withIdentifier: "startApp", sender: self)
            }
        }
    }



}
