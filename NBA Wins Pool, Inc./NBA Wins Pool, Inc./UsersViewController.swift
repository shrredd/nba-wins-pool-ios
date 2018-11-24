//
//  UsersViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/4/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class UsersViewController: UITableViewController {
  
  var pool: Pool!
  var users = [User]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self
    self.tableView.delegate = self
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
    users = pool.membersSortedByWinPercentage
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
    let user = users[indexPath.row]
    cell.nameLabel?.text = user.username
    let record = pool.recordForUser(user)
    cell.recordLabel?.text = "\(record.wins)-\(record.losses) (\(String(format: "%.1f", record.percentage*100.0)))"
    cell.teams = Array(pool.teamsForUser(user))
    
    return cell
  }
  
  @IBAction func backPressed(_ sender: UIBarButtonItem) {
    _ = navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! TeamsViewController
      viewController.pool = pool
      viewController.user = users[indexPath.row]
    }
  }
  
}

extension UsersViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
