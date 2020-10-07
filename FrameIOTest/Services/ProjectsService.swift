//
//  ProjectsService.swift
//  FrameIOTest
//
//  Created by Carlos Torres on 9/24/20.
//

import Foundation
import Alamofire

class ProjectsService {
    static let shared = ProjectsService()
    
    /// Get list of projects and teams serialized into array of models
    /// and in a dictionary like this [projects: [Project], teams: [Team]]
    func getProjectsAndTeams(completion: @escaping ((Result<[String: Any], Error>) -> Void)) {
          
        AF.request(API_URL, method: .get).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                let json = response.value as? Dictionary<String, Any>
                
                // Get list of teams from "included"
                var teams = [Team]()
                if let teamsList = json?["included"] as? [[String: Any]] {
                    teamsList.forEach { team in
                        let id = Int(team["id"] as? String ?? "0") ?? 0
                        let attributes = team["attributes"] as? [String: Any]
                        let name = attributes?["name"] as? String ?? ""
                        let teamObj = Team(id: id, name: name)
                        teams.append(teamObj)
                    }
                }
                
                // Get list of projects from the "data"
                var projects = [Project]()
                if let projectsList = json?["data"] as? [[String: Any]] {
                    projectsList.forEach { project in
                        let id = Int(project["id"] as? String ?? "0") ?? 0
                        let attributes = project["attributes"] as? [String: Any]
                        let name = attributes?["name"] as? String ?? ""
                        let updatedAt = attributes?["updated_at"] as? String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.969Z"
                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.locale = Locale.current
                        let updatedAtDate = updatedAt != nil ? dateFormatter.date(from: updatedAt!)! : Date()
                        let relationships = project["relationships"] as? [String: Any]
                        let team = relationships?["team"] as? [String: Any]
                        let teamId = Int(team?["id"] as? String ?? "0") ?? 0
                        let teamObj = teams.filter { $0.id == teamId }.first ?? Team(id: 0, name: "")
                        let projectObj = Project(id: id, team: teamObj, name: name, updatedAt: updatedAtDate)
                        projects.append(projectObj)
                    }
                    // Sort projects by updatedAt date descendentely (newer first)
                    projects.sort(by: { $0.updatedAt > $1.updatedAt })
                }

                // Return the dictionary with projects and teams
                completion(.success(["projects": projects, "teams": teams]))
                
            case let .failure(error):
                completion(.failure(error))
            }
        }

    }
}
