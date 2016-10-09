//
//  DraftViewController.swift
//  NBA Wins Pool, Inc.
//
//  Created by John Benz Jessen on 10/8/16.
//  Copyright © 2016 NBA Wins Pool, Inc. All rights reserved.
//

import UIKit

class DraftViewController: UITableViewController {
  
  var draft: Draft!
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
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closePressed))
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.pinkishRed
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    unselectedTeams = draft.unselectedTeams
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return unselectedTeams.count
    } else {
      return draft.picks.count
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
      let team = draft.unselectedTeams[indexPath.row]
      cell.pick.isHidden = true
      cell.label.text = team.fullName
      cell.emoji.text = team.emoji
      cell.contentView.backgroundColor = team.primaryColor
    } else {
      if indexPath.row < draft.selections.count {
        let team = draft.selections[indexPath.row]
        cell.label.text = team.fullName
        cell.emoji.text = team.emoji
        cell.contentView.backgroundColor = team.primaryColor
      } else {
        cell.label.text = "--"
        cell.emoji.text = "🏀"
        cell.contentView.backgroundColor = UIColor.almostBlackGray
      }
      cell.pick.isHidden = false
      cell.pick.text = "\(indexPath.row + 1). " + draft.picks[indexPath.row].username
    }
    
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func closePressed() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
