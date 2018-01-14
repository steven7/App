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
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var dicardButton: UIButton!
    
    enum QuestionTypes  {
        case text
        case yesOrNo
        case list
        case listMulti
        case photo
    }
    
    var theQuestions = [Question]()
    
    var theQuestionTypes = [QuestionTypes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.saveButton.layer.cornerRadius = 10
        self.dicardButton.layer.cornerRadius = 10
        
        theQuestionTypes = [.text, .yesOrNo, .list, .listMulti, .photo ]
        
        let tNib = UINib(nibName: "TextQuestionTableViewCell", bundle: nil)
        let yNib = UINib(nibName: "YesOrNoQuestionTableViewCell", bundle: nil)
        let lNib = UINib(nibName: "ListQuestionTableViewCell", bundle: nil)
        let mNib = UINib(nibName: "MultiListQuestionTableViewCell", bundle: nil)
        let pNib = UINib(nibName: "PhotoQuestionTableViewCell", bundle: nil)
        
        tableView.register(tNib, forCellReuseIdentifier: "textCell")
        tableView.register(yNib, forCellReuseIdentifier: "yesrOrNoCell")
        tableView.register(lNib, forCellReuseIdentifier: "listCell")
        tableView.register(mNib, forCellReuseIdentifier: "multiListCell")
        tableView.register(pNib, forCellReuseIdentifier: "photoCell")
        
        tableView.rowHeight = tableView.estimatedRowHeight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = theQuestionTypes[indexPath.row]
        let text = theQuestions[indexPath.row].questionText
        let textString = "  \(indexPath.row+1).  \(String(describing: text!))"
        
        if (type == .text) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextQuestionTableViewCell
            cell.questionLabel.text = textString
            return cell
        }
        else if (type == .yesOrNo) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "yesrOrNoCell") as! YesOrNoQuestionTableViewCell
            cell.questionLabel.text = textString
            return cell
        }
        else if (type == .list) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListQuestionTableViewCell
            cell.questionLabel.text = textString
            return cell
        }
        else if (type == .listMulti) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "multiListCell") as! MultiListQuestionTableViewCell
            cell.questionLabel.text = textString
            return cell
        }
        else if (type == .photo) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoQuestionTableViewCell
            cell.questionLabel.text = textString
            return cell
        }
        
        let cell = UITableViewCell()
        let theText = theQuestions[indexPath.row].questionText
        cell.textLabel?.text = "  \(indexPath.row+1).  \(String(describing: theText!))"
        cell.textLabel?.font =  UIFont(name: "Courier", size: 30.0)
        //cell.textLabel?.textAlignment = .center
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type = theQuestionTypes[indexPath.row]
        
        if (type == .text) {
            return 150
        }
        else if (type == .yesOrNo) {
            return 150
        }
        else if (type == .list) {
            return 150
        }
        else if (type == .listMulti) {
            return 150
        }
        else if (type == .photo) {
            return 110
        }
        else {
            return 65
        }
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
