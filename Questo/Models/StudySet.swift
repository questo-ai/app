//
//  StudySet.swift
//  Questo
//
//  Created by Taichi Kato on 5/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import ObjectMapper_Realm
class StudySet: Object, Mappable {
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        id <-  (map["id"])
        title <-  (map["title"])
        subject <-  (map["subject"])
        cards <- (map["quiz"], ListTransform<Card>())
    }
    
    @objc dynamic var title: String? = nil
    @objc dynamic var subject: String? = nil
    @objc dynamic var author: String? = nil
    @objc dynamic var id: String? = nil
    @objc dynamic var dateCreated: Date? = nil
    var cards = List<Card>()
    func getCardsForToday() -> List<Card>{
        let today🤘 = List<Card>()
        for card in cards {
            if card.nextDate < Date().timeIntervalSince1970 {
                today🤘.append(card)
            }
        }
        return today🤘
    }
}
