//
//  UserDefaults.swift
//  TalkingBooghi_tracker
//
//  Created by Donghoon Shin on 20/04/2019.
//  Copyright © 2019 Donghoon Shin. All rights reserved.
//

import Foundation

var experimentID: String {
    get {
        return UserDefaults.standard.string(forKey: "experimentID") ?? "john"
    } set {
        UserDefaults.standard.set(newValue, forKey: "experimentID")
        UserDefaults.standard.synchronize()
    }
}
var experimentRole: String {
    get {
        return UserDefaults.standard.string(forKey: "role") ?? "부모"
    } set {
        UserDefaults.standard.set(newValue, forKey: "role")
        UserDefaults.standard.synchronize()
    }
}
