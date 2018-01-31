//
//  Board.swift
//  wekanBoardsiOS
//
//  Created by Guillaume on 31/01/2018.
//

import UIKit

class Board: NSObject {

    var id: String
    var name: String
    var usersId = [String]()
    
    required init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
