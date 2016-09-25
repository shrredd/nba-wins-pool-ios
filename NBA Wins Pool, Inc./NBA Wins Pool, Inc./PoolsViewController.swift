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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label = UILabel(frame: view.bounds)
    label.text = "No pools :("
    label.font = UIFont(name: "Avenir-Heavy", size: 26.0)
    label.textColor = UIColor.white
    label.textAlignment = .center
    view.addSubview(label)
    noPoolsLabel = label
    
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Pools.poolsUpdated), object: nil)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.reloadData()
    
    if Users.shared.loggedInUser == nil {
      let loginViewController = LoginViewController()
      present(loginViewController, animated: false, completion: nil)
    }
  }
  
  func reloadData() {
    tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let name = Users.shared.loggedInUser?.username {
      self.title = name + "\'s Pools"
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    noPoolsLabel?.isHidden = Pools.shared.pools.count > 0
    return Pools.shared.pools.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PoolTableViewCell", for: indexPath) as! PoolTableViewCell
    cell.delegate = self
    
    let pool = Pools.shared.pools[indexPath.row]
    cell.nameLabel?.text = pool.name
    cell.membersLabel?.text = "\(pool.users.count)/\(pool.size) members"
    
    let button = cell.button
    if let user = Users.shared.loggedInUser {
      if !pool.users.contains(user) {
        button?.setTitle("Join", for: .normal)
      } else if pool.users.count != pool.size {
        button?.setTitle("Invite", for: .normal)
      } else {
        button?.isHidden = true
      }
    } else {
      button?.isHidden = true
    }
    
    return cell
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      Pools.shared.remove(pool: Pools.shared.pools[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  func invite(pool: Pool) {
    let message = "Join our NBA wins pool ->"
    let string = Pool.name + "=" + pool.name + "&" + Pool.id + "=" + pool.id + "&" + Pool.size + "=\(pool.size)"
    
    if let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
      if let url = URL(string: "NBAWinsPool://?" + escapedString) {
        let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {
          
        })
      }
    }
  }
  
  // MARK: PoolTableViewCellDelegate
  
  func poolCellButtonPressed(cell: PoolTableViewCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      if let user = Users.shared.loggedInUser {
        let pool = Pools.shared.pools[indexPath.row]
        if !pool.users.contains(user) {
          // join
        } else if pool.users.count != pool.size {
          invite(pool: pool)
        }
      }
    }
  }
  
  // MARK: button callbacks
  
  @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
    if let user = Users.shared.loggedInUser {
      Users.shared.loggedInUser = nil
      Users.shared.remove(user: user)
      Pools.shared.removeAllPools()
      
      let loginViewController = LoginViewController()
      present(loginViewController, animated: true, completion: nil)
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! PlayersViewController
      viewController.pool = Pools.shared.pools[indexPath.row]
    }
  }
  
}
