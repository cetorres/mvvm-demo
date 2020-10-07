//
//  Project.swift
//  FrameIOTest
//
//  Created by Carlos Torres on 9/24/20.
//

import Foundation

class Project: Codable {
    let id: Int
    let team: Team
    let name: String
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, team, name, updatedAt
    }

    init(id: Int, team: Team, name: String, updatedAt: Date) {
        self.id = id
        self.team = team
        self.name = name
        self.updatedAt = updatedAt
    }
}
