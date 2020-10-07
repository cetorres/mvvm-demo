//
//  MainViewController.swift
//  FrameIOTest
//
//  Created by Carlos Torres on 9/24/20.
//

import UIKit

class MainViewController: UITableViewController {
    
    var projects = [Project]()
    var recentProjects = [Project]()
    var teams = [Team]()
    let activityIndicator = UIActivityIndicatorView()
    var isInitialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = MAIN_VC_TITLE
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Table view settings
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        
        // Table view refresh control
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = rc
                
        // Initial activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y/1.5)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
                
        // Load projects
        loadProjects()
    }
    
    private func loadProjects() {
        ProjectsService.shared.getProjectsAndTeams { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "\(ERROR_COULD_NOT_LOAD_DATA) \(error.localizedDescription)")
                }
            case .success(let results):
                if let projects = results["projects"] as? [Project] {
                    self?.projects = projects
                }
                if let teams = results["teams"] as? [Team] {
                    self?.teams = teams
                }
                
                self?.isInitialLoad = false
                
                self?.loadRecentProjects()
            }
                                    
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
                self?.activityIndicator.stopAnimating()
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
    }

    @objc func refreshData() {
        loadProjects()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return teams.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Recent
        if (section == 0) {
            return recentProjects.count
        }
        // Teams
        let team = teams[section-1]
        let teamProjects = projects.filter { $0.team.id == team.id }
        return teamProjects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isInitialLoad {
            return nil
        }
        if section == 0 {
            return RECENT_SECTION_TITLE
        }
        return teams[section-1].name
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isInitialLoad {
            return nil
        }
        // Show a message when there is no recent projects to show under the Recent section
        if (section == 0) {
            let lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
            lblMessage.text = RECENT_NO_ITEMS_MESSAGE
            lblMessage.textAlignment = .center
            lblMessage.sizeToFit()
            return lblMessage
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isInitialLoad {
            return 0
        }
        if (section == 0 && recentProjects.count <= 0) {
            return 50
        }
        return 0
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // Recent
        if (indexPath.section == 0) {
            let recentProject = recentProjects[indexPath.row]

            cell.textLabel?.text = recentProject.name
            cell.textLabel?.numberOfLines = 0

            cell.detailTextLabel?.text = recentProject.team.name
            cell.detailTextLabel?.numberOfLines = 0
        }
        // Teams
        else {
            let team = teams[indexPath.section-1]
            let teamProjects = projects.filter { $0.team.id == team.id }
            
            let project = teamProjects[indexPath.row]
                 
            cell.textLabel?.text = project.name
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
      
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

