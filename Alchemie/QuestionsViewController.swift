//
//  QuestionsViewController.swift
//  Alchemie
//
//  Created by Steven Kanceruk on 1/11/18.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var dicardButton: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var pickerViewTopConstraint: NSLayoutConstraint!
    
    enum QuestionTypes  {
        case text
        case yesOrNo
        case list
        case listMulti
        case photo
    }
    
    // var pickerQuestions = [ "Question One", "Question Two", "Question Three", "Question Four", "Question Five"]
    var pickerQuestions = [ "Question One", "Question Two", "Question Three", "Question Four", "Question Five", "Question Six", "Question Seven", "Question Eight"]
    
    var theQuestions = [Question]()
    
    var theQuestionTypes = [QuestionTypes]()
    
    
    let imagePicker = UIImagePickerController()
    
    var theImage:UIImage?
    var photoButton:UIButton?
    
    var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.saveButton.layer.cornerRadius = 10
        self.dicardButton.layer.cornerRadius = 10
        
        // picker stuff
        self.imagePicker.delegate = self
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        theQuestionTypes = [.text, .yesOrNo, .list, .listMulti, .photo ]
        /*
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestions.append(Question(text: "qwerty asdfg zxcvbn") )
        theQuestionTypes = [.text, .yesOrNo, .list, .listMulti, .photo, .list, .list, .list, .list, .list, .list , .list, .list, .list  ]
        */
        
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
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: .UIKeyboardDidShow , object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: .UIKeyboardDidHide , object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
            //cell.questionText.delegate = self
            //cell.thePicker = self.pickerView
            cell.pickerClosureOpen = pickerClosureOpen
            cell.pickerClosureClose = pickerClosureClose
            cell.pickerPositionClosure = setPickerPositionClosure
            cell.pickerQuestionsClosure = setPickerQuestionsClosure
            
            cell.pickerClosureCloseWithAns = pickerClosureCloseWithAns
            //cell.row = indexPath.row
            cell.keyboardManageClosure = keyboardManageClosure
            cell.keyboardManageClosureClose = keyboardManageClosureClose
            
            return cell
        }
        else if (type == .listMulti) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "multiListCell") as! MultiListQuestionTableViewCell
            cell.questionLabel.text = textString
            cell.pickerClosureOpen = pickerClosureOpen
            cell.pickerClosureClose = pickerClosureClose
            cell.pickerPositionClosure = setPickerPositionClosure
            cell.pickerQuestionsClosure = setPickerQuestionsClosure
            
            cell.pickerClosureCloseWithAnsMulti = pickerClosureCloseWithAnsMulti
            cell.keyboardManageClosure = keyboardManageClosure
            cell.keyboardManageClosureClose = keyboardManageClosureClose
            return cell
        }
        else if (type == .photo) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoQuestionTableViewCell
            cell.questionLabel.text = textString
            cell.photoClosure = photoButtonClosure
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
 
    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            theImage = pickedImage
            photoButton?.setBackgroundImage(self.theImage, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    func photoButtonClosure(sourceView: UIView ) {
        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
        //photoAlert.popoverPresentationController?.sourceView = photoButton
        photoAlert.popoverPresentationController?.sourceView = sourceView
        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        photoAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 180, width: 0, height: 0)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cameraAction)
        self.present(photoAlert, animated: true, completion: {
            print("done lololz")
        })
    }
    */
    
    func photoButtonClosure(button: UIButton ) {
        
        self.photoButton = button
        
        let photoAlert = UIAlertController(title: "Photo Source", message: "What is the source of the photo?", preferredStyle: .actionSheet)
        let buttonView = UIView(frame: CGRect(x: button.frame.midX, y: button.frame.minY - 80, width: button.frame.width, height: button.frame.height))
        //
        photoAlert.popoverPresentationController?.sourceView = button // View // button // .superview 
        //photoAlert.popoverPresentationController?.sourceView = self.view
        photoAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        //photoAlert.popoverPresentationController?.sourceRect = CGRect(x: button.frame.midX, y: button.frame.maxY - 100, width: 0, height: 0)
            //(button.superview?.frame)!
            //CGRect(x: button.frame.midX, y: button.frame.maxY , width: 0, height: 0)
            // button.frame
            // CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 180, width: 0, height: 0)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraAction  = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cameraAction)
        self.present(photoAlert, animated: true, completion: {
            print("done lololz")
        })
    }
    
    func pickerClosureOpen() {
        self.pickerView.isHidden = false
        self.pickerView.isUserInteractionEnabled = true
        self.view.bringSubview(toFront: self.pickerView)
    }
    
    func pickerClosureClose() {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        let answer = self.pickerView.selectedRow(inComponent: 0)
    }
    
    func pickerClosureCloseWithAns(textField: UITextField) {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        let index = self.pickerView.selectedRow(inComponent: 0)
        let theanswer = pickerQuestions[index]
        textField.text = theanswer
    }
    
    func pickerClosureCloseWithAnsMulti(textField: UITextField) {
        self.pickerView.isHidden = true
        self.pickerView.isUserInteractionEnabled = false
        let index = self.pickerView.selectedRow(inComponent: 0)
        let theanswer = pickerQuestions[index]
        textField.text?.append("\(theanswer)  ")
    }
    
    func setPickerQuestionsClosure(theQuestions: [String]) {
        print("question closure")
        print(theQuestions)
        self.pickerQuestions = theQuestions
        self.pickerView.reloadAllComponents()
    }
    
    func setPickerPositionClosure(textField: UITextField) {
        //self.pickerView.leadingAnchor
        //    = textField.bounds.minX
        /*
        print(textField.frame.minY)
        print(textField.superview!.superview!.frame.minY)
        print(textField.superview!.superview!.frame.maxY)
        print(textField.superview!.frame.minY)
        print(textField.superview!.frame.maxY)
        */
        //let point = self.view.superview?.convert(textField.superview!.superview!.frame, to: nil)
        //let point = textField.superview!.superview!.frame.convert(textField.superview!.superview!.frame, to: nil)\
        /*
        let pointone = self.tableView.convert(CGPoint.zero, from: textField.superview!.superview! )
        print("point: \(pointone)")
        let pointtwo = self.tableView.convert(CGPoint.zero, from: textField.superview! )
        print("point: \(pointtwo)")
        */
        let pointthree = self.view.convert(CGPoint.zero, from: textField.superview!.superview! )
        print("point: \(pointthree)")
        /*
        let pointfour = self.view.convert(CGPoint.zero, from: textField.superview! )
        print("point: \(pointfour)")
        let pointone1 = self.tableView.convert(CGRect.zero, from: textField.superview!.superview!)
        print("point: \(pointone1)")
        let pointone11 = self.tableView.convert(CGRect.zero, from: textField.superview! )
        print("point: \(pointone11)")
        */
        
        let dist = pointthree.y - 20.0
        
        print(self.pickerViewTopConstraint.constant)
        self.pickerViewTopConstraint.constant = dist
        print(self.pickerViewTopConstraint.constant)
        self.view.layoutIfNeeded()
        print(self.pickerViewTopConstraint.constant)
    }
    
    func keyboardManageClosure(textField: UITextField, _ notification: NSNotification){
        
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        print("Keyboard size: \(keyboardSize)")
        
        let keyboardRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        var pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: tableView)
        var contentOffset:CGPoint = tableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tableView.contentOffset = contentOffset
        
        /*
        let indexPath = tableView.indexPathForSelectedRow
        print("selected row \(indexPath)")*/
        /*
         let cell = tableView.cellForRow(at: indexPath!)
         */
         /*
        print("current text field \(textField)")
        print("ctext field rect \(textField.frame)")
        print("keyboard rect    \(keyboardRect)")

        if ( keyboardRect.contains(textField.frame) ) {
            print("we scrolling?")
            tableView.scrollRectToVisible(keyboardRect, animated: true)
        }*/
        /*
        if ( textField.frame.contains(keyboardRect) ) {
            tableView.scrollRectToVisible(keyboardRect, animated: true)
        }
        */
    }
    
    func keyboardManageClosureClose(textField: UITextField, _ notification: NSNotification){
        textField.resignFirstResponder()
        if ( textField.superview?.superview is UITableViewCell )
        {
            let buttonPosition = textField.convert(CGPoint.zero, to: tableView)
            let indexPath = tableView.indexPathForRow(at: buttonPosition)
            
            tableView.scrollToRow(at: indexPath!, at: .middle, animated: true)
            //[_tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        }
        /*
        return YES;
        
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        print("Keyboard size: \(keyboardSize)")
        
        let keyboardRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        var pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: tableView)
        var contentOffset:CGPoint = tableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tableView.contentOffset = contentOffset*/
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerQuestions[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerQuestions.count
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        print("Keyboard will show!")
        // print(notification.userInfo)
        
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        print("Keyboard size: \(keyboardSize)")
        
        let keyboardRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let indexPath = tableView.indexPathForSelectedRow
        print("selected row \(indexPath)")
        /*
        let cell = tableView.cellForRow(at: indexPath!)
        */
        print("current text field \(currentTextField)")
        print("keyboard rect \(keyboardRect)")
        /*
        if ( currentTextField?.frame.contains(keyboardRect) )! {
            tableView.scrollRectToVisible(keyboardRect, animated: true)
        }
        */
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
    }
    
    @objc func screenTapped(){
        self.view.endEditing(true)
        pickerClosureClose()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began?")
        self.view.endEditing(true)
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func discardButtonPressed(_ sender: Any) {
        // self.tableView.reloadData()
        // self.navigationController?.popViewController(animated: false)
    }
    
}
