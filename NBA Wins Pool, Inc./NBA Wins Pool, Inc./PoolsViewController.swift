//
//  PoolsViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 9/3/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class PoolsViewController: UITableViewController, PoolTableViewCellDelegate {
  
  var noPoolsLabel: UILabel?
  var pools = [Pool]()
  
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
    
    if User.shared == nil {
      presentLogin(animated: false)
    }
  }
  
  @objc func reloadData() {
    pools = Pools.shared.pools.sorted { $0.name < $1.name }
    tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let name = User.shared?.username {
      self.title = name + "\'s Pools"
    }
    
    Pools.shared.delegate = self
    Teams.shared.delegate = self
    reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    Pools.shared.delegate = nil
    Teams.shared.delegate = nil
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
    cell.membersLabel?.text = "\(pool.members?.count ?? 0)/\(pool.max_size) members"
    
    if let button = cell.button {
      if pool.members?.count ?? 0 != pool.max_size {
        button.setTitle("Invite", for: .normal)
      } else if pool.isComplete {
        var record = Record(wins: 0, losses: 0)
        if let user = User.shared {
          record = pool.recordForUser(user)
        }
        button.setTitle("\(record.wins)-\(record.losses) (\(String(format: "%.1f", record.percentage*100.0)))", for: .normal)
      } else if let username = pool.userWithPick?.username {
        if let name = User.shared?.username, name == username {
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
      pools.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      Pools.shared.leavePoolWithId(pool.id) { [weak self] (success) in
        if success {
          self?.reloadData()
        } else {
          UIAlertController.alertOK(title: "Delete Pool Failed", message: "We could not remove you from the pool you just deleted. Expect the pool to reappear unexpectedly...I blame Shravan.")
        }
      }
    }
  }

  func invite(pool: Pool) {
    let message = "Join our wins pool ->"
    let string = "id=\(pool.id)"
    
    if let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
      if let url = URL(string: "WinsPool://?" + escapedString) {
        let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {
          
        })
      }
    }
  }
  
  // MARK: PoolTableViewCellDelegate
  
  func poolCellButtonPressed(cell: PoolTableViewCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let pool = pools[indexPath.row]
      if pool.members?.count ?? 0 != pool.max_size {
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
    User.shared = nil
    User.save()
    Pools.shared.removeAll()
    presentLogin(animated: true)
  }
  
  func presentLogin(animated: Bool) {
    let loginViewController = LoginViewController()
    loginViewController.modalPresentationStyle = .fullScreen
    parent?.present(loginViewController, animated: animated, completion: nil)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! UsersViewController
      viewController.pool = pools[indexPath.row]
    }
  }
  
}

extension PoolsViewController: PoolsDelegate {
  func pools(_ pools: Pools, didUpdatePool pool: Pool) {
    reloadData()
  }
}

extension PoolsViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
