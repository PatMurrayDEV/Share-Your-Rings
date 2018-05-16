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
    
    var time = 4.0
    
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
    
    
    func getTodayRing(date: Date = Date(), completion: @escaping (HKActivitySummary?) -> Swift.Void)  {
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
                    completion(nil)
                    return
            }
            
            let summary = summaries[0]
            self.calcTime(with: summary)
            completion(summary)
            
            
            
            
            
        }
        
        healthStore.execute(query)
        
    }
    
    func calcTime(with summary: HKActivitySummary) {
        let energyUnit   = HKUnit.jouleUnit(with: .kilo)
        let standUnit    = HKUnit.count()
        let exerciseUnit = HKUnit.second()

        let energy   = summary.activeEnergyBurned.doubleValue(for: energyUnit)
        let stand    = summary.appleStandHours.doubleValue(for: standUnit)
        let exercise = summary.appleExerciseTime.doubleValue(for: exerciseUnit)

        let energyGoal   = summary.activeEnergyBurnedGoal.doubleValue(for: energyUnit)
        let standGoal    = summary.appleStandHoursGoal.doubleValue(for: standUnit)
        let exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: exerciseUnit)

        let energyProgress   = energyGoal == 0 ? 0 : energy / energyGoal
        let standProgress    = standGoal == 0 ? 0 : stand / standGoal
        let exerciseProgress = exerciseGoal == 0 ? 0 : exercise / exerciseGoal


        let largest = max(max(energyProgress, standProgress), exerciseProgress)
//
        
//
        
        if largest > 5 {
            self.time = largest
        } else {
            let timeCalc = largest * 1.42
            self.time = timeCalc + 1

        }
        
//        self.time = 5
        
        self.energyProgress = energyProgress
        self.exerciseProgress = exerciseProgress
        self.standProgress = stand
        
    }
    
    var energyProgress   = 0.0
    var standProgress    = 0.0
    var exerciseProgress = 0.0
    
    
    
}
