//
//  MainViewModel.swift
//  FrameIOTest
//
//  Created by Carlos Torres on 10/8/20.
//

import Foundation

protocol MainViewModelDelegate: AnyObject {
    func loadViewDataError(error: String)
    func viewDataLoaded(viewData: [ViewData])
}

struct ViewData {
    let sectionTitle: String
    let viewItems: [ViewItem]
}

struct ViewItem {
    let projectName: String
    let teamName: String?
}

class MainViewModel {
    private var projects = [Project]()
    private var recentProjects = [Project]()
    private var teams = [Team]()
    
    var projectsNames = [String]()
    var teamsNames = [String]()
    
    weak var delegate: MainViewModelDelegate?
    
    init() {
        loadProjects()
    }
    
    public func reloadProjects() {
        loadProjects()
    }
    
    private func loadProjects() {
        ProjectsService.shared.getProjectsAndTeams { [weak self] result in
            switch result {
            case .failure(let error):
                self?.delegate?.loadViewDataError(error: "\(ERROR_COULD_NOT_LOAD_DATA) \(error.localizedDescription)")
            case .success(let results):
                if let projects = results["projects"] as? [Project] {
                    self?.projects = projects
                }
                if let teams = results["teams"] as? [Team] {
                    self?.teams = teams
                }
                
                self?.loadRecentProjects()
            }
        }
    }
    
    private func loadRecentProjects() {
        recentProjects.removeAll()
        
        // Apply rules for recent project
        if (projects.count > RECENT_PROJECTS_RULE["LOW"]! && projects.count < RECENT_PROJECTS_RULE["HIGH"]!) {
            let recentTotal = projects.count - RECENT_PROJECTS_RULE["SHOW"]!
            for i in 0..<recentTotal {
                recentProjects.append(projects[i])
            }
        }
        else if (projects.count >= RECENT_PROJECTS_RULE["HIGH"]!) {
            let recentTotal = RECENT_PROJECTS_RULE["SHOW"]!
            for i in 0..<recentTotal {
                recentProjects.append(projects[i])
            }
        }
        
        formatViewData()
    }
    
    private func formatViewData() {
        var viewData = [ViewData]()
        
        // Recent projects
        let recentViewItems = recentProjects.map { ViewItem(projectName: $0.name, teamName: $0.team.name) }
        let viewDataRecent = ViewData(sectionTitle: RECENT_SECTION_TITLE, viewItems: recentViewItems)
        viewData.append(viewDataRecent)
        
        // Other projects
        for team in teams {
            let teamProjects = projects.filter { $0.team.id == team.id }
            let viewItems = teamProjects.map { ViewItem(projectName: $0.name, teamName: nil) }
            let viewDataItem = ViewData(sectionTitle: team.name, viewItems: viewItems)
            viewData.append(viewDataItem)
        }
        
        delegate?.viewDataLoaded(viewData: viewData)
    }
}
