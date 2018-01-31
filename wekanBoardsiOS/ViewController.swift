//
//  ViewController.swift
//  wekanBoardsiOS
//
//  Created by Guillaume on 31/01/2018.
//  Copyright © 2018 Guillaume. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bearer = ""
    var rootURL: String = ""
    var mode = ""
    var parentElement = ""
    
    var usersDict = [String: User]()
    var boardsDict = [String: Board]()
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBAction func back(_ sender: UIButton) {
        if parentElement != "" {
            parentElement = ""
            self.navBar.topItem?.title = (mode == "users") ? "Users" : "Boards"
            self.tableView.reloadData()
        } else if mode != "" {
            mode = ""
            self.navBar.topItem?.title = "Wekan"
            self.tableView.reloadData()
            btnBack.isEnabled = false
        }
    }
    
    
    func buildBoardsDict() {
        if boardsDict.count == 0 {
            for (userId, userObject) in usersDict {
                for board in userObject.boards {
                    let boardId = board.id
                    if !Array(boardsDict.keys).contains(boardId) {
                        board.usersId.append(userId)
                        boardsDict[boardId] = board
                    } else if !(boardsDict[boardId]?.usersId.contains(userId))! {
                        boardsDict[boardId]?.usersId.append(userId)
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        var request = URLRequest(url: URL(string: "\(rootURL)/api/users")!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let users = try JSONSerialization.jsonObject(with: data!) as! [NSDictionary]
                var i = 0
                for user in users {
                    let userId = "\(user["_id"]!)"
                    let userName = "\(user["username"]!)"
                    self.usersDict[userId] = User(id: userId, name: userName)
                    self.usersDict[userId]?.getBoards(rootURL: self.rootURL, bearer: self.bearer)
                    i = i + 1
                }
            } catch {
                print("error")
            }
        })
        task.resume()
        // wait 2 seconds
        sleep(2)
        buildBoardsDict()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case "users":
            btnBack.isEnabled = true
            return (parentElement == "") ? usersDict.count : (usersDict[parentElement]?.boards.count)!
        case "boards":
            btnBack.isEnabled = true
            return (parentElement == "") ? boardsDict.count : (boardsDict[parentElement]?.usersId.count)!
        default:
            self.navBar.topItem?.title = "Wekan"
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "outlineViewCell") as UITableViewCell!
        
        var text = ""
        var hiddenText = ""
        switch mode {
        case "users":
            if parentElement == "" {
                let userId = Array(usersDict.keys)[indexPath.row]
                text = (usersDict[userId]?.name)!
                hiddenText = userId
            } else {
                let boardId = usersDict[parentElement]?.boards[indexPath.row].id
                text = (boardsDict[boardId!]?.name)!
            }
        case "boards":
            if parentElement == "" {
                let boardId = Array(boardsDict.keys)[indexPath.row]
                text = (boardsDict[boardId]?.name)!
                hiddenText = boardId
            } else {
                let userId = boardsDict[parentElement]?.usersId[indexPath.row]
                text = (usersDict[userId!]?.name)!
            }
        default:
            text = (indexPath.row == 0) ? "Users" : "Boards"
        }
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = hiddenText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if parentElement == "" && mode == "" {
            if indexPath.row == 0 {
                mode = "users"
                self.navBar.topItem?.title = "Users"
            } else {
                mode = "boards"
                self.navBar.topItem?.title = "Boards"
            }
            self.tableView.reloadData()
        } else if parentElement == "" {
            parentElement = (cell?.detailTextLabel?.text)!
            if mode == "users" {
                self.navBar.topItem?.title = "Boards for " + (usersDict[parentElement]?.name)!
            } else {
                self.navBar.topItem?.title = "Users for " + (boardsDict[parentElement]?.name)!
            }
            self.tableView.reloadData()
        }
    }
    
}

