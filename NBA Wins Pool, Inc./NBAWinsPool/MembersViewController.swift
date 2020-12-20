//
//  UsersViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/4/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class MembersViewController: UITableViewController {
  
  var pool: Pool! {
    didSet {
      if pool.members.count != pool.size {
        members = pool.members.sorted { $0.name < $1.name }
      } else {
        members = pool.membersSortedByWinPercentage
      }
    }
  }
  var members: [Member]!
  var listener: ListenerRegistration?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self
    self.tableView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Teams.shared.delegate = self
    reloadData()
    
    guard pool.members.count != pool.size else { return }
    listener = FirebaseInterface.addPoolListener(id: pool.id) { (updatedPool, error) in
      guard let p = updatedPool else { return }
      self.pool = p
      UNUserNotificationCenter.addDraftPickNotification(pool: p)
      self.reloadData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    Teams.shared.delegate = nil
    listener?.remove()
    listener = nil
  }
  
  func reloadData() {
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return members.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! MemberTableViewCell
    let member = members[indexPath.row]
    cell.nameLabel?.text = member.name
    let record = pool.recordForMember(member)
    cell.recordLabel?.text = "\(record.wins)-\(record.losses) (\(String(format: "%.1f", record.percentage*100.0)))"
    cell.teams = Array(pool.teamsForMember(member))
    
    return cell
  }
  
  @IBAction func backPressed(_ sender: UIBarButtonItem) {
    _ = navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! TeamsViewController
      viewController.pool = pool
      viewController.member = members[indexPath.row]
    }
  }
  
}

extension MembersViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
