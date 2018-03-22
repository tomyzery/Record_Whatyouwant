//
//  File.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 3. 6..
//  Copyright © 2018년 seok. All rights reserved.
//


import Foundation


struct audioinfo {
    
    var firsttime : String
    var lasttime : String
    var nameMp3 : String
    
    init(firsttime: String, lasttime: String, nameMp3: String) {
        self.firsttime = firsttime
        self.lasttime = lasttime
        self.nameMp3 = nameMp3
    }
    
    static var selected : String = ""
}








