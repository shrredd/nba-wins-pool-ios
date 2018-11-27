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
  var picks = [Pool.Pick]()
  var teams = [Team]()
  
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
    Pools.shared.delegate = self
    reloadData()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    Pools.shared.delegate = nil
  }
  
  @objc func reloadData() {
    picks = pool.picksSortedByDraftNumber.filter { $0.team != nil }
    let selectedTeams = picks.map { Teams.shared.idToTeam[$0.team!.team_id]! }
    teams = Teams.shared.teams.subtracting(selectedTeams).sorted { $0.name < $1.name }    
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return teams.count
    case 1: return picks.count
    default: return 0
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
    if indexPath.section == 0 {
      let team = teams[indexPath.row]
      cell.pick.isHidden = true
      cell.set(team: team)
    } else {
      if indexPath.row < picks.count {
        let team = picks[indexPath.row].getTeam()
        cell.set(team: team)
      } else {
        cell.set(team: nil)
      }
      cell.pick.isHidden = false
      cell.pick.text = "\(indexPath.row + 1). \(picks[indexPath.row].user.username)"
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
    return indexPath.section == 0 && pool.userWithPick == User.shared
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = teams[indexPath.row]
    let pickViewController = PickViewController()
    pickViewController.pool = pool
    pickViewController.team = team
    navigationController?.pushViewController(pickViewController, animated: true)
  }
  
  func closePressed() {
    _ = navigationController?.popViewController(animated: true)
  }
}

extension DraftViewController: PoolsDelegate {
  func pools(_ pools: Pools, didUpdatePool pool: Pool) {
    reloadData()
  }
}
