//
//  Team.swift
//  MVVMDemo
//
//  Created by Carlos Torres on 9/24/20.
//

import Foundation

class Team: Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id, name
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
