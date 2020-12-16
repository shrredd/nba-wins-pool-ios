//
//  PoolsViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class PoolsViewController: UITableViewController, PoolTableViewCellDelegate {
  
  var noPoolsLabel: UILabel?
  var pools = [Pool]()
  var listener: ListenerRegistration?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label = UILabel(frame: view.bounds)
    label.text = "No pools :("
    label.font = UIFont(name: "Avenir-Heavy", size: 26.0)
    label.textColor = UIColor.white
    label.textAlignment = .center
    view.addSubview(label)
    noPoolsLabel = label

    tableView.dataSource = self
    tableView.delegate = self
    tableView.reloadData()
    
    if Auth.auth().currentUser == nil {
      presentLogin(animated: false)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Teams.shared.delegate = self
    reloadData()
    
    guard let member = Member.currentMember else { return }
    self.title = member.name + "\'s Pools"

    listener = FirebaseInterface.addPoolsListener(member: member) { (updatedPools, error) in
      if let e = error {
        UIAlertController.alertOK(title: "Update Pools Error", message: e.localizedDescription)
      }
      guard let p = updatedPools else { return }
      self.pools = p.sorted { $0.name < $1.name }
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
    noPoolsLabel?.isHidden = !pools.isEmpty
    return pools.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PoolTableViewCell", for: indexPath) as! PoolTableViewCell
    cell.delegate = self
    
    let pool = pools[indexPath.row]
    cell.nameLabel?.text = pool.name
    cell.membersLabel?.text = "\(pool.members.count)/\(pool.size) members"
    
    if let button = cell.button {
      if pool.members.count != pool.size {
        button.setTitle("Invite", for: .normal)
      } else if pool.isComplete {
        var record = Record(wins: 0, losses: 0)
        if let member = Member.currentMember {
          record = pool.recordForMember(member)
        }
        button.setTitle("\(record.wins)-\(record.losses) (\(String(format: "%.1f", record.percentage*100.0)))", for: .normal)
      } else if let username = pool.currentPick?.member.name {
        if let name = Member.currentMember?.name, name == username {
          button.setTitle("Your pick!", for: .normal)
        } else {
          button.setTitle(username + "'s pick", for: .normal)
        }
      } else {
        button.setTitle("Waiting for draft status...", for: .normal)
      }
      
      let isEnabled = !pool.isFull || !pool.isComplete
      button.isUserInteractionEnabled = isEnabled
      button.isEnabled = isEnabled
    }
    
    return cell
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let pool = pools[indexPath.row]
      guard let member = Member.currentMember else {
        UIAlertController.alertOK(title: "Delete Pool Failed", message: "You are not logged in?")
        return
      }
      FirebaseInterface.leavePool(pool, member: member) { (error) in
        guard let e = error else { return }
        UIAlertController.alertOK(title: "Delete Pool Failed", message: e.localizedDescription)
      }
    }
  }

  func invite(pool: Pool) {
    let message = "Join our wins pool ->"
    let string = "id=\(pool.id)"
    
    if let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
      if let url = URL(string: "WinsPool://?" + escapedString) {
        let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
      }
    }
  }
  
  // MARK: PoolTableViewCellDelegate
  
  func poolCellButtonPressed(cell: PoolTableViewCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let pool = pools[indexPath.row]
      if pool.members.count != pool.size {
        invite(pool: pool)
      } else if !pool.isComplete {
        let viewController = DraftViewController()
        viewController.pool = pool
        navigationController?.pushViewController(viewController, animated: true)
      }
    }
  }
  
  // MARK: button callbacks
  
  @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
    pools = []
    do {
      try FUIAuth.defaultAuthUI()?.signOut()
    } catch {
      UIAlertController.alertOK(title: "Log Out Failed", message: error.localizedDescription)
    }
    presentLogin(animated: true)
  }
  
  func presentLogin(animated: Bool) {
    guard let authViewController = FUIAuth.defaultAuthUI()?.authViewController() else { return }
    authViewController.modalPresentationStyle = .fullScreen
    parent?.present(authViewController, animated: true, completion: nil)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! MembersViewController
      viewController.pool = pools[indexPath.row]
    }
  }
  
}

extension PoolsViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
