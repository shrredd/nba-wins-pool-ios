//
//  TeamsViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/13/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class TeamsViewController: UITableViewController {
  
  var pool: Pool!
  var user: User!
  var teams: [Team]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\(user.username!)'s Teams"
    let nib = UINib(nibName: "DraftTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "DraftTableViewCell")
    navigationController?.addBackButton(viewController: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Teams.shared.updated), object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func reloadData() {
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    teams = pool.teams(user: user).sorted(by: { (teamA, teamB) -> Bool in
      return teamA.record?.percentage ?? 0 > teamB.record?.percentage ?? 0
    })
    return teams.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DraftTableViewCell", for: indexPath) as! DraftTableViewCell
    
    let team = teams[indexPath.row]
    cell.set(team: team)
    
    if let index = pool.draft?.selections.index(of: team) {
      cell.pick.text = "Pick: \(index + 1)"
      cell.pick.isHidden = false
    } else {
      cell.pick.isHidden = true
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = teams[indexPath.row]
    let teamViewController = TeamViewController()
    teamViewController.team = team
    navigationController?.pushViewController(teamViewController, animated: true)
  }
  
}
