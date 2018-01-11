//
//  QuestionsViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 1/11/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var theQuestions = [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let text = theQuestions[indexPath.row].questionText
        cell.textLabel?.text = "  \(indexPath.row+1).  \(String(describing: text!))"
        cell.textLabel?.font =  UIFont(name: "Courier", size: 30.0)
        //cell.textLabel?.textAlignment = .center
        return cell
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
