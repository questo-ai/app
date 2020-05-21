//
//  OperationExtensions.swift
//  Questo
//
//  Created by Taichi Kato on 5/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import Foundation
import RealmSwift
//Randomly shuffle contents of an Sequence
extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
extension UserDefaults {
    func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "HasAtLeastLaunchedOnce") {
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    func doneFirstLaunch(){
        UserDefaults.standard.set(true, forKey: "HasAtLeastLaunchedOnce")
    }
}
extension Date {
    func timeDifferenceWithNow() -> String {
        let msPerMinute: Double = 60
        let msPerHour: Double = msPerMinute * 60
        let msPerDay: Double = msPerHour * 24
        let msPerMonth: Double = msPerDay * 30
        let msPerYear: Double = msPerDay * 365
        
        let elapsed = self.timeIntervalSinceNow * -1
        if (elapsed < 0) {
            return "From the Future"
        }
        
        if (elapsed < 1000) {
            return "Just Now"
        }
        
        if (elapsed < msPerMinute) {
            return String(format: "%.0f", round(elapsed/1000)) + " seconds ago"
        }
            
        else if (elapsed < msPerHour) {
            return String(format: "%.0f", round(elapsed/msPerMinute)) + " minutes ago"
        }
            
        else if (elapsed < msPerDay ) {
            return String(format: "%.0f", round(elapsed/msPerHour )) + " hours ago"
        }
            
        else if (elapsed < msPerMonth) {
            return String(format: "%.0f", round(elapsed/msPerDay)) + " days ago"
        }
            
        else if (elapsed < msPerYear) {
            return String(format: "%.0f", round(elapsed/msPerMonth)) + " months ago"
        }
            
        else {
            return String(format: "%.0f", round(elapsed/msPerYear)) + " years ago"
        }
    }
}
