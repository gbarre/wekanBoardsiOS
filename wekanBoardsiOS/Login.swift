//
//  Login.swift
//  wekanBoardsiOS
//
//  Created by Guillaume on 31/01/2018.
//

import UIKit

class Login: UIViewController {
    
    var bearer = ""

    @IBOutlet weak var rootURL: UITextField!
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func getToken(_ sender: UIButton) {
        let params = ["username": "\(login.text!)", "password": "\(password.text!)"]
        var request = URLRequest(url: URL(string: "\(rootURL.text!)/users/login")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let credentials = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                    self.bearer = "\(credentials["token"]!)"
                    let defaults = UserDefaults.standard
                    defaults.set("\(credentials["tokenExpires"]!)", forKey: "tokenExpires")
                    defaults.set("\(credentials["token"]!)", forKey: "token")
                    defaults.set("\(self.rootURL.text!)", forKey: "url")
                    
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "loginOK", sender: sender)
                    }
                } catch {
                    print("error")
                }
                
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        rootURL.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCredentials()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginOK" {
            let controller: ViewController = segue.destination as! ViewController
            controller.bearer = self.bearer
            controller.rootURL = self.rootURL.text!
        }
    }
    
    func getCredentials() {
        let defaults = UserDefaults.standard
        
        if let tokenExpires = defaults.string(forKey: "tokenExpires") {
            let expireDay = "\(tokenExpires.prefix(tokenExpires.count - 5))"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
            
            guard let expireDate = dateFormatter.date(from: expireDay) else {
                fatalError("ERROR: Date conversion failed due to mismatched format.")
            }

            if Date() < expireDate {
                if let token = defaults.string(forKey: "token") {
                    self.bearer = token
                    self.rootURL.text = defaults.string(forKey: "url")
                    self.performSegue(withIdentifier: "loginOK", sender: self)
                }
            }
        }
    }
    
}
