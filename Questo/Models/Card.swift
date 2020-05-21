//
//  Card.swift
//  Questo
//
//  Created by Taichi Kato on 5/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import ObjectMapper

class Card: Object, Mappable {
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        prompt <- map["question"]
        answer <- map["answer"]
    }

    @objc dynamic var repetition = 0
    
    @objc dynamic var interval = 0
    @objc dynamic var uuid: String? = nil
    @objc dynamic var nextDate = Date().timeIntervalSince1970 // the date in which this card should be recalled
    
    @objc dynamic var previousDate = Date().timeIntervalSince1970
    
    @objc dynamic var easinessFactor = 2.5
    @objc dynamic var maxQuality = 4
    
    @objc dynamic var prompt: String? = nil // front side of the card, clues
    @objc dynamic var answer: String? = nil // back side of the flashcard, what is being asked
    let distractors = List<String>()
    @objc dynamic var cardType = "default" // card type: default, mcq, gfq, conv
    
    let hasMastered = RealmOptional<Bool>() // Will be true if card was created manually

    let manuallyCreated = RealmOptional<Bool>() // Will be true if card was created manually
    let previousVersions = List<Card>() // Saving previous versions, or edit history
    
    let pastResults = List<Result>() // Details of past attempts at attempting this card
    
    func rateCard(rating: Rating) -> Card {
        if(rating == .good) { // 5 is "got it!" 🤘🏽
            return gradeFlashcard(card: self, cardGrade: 5, currentDatetime: Date().timeIntervalSince1970)
        } else if(rating == .bad) { // 0 is "need to review" 🤥
            return gradeFlashcard(card: self, cardGrade: 0, currentDatetime: Date().timeIntervalSince1970)
        } else {
            // THIS SHOULD NEVER HAPPEN BUT JUST IN CASE
            return self
        }
    }
    
    /// Grade Flash card
    /// - Parameters:
    ///   - card: Flashcard
    ///   - grade: Grade(0-5)
    ///   - currentDatetime: TimeInterval
    /// - Returns: Flashcard with new interval and repetition
    func gradeFlashcard(card: Card, cardGrade: Int, currentDatetime: TimeInterval) -> Card {
        if cardGrade < 3 {
            card.repetition = 0
            card.interval = 0
        } else {
            let qualityFactor = Double(maxQuality - cardGrade) // CardGrade.bright.rawValue - grade
            let newEasinessFactor = card.easinessFactor + (0.1 - qualityFactor * (0.08 + qualityFactor * 0.02))
            if newEasinessFactor < easinessFactor {
                card.easinessFactor = easinessFactor
            } else {
                card.easinessFactor = newEasinessFactor
            }
            card.repetition += 1
            switch card.repetition {
            case 1:
                card.interval = 1
            case 2:
                card.interval = 6
            default:
                let newInterval = ceil(Double(card.repetition - 1) * card.easinessFactor)
                card.interval = Int(newInterval)
            }
        }
        if cardGrade == 3 {
            card.interval = 0
        }
        let seconds = 60
        let minutes = 60
        let hours = 24
        let dayMultiplier = seconds * minutes * hours
        let extraDays = dayMultiplier * card.interval
        let newNextDatetime = currentDatetime + Double(extraDays)
        card.previousDate = card.nextDate
        card.nextDate = newNextDatetime
        if easinessFactor > 3 { // 3 is the threshold for mastery 🗿
            card.hasMastered.value = true
        }
        return card
    }
}

enum Rating {
    case good
    case bad
}
