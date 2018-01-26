//
//  MultiListQuestionTableViewCell.swift
//  Alchemie
//
//  Created by Steve on 1/13/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class MultiListQuestionTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var questionText: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    
    var answer:String?
    
    var pickerQuestions = [ "Question One", "Question Two", "Question Three", "Question Four", "Question Five"]
    
    var pickerClosureOpen:(( )->())?
    var pickerClosureClose:(( )->())?
    var pickerPositionClosure:((UITextField)->())?
    var pickerQuestionsClosure:(([String])->())?
    
    var pickerClosureCloseWithAnsMulti:((UITextField)->())?
    var row:Int?
    var keyboardManageClosure: ((UITextField,NSNotification)->())?
    var keyboardManageClosureClose: ((UITextField,NSNotification)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.questionText.delegate = self
        
        let dummyView = UIView(frame:  CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0) )
        self.questionText.inputView = dummyView
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: .UIKeyboardDidShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: .UIKeyboardDidHide , object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin list edit")
        pickerQuestionsClosure!(pickerQuestions)
        pickerPositionClosure!(questionText)
        pickerClosureOpen!()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end list edit")
        pickerClosureCloseWithAnsMulti!(textField)
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        print("Keyboard will show!")
        // print(notification.userInfo)
        // keyboardManageClosure!(questionText, notification)
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
        // keyboardManageClosureClose!(questionText, notification)
    }
}
