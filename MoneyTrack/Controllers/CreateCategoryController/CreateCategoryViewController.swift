import UIKit

protocol SelectIconCategoryDelegate {
    func didSelectIcon(iconImage: String, color: String)
    func didSelectIconColor(color: String)
}

class CreateCategoryViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var newImage: String!
    
    var newColor: String!
    
    var delegate: AddCategoryDelegate!
    
    var navigationTitle: String!
    
    var checkController: Bool!
    
    var nameCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        
        categoryTableView.register(UINib(nibName: "NewTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "newTitleCell")
        
        categoryTableView.register(UINib(nibName: "ChooseIconTableViewCell", bundle: nil), forCellReuseIdentifier: "chooseIconCell")
        
        categoryTableView.register(UINib(nibName: "ChooseColorIconTableViewCell", bundle: nil), forCellReuseIdentifier: "chooseColorIconCell")
        
        if checkController == true{
            
        }
        else{
            newImage = "icon_1"
            newColor = "greyLight"
        }
        
        let rightButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(changeButton))
        
        navigationItem.title = navigationTitle
        
        navigationItem.rightBarButtonItem = rightButton
        
        categoryTableView.separatorColor = .white
    }

    @objc func changeButton() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        if let cell = categoryTableView.cellForRow(at: indexPath) as? NewTitleTableViewCell {
           
            let text = cell.textTitle.text
            
            if !text!.isEmpty {
                if checkController == true {
                    delegate.updateCategory(nameCategory: text!, iconImage: newImage!, iconColor: newColor!)
                    navigationController?.popViewController(animated: true)
                }
                else{
                    delegate.addNewCategory(nameCategory: text!, iconImage: newImage!, iconColor: newColor!)
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension CreateCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let newTitleCell = tableView.dequeueReusableCell(withIdentifier: "newTitleCell", for: indexPath) as! NewTitleTableViewCell
            
            newTitleCell.textTitle.text = nameCategory
            newTitleCell.textTitle.delegate = self
            
            return newTitleCell
        case 1:
            let chooseIconCell = tableView.dequeueReusableCell(withIdentifier: "chooseIconCell", for: indexPath) as! ChooseIconTableViewCell
            
            chooseIconCell.imageIcon.image = UIImage(named: newImage)
            chooseIconCell.imageIcon.image = chooseIconCell.imageIcon.image?.withRenderingMode(.alwaysTemplate)
            chooseIconCell.imageIcon.tintColor = UIColor(named: newColor)
            
            return chooseIconCell
        default:
            let chooseColorIconCell = tableView.dequeueReusableCell(withIdentifier: "chooseColorIconCell", for: indexPath) as! ChooseColorIconTableViewCell
            
            return chooseColorIconCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.row == 1{
            let allIconViewController = AllIconCategoryCollectionViewController(nibName: "AllIconCategoryCollectionViewController", bundle: nil)
            
            allIconViewController.delegate = self
            allIconViewController.currentIcon = newImage
            
            navigationController?.pushViewController(allIconViewController, animated: true)
        }
        
        if indexPath.row == 2{
            let colorIconViewController = ColorIconCollectionViewController(nibName: "ColorIconCollectionViewController", bundle: nil)
            
            colorIconViewController.delegate = self
            colorIconViewController.myIcon = newImage
            colorIconViewController.currentColor = newColor
            
            navigationController?.pushViewController(colorIconViewController, animated: true)
        }
    }
}

extension CreateCategoryViewController: SelectIconCategoryDelegate{
    func didSelectIcon(iconImage: String, color: String) {
        newImage = iconImage
        newColor = color
        categoryTableView.reloadData()
    }
    
    func didSelectIconColor(color: String) {
        newColor = color
        categoryTableView.reloadData()
    }
}
