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
  var teams = [Team]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\(user.username)'s Teams"
    let nib = UINib(nibName: "DraftTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "DraftTableViewCell")
    navigationController?.addBackButton(viewController: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Teams.shared.delegate = self
    reloadData()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    Teams.shared.delegate = nil
  }
  
  @objc func reloadData() {
    teams = pool.teamsForUser(user).sorted { $0.record?.percentage ?? 0 > $1.record?.percentage ?? 0 }
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return teams.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DraftTableViewCell", for: indexPath) as! DraftTableViewCell
    
    let team = teams[indexPath.row]
    cell.set(team: team)
    let selectedTeams = pool.draft_status?.map { Teams.shared.idToTeam[$0.team?.team_id ?? ""] } ?? []
    if let index = selectedTeams.index(of: team) {
      cell.pick.text = "Pick: \(index + 1)"
      cell.pick.isHidden = false
    } else {
      cell.pick.isHidden = true
    }
    
    return cell
  }
}

extension TeamsViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
