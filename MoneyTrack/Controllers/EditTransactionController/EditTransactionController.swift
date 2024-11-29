import UIKit

protocol CategoryNameSelectionDelegate {
    func didSelectIconName(nameCategory: String, iconImage: String, iconColor: String)
}

class EditTransactionController: UITableViewController {
    
    let dateFormatter = DateFormatter()
    var transactionID: UUID!
    var transactionItems = [Item]()
    var transactionItem: Item!
    var transactionDelegate: VCDelegate!
    var monthlyDelegate: SelectedMonthDelegate!
    var availableCategories = [Category]()
    var selectedDateString: String!
    var newCellDateSelect: String!
    var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SelectCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "selectedCategory")
        
        tableView.register(UINib(nibName: "SummaTableViewCell", bundle: nil), forCellReuseIdentifier: "summaExpenses")
        
        tableView.register(UINib(nibName: "SelectDateTableViewCell", bundle: nil), forCellReuseIdentifier: "selectedDate")
        
        tableView.separatorColor = .white
        
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy"
        selectedDateString = dateFormatter.string(from: transactionItem.date)
        
        let rightButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(changeButton))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "Редактирование"
    }
    
    
    @objc func changeButton() {
        guard let idToUpdate = transactionID else { return }
        
        if let index = transactionItems.firstIndex(where: { $0.id == idToUpdate }) {
            
            let indexPathSumma = IndexPath(row: 1, section: 0)
            
            if let cellSumma = tableView.cellForRow(at: indexPathSumma) as? SummaTableViewCell {
                
                guard let summaText = cellSumma.summaText.text, let nameValue = Double(summaText) else {
                    print("Некорректное значение суммы")
                    return
                }
               
                if let date = dateFormatter.date(from: selectedDateString) {
                    
                    let newDateFormatter = DateFormatter()
                    newDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    
                    let newItem = Item(name: nameValue, date: date, id: idToUpdate, category: transactionItem.category)
                    
                    transactionItems[index] = newItem
                    
                    if let transactionDelegate = transactionDelegate {
                        transactionDelegate.updateTransaction(itemTransaction: transactionItems)
                    } else {
                        print("Ошибка: делегат monthlyDelegate не инициализирован")
                    }
                    
                    if let monthlyDelegate = monthlyDelegate {
                        monthlyDelegate.updateTransactions(items: transactionItems)
                    } else {
                        print("Ошибка: делегат monthlyDelegate не инициализирован")
                    }
                    
                    navigationController?.popViewController(animated: true)
                } else {
                    print("Ошибка: некорректная дата")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 1:
            let cellSumma = tableView.dequeueReusableCell(withIdentifier: "summaExpenses", for: indexPath) as! SummaTableViewCell
            cellSumma.summaText.text = String(transactionItem.name)
            return cellSumma
        case 2:
            let cellDate = tableView.dequeueReusableCell(withIdentifier: "selectedDate", for: indexPath) as! SelectDateTableViewCell
            
            if let date = dateFormatter.date(from: selectedDateString) {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "d MMMM"
                displayDateFormatter.locale = Locale(identifier: "ru_RU")
                
                let formattedDate = displayDateFormatter.string(from: date)
                cellDate.dateTextField.text = formattedDate
            }
            
            cellDate.selectionStyle = .none
            datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
            cellDate.dateTextField.inputView = datePicker
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.datePickerMode = .date
            datePicker.date = transactionItem.date
            let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            cellDate.dateTextField.inputAccessoryView = toolBar
            
            return cellDate
        default:
            let cellCategory = tableView.dequeueReusableCell(withIdentifier: "selectedCategory", for: indexPath) as! SelectCategoryTableViewCell
            cellCategory.categoryText.text = transactionItem.category.name
            return cellCategory
        }
    }
    
    @objc func datePickerDone() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        selectedDateString = dateFormatter.string(from: datePicker.date)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            let categoryViewController = CategoryCollectionViewController(nibName: "CategoryCollectionViewController", bundle: nil)
            categoryViewController.delegateName = self
            categoryViewController.collectionCategory = availableCategories
            categoryViewController.checkController = true
            
            navigationController?.pushViewController(categoryViewController, animated: true)
        }
    }
}

extension EditTransactionController: CategoryNameSelectionDelegate{
    func didSelectIconName(nameCategory: String, iconImage: String, iconColor: String) {
        transactionItem.category.imageName = iconImage
        transactionItem.category.colorName = iconColor
        transactionItem.category.name = nameCategory
        tableView.reloadData()
    }
}
