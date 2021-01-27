//
//  Card.swift
//  Flashzilla
//
//  Created by Zaid Raza on 05/01/2021.
//  Copyright © 2021 Zaid Raza. All rights reserved.
//

import Foundation

struct Card: Codable{
    let prompt: String
    let answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    }
}
