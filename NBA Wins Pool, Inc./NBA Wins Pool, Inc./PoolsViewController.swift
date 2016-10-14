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
    
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Pools.shared.updated), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Pool.didUpdateDraft), object: nil)

    tableView.dataSource = self
    tableView.delegate = self
    tableView.reloadData()
    
    if User.shared == nil {
      let loginViewController = LoginViewController()
      present(loginViewController, animated: false, completion: nil)
    }
  }
  
  func reloadData() {
    tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let name = User.shared?.username {
      self.title = name + "\'s Pools"
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    noPoolsLabel?.isHidden = Pools.shared.items.count > 0
    return Pools.shared.items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PoolTableViewCell", for: indexPath) as! PoolTableViewCell
    cell.delegate = self
    
    let pool = Pools.shared.items[indexPath.row]
    cell.nameLabel?.text = pool.name
    cell.membersLabel?.text = "\(pool.users.count)/\(pool.maxSize!) members"
    
    if let button = cell.button {
      if pool.users.count != pool.maxSize {
        button.setTitle("Invite", for: .normal)
      } else if let draft = pool.draft, draft.isComplete {
        let record = pool.record(user: User.shared!)
        button.setTitle("\(record.wins)-\(record.losses) (\(String(format: "%.2f", record.percentage*100.0)))", for: .normal)
      } else if let username = pool.draft?.userWithPick?.username {
        if let name = User.shared?.username, name == username {
          button.setTitle("Your pick!", for: .normal)
        } else {
          button.setTitle(username + "'s pick", for: .normal)
        }
      } else {
        button.setTitle("Waiting for draft status...", for: .normal)
      }
      
      let enabled = !pool.isFull || pool.draft?.picks.count != pool.draft?.selections.count
      button.isUserInteractionEnabled = enabled
      button.isEnabled = enabled
    }
    
    return cell
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      Pools.shared.remove(Pools.shared.items[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  func invite(pool: Pool) {
    let message = "Join our NBA wins pool ->"
    let string = Pool.id + "=\(pool.id!)"
    
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
      let pool = Pools.shared.items[indexPath.row]
      if pool.users.count != pool.maxSize {
        invite(pool: pool)
      } else if pool.draft?.selections.count != pool.draft?.picks.count {
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
    
    let loginViewController = LoginViewController()
    present(loginViewController, animated: true, completion: nil)
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let indexPath = self.tableView.indexPathForSelectedRow {
      let viewController = segue.destination as! UsersViewController
      viewController.pool = Pools.shared.items[indexPath.row]
    }
  }
  
}
