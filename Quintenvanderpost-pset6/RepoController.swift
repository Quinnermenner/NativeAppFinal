//
//  RepoController.swift
//  Quintenvanderpost-pset6
//
//  Created by Quinten van der Post on 11/12/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class RepoController: UITableViewController {
    
    // MARK Outlets:
    @IBOutlet var repoTable: UITableView!
    
    // MARK Constants:
    let ref = FIRDatabase.database().reference(withPath: "repo-list")
    
    // MARK: Properties
    var repos: [Repo] = []
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Synchronize Data to tableView
        ref.observe(.value, with: { snapshot in
            var repoList: [Repo] = []
                for item in snapshot.children {
                let repo = Repo(snapshot: item as! FIRDataSnapshot)
                repoList.append(repo)
            }
            self.repos = repoList
            self.repoTable.reloadData()
        })
    }
    
    // Mark: Functions
    
    func gitRepoSearch(title: String) -> JSON {
        
        let url = URL(string: "https://api.github.com/search/repositories?q=\(title)")!
        let data = try? Data(contentsOf: url)
        let json = JSON(data: data!)

        return json
    }
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Git Repo",
                                      message: "Add a repository",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add",
                                       style: .default) { _ in
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                         // TODO: Implement GitAPI and make classes
                                        
                                        let repoJson = self.gitRepoSearch(title: text)
                                        let name = repoJson["items"][0]["name"].stringValue
                                        let description = repoJson["items"][0]["description"].stringValue
                                        let owner = repoJson["items"][0]["owner"]["login"].stringValue
                                        let url = repoJson["items"][0]["owner"]["html_url"].stringValue
                                        let updateDate = repoJson["items"][0]["updated_at"].stringValue
                                        let id = repoJson["items"][0]["id"].intValue
                                        
                                        let repo = Repo(name: name, description: description, owner: owner, url: url, updateDate: updateDate)
                                        
                                        let repoRef = self.ref.child(String(id))
                                        
                                        repoRef.setValue(repo.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = repoTable.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath) as! RepoCell
        let repo = repos[indexPath.row]
     
        cell.name.text = repo.name
        cell.repoDescription.text = repo.description
        cell.updateDate.text = repo.owner
     
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let repo = repos[indexPath.row]
            print(repo)
            repo.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = repoTable.indexPathForSelectedRow
        performSegue(withIdentifier: "segueToCommitController", sender: selectedRow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCommitController" {
            let indexPath = self.repoTable.indexPathForSelectedRow
            let repo = repos[(indexPath?.row)!]
            let destination = segue.destination as! CommitController
            destination.repo = repo
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
