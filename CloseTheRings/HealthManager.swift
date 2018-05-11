//
//  HealthManager.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 10/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI

class HealthManager: NSObject {

    static let main = HealthManager()

    private let healthStore = HKHealthStore()
    
    func getPermission(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        let objectTypes: Set<HKObjectType> = [
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    func checkPermission() -> Bool {
        return UserDefaults.standard.bool(forKey: "AuthRequested")
    }
    
    func setPermission() {
        UserDefaults.standard.set(true, forKey: "AuthRequested")
    }
    
    
    func getTodayRing(date: Date = Date(), completion: @escaping (HKActivitySummary) -> Swift.Void)  {
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: date
        )
        
        // This line is required to make the whole thing work
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            guard let summaries = summaries, summaries.count > 0
                else {
                    // No data returned. Perhaps check for error
                    return
            }
            
            let summary = summaries[0]
            completion(summary)
            
        }
        
        healthStore.execute(query)
        
    }
    
    
    
}
