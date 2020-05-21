//
//  Result.swift
//  Questo
//
//  Created by Taichi Kato on 5/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
import RealmSwift
class Result: Object {
    let correct = RealmOptional<Bool>() // whether the user got the card right or not
    @objc dynamic var date:Date? = nil // when this result was recorded
    @objc dynamic var answerChoice:String? = nil // the value of answer which was chosen
}
