//
//  InfoViewController.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 11/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit
import StoreKit

let kTipAmount = "PurchasedTipAmount"

class InfoViewController: UIViewController {
    
    let productIdentifier = "com.patmurraydev.CloseTheRings.Tip"
    var product : SKProduct?

    @IBOutlet weak var tipButton: RoundedButton!
    @IBOutlet weak var madeByLabel: UILabel!
    @IBOutlet weak var totalTippedLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    @IBAction func tipButtonTapped(_ sender: Any) {
        setSpinner()
        self.purchase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setSpinner()
        self.getProducts()
        loadTipThanks()
    }
    
    func setSpinner()  {
        self.tipButton.setTitle("", for: .normal)
        self.tipButton.isUserInteractionEnabled = false
        self.spinner.startAnimating()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewAppsTapped(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/us/developer/patrick-murray/id406128112?uo=4"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func nameTapped(_ sender: Any) {
        if let url = URL(string: "https://patmurray.co"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getProducts()  {
        
        loadTipThanks()
        
        self.spinner.startAnimating()
        
        var productIdentifiers = Set<ProductIdentifier>()
        
        productIdentifiers.insert(productIdentifier)
        
        IAP.requestProducts(productIdentifiers) { (response, error) in
            if let products = response?.products, !products.isEmpty {
                // Get the valid products
                for product in products {
                    if product.productIdentifier == self.productIdentifier {
                        self.setProduct(product: product)
                        return;
                    }
                }
            } else if let invalidProductIdentifiers = response?.invalidProductIdentifiers {
                // Some products id are invalid
                print(invalidProductIdentifiers)
            } else {
                // Some error happened
            }
        }
        
    }
    func setProduct(product: SKProduct) {
        self.product = product
        DispatchQueue.main.async { [unowned self] in
            self.tipButton.setTitle("Tip for \(product.localizedPrice() ?? "$\(product.price)")", for: .normal)
            self.spinner.stopAnimating()
            self.tipButton.isUserInteractionEnabled = true
        }
        
    }
    
    func purchase() {
        IAP.purchaseProduct(productIdentifier, handler: { (productIdentifier, error) in
            if let identifier = productIdentifier {
                // The product of 'productIdentifier' purchased.
                self.purchaseSuccess()
                print(identifier)
            }
        })
    }
    
    func purchaseSuccess() {
        if let price = product?.price {
            self.saveTip(amount: price)
        }
        self.getProducts()
    }
    
    func saveTip(amount: NSNumber) {
        guard let tipAmountString = KeychainSwift().get(kTipAmount) else {
            KeychainSwift().set(amount.stringValue, forKey: kTipAmount)
            return
        }
        guard let amountDouble = Double(tipAmountString) else {
            return
        }
        let finalAmount = amountDouble + amount.doubleValue
        KeychainSwift().set(String(format:"%f", finalAmount), forKey: kTipAmount)
        loadTipThanks()
    }
    
    func loadTipThanks() {
        guard let tipAmountString = KeychainSwift().get(kTipAmount) else {
            totalTippedLabel.text = ""
            return
        }
        
        guard let amountDouble = Double(tipAmountString) else {
            totalTippedLabel.text = ""
            return
        }
        
        let amountNumber = NSNumber(value: amountDouble)
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        guard let numberString = formatter.string(from: amountNumber) else {
            totalTippedLabel.text = ""
            return
        }
        
        
        totalTippedLabel.text = "You have tipped a total of \(numberString) 🧡"
        
        
    }
    

    

}
