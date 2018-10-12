//
//  DraftViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/8/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class DraftViewController: UITableViewController {
  
  var pool: Pool!
  var unselectedTeams: [Team]!
  
  init() {
    super.init(nibName: String(describing: DraftViewController.self), bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Draft"
    
    let nib = UINib(nibName: "DraftTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "DraftTableViewCell")
    
    navigationController?.addBackButton(viewController: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: Pool.didUpdateDraft), object: nil)
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
    if let draft = pool.draft {
      unselectedTeams = draft.unselectedTeams
    }
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return unselectedTeams.count
    } else if let draft = pool.draft {
      return draft.picks.count
    } else {
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Available Teams"
    } else {
      return "Picks"
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DraftTableViewCell", for: indexPath) as! DraftTableViewCell
    
    if let draft = pool.draft {
      if indexPath.section == 0 {
        let team = draft.unselectedTeams[indexPath.row]
        cell.pick.isHidden = true
        cell.set(team: team)
      } else {
        if indexPath.row < draft.selections.count {
          let team = draft.selections[indexPath.row]
          cell.set(team: team)
        } else {
          cell.set(team: nil)
        }
        cell.pick.isHidden = false
        cell.pick.text = "\(indexPath.row + 1). " + draft.picks[indexPath.row].username
      }
    }
    cell.record.isHidden = true

    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let headerView = view as? UITableViewHeaderFooterView {
      headerView.contentView.backgroundColor = UIColor.almostBlackGray
      headerView.textLabel?.textColor = UIColor.white
      headerView.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      headerView.textLabel?.textAlignment = .center
    }
  }
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    if let draft = pool.draft {
      return indexPath.section == 0 && draft.userWithPick == User.shared
    }
    
    return false
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = unselectedTeams[indexPath.row]
    let pickViewController = PickViewController()
    pickViewController.pool = pool
    pickViewController.team = team
    navigationController?.pushViewController(pickViewController, animated: true)
  }
  
  func closePressed() {
    _ = navigationController?.popViewController(animated: true)
  }
  
}
