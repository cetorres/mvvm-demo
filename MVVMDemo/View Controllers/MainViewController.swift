//
//  MainViewController.swift
//  MVVMDemo
//
//  Created by Carlos Torres on 9/24/20.
//

import UIKit

class MainViewController: UITableViewController {
    
    let viewModel = MainViewModel()
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
                
        // View model delegate
        viewModel.delegate = self
    }

    @objc func refreshData() {
        viewModel.reloadProjects()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.viewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.viewData[section].viewItems.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isInitialLoad {
            return nil
        }

        return viewModel.viewData[section].sectionTitle
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
        if (section == 0 && viewModel.viewData[0].sectionTitle == RECENT_SECTION_TITLE && viewModel.viewData[0].viewItems.count <= 0) {
            return 50
        }
        return 0
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let viewItem = viewModel.viewData[indexPath.section].viewItems[indexPath.row]
        
        cell.textLabel?.text = viewItem.projectName
        cell.textLabel?.numberOfLines = 0
        
        if let teamName = viewItem.teamName {
            cell.detailTextLabel?.text = teamName
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        return cell
    }
      
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - MainViewModel Delegate

extension MainViewController: MainViewModelDelegate {
    func loadViewDataError(error: String) {
        self.activityIndicator.stopAnimating()
        self.tableView.refreshControl?.endRefreshing()
        
        showAlert(title: "Error", message: error)
    }
    
    func viewDataLoaded() {
        self.isInitialLoad = false
        
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        self.activityIndicator.stopAnimating()
    }
}
