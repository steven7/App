//
//  TextQuestionTableViewCell.swift
//  Alchemie
//
//  Created by Steve on 1/13/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class TextQuestionTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var questionText: UITextField!
    
    var question:Question?
     
    var pickerClosureCloseWithAnsPlusRow:((UITextField, Int)->())?
    var textFieldClosure:((String, Int)->())?
    
    var row:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.questionText.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end list edit")
        // pickerClosureCloseWithAns!(textField)
        //pickerClosureCloseWithAns!(textField, row)
        pickerClosureCloseWithAnsPlusRow!(textField, row!)
        textFieldClosure!(textField.text!, row!)
    }
    
    func getAnswer() -> String {
        return questionText.text!
    }
    
}
