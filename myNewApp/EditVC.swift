//
//  EditVC.swift
//  myNewApp
//
//  Created by Alexandr Kovalchuk on 04.05.2024.
//

import UIKit

protocol VCDelegateCategory {
    func changeCategory(text: String)
}

class EditViewController: UITableViewController {
    
    var sectionNumber: String!
    var textSumma: String!
    var dateValue2: String!
    var categoryText: String!
    @IBOutlet weak var summa: UITextField!
    
    @IBOutlet weak var dateValue: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    let datePicker = UIDatePicker()
    
    let toolbar = UIToolbar()
    
    @IBAction func categoryBtn(_ sender: UIButton) {
        let categoryViewController = CategoryCollectionViewController(nibName: "CategoryCollectionViewController", bundle: nil)
        
        categoryViewController.categoryNameCell = categoryText
        categoryViewController.delegateCategory = self
        
        // Отображаем новый экран
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
    
    var delegate: VCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Редактирование"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(closeTVC))
        
        summa.text = textSumma
        
        categoryButton.setTitle(categoryText, for: .normal)
        
        
        dateValue.text = dateValue2
        dateValue.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        dateValue.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        dateValue.inputAccessoryView = toolbar
        
        
    }

    
    @objc func hideKeyboard(){
        
        view.endEditing(true)

    }
    
    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        
        dateValue.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc func closeTVC() {
        navigationController?.popViewController(animated: true)
        
        switch Int(sectionNumber)  {
        case 0:
            delegate.update(text: summa.text!, catText: categoryButton.titleLabel?.text!)
        case 1:
            delegate.update1(text: summa.text!, catText: categoryButton.titleLabel?.text!)
        default:
            break
        }
        
        
    dismiss(animated: true)
    }
}

extension EditViewController: VCDelegateCategory{
    func changeCategory(text: String) {
        categoryButton.setTitle(text, for: .normal)
    }
}
