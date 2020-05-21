//
//  SM2Engine.swift
//  Questo
//
//  Created by Arya Vohra on 7/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import Foundation
import RealmSwift
public class SM2Engine {
    static let realm = try! Realm()
    static func masterSet() -> StudySet {
        let master = StudySet()
        let sets = realm.objects(StudySet.self).sorted(byKeyPath: "dateCreated", ascending: false)
        for set in sets{
            master.cards.append(objectsIn: set.getCardsForToday())
        }
        master.title = "Today's master set"
        master.author = "Questo AI"
        master.dateCreated = Date()
        master.subject = "All Subjects"
        return master
    }
}

