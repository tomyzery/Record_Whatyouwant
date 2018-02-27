//
//  button.swift
//  RecordApp0124
//
//  Created by 방문사용자 on 2018. 2. 4..
//  Copyright © 2018년 seok. All rights reserved.
//

import Foundation
import AVKit



struct ButtonInfo {
    
    var button : UIButton
    var xpos : Int
    var ypos : Int
    var mark_number : Int
    var pageNum : Int
    
    
    init(button : UIButton, xpos : Int, ypos : Int, mark_number : Int, pageNum : Int){
        self.button = button
        self.mark_number = mark_number
        self.xpos = xpos
        self.ypos = ypos
        self.pageNum = pageNum

    }

}
