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
  var member: Member!
  var picks = [Pool.Pick]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\(member.name)'s Teams"
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
    picks = pool.picksForMember(member)?.sorted { $0.team?.record?.percentage ?? 0 > $1.team?.record?.percentage ?? 0 } ?? []
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return picks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DraftTableViewCell", for: indexPath) as! DraftTableViewCell
    
    let pick = picks[indexPath.row]
    cell.set(team: pick.team)
    cell.pick.text = "Pick: \(pick.number)"
    
    return cell
  }
}

extension TeamsViewController: TeamsDelegate {
  func teams(_ teams: Teams, didUpdateTeam team: Team) {
    reloadData()
  }
}
