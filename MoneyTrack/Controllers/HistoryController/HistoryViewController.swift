import UIKit

protocol SelectedMonthDelegate {
    func monthlySelect(month: Int, year: Int)
    func updateTransactions(items: [Item])
}

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var allTransactions: [Item] = []
    
    var historyDelegate: VCDelegate!
    
    var currentMonthItems: [Item] = []
    
    var selectedMonth: Int!
    var selectedYear: Int!
    
    var categories: [Category] = []
    
    var uniqueMonthYearStrings: [String] = []
    var distinctMonthYearStrings: [String] = []
    
    var monthNumbers: [Int] = []
    var yearNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "История"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backButtonPressed))
        
        tableView.sectionHeaderTopPadding = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.register(UINib(nibName: "HistoryViewCell", bundle: nil), forCellReuseIdentifier: "cellHistory")
        allTransactions.sort { $0.date > $1.date }
        let currentDate = Date()
        let calendar = Calendar.current
        selectedMonth = calendar.component(.month, from: currentDate)
        selectedYear = calendar.component(.year, from: currentDate)
        filterItemsForCurrentMonth()
        generateUniqueMonthYearStrings()
        tableView.reloadData()
    }
    
    @objc func backButtonPressed() {
        historyDelegate.history(history: allTransactions)
        navigationController?.popViewController(animated: true)
    }
    
    func filterItemsForCurrentMonth() {
        currentMonthItems = allTransactions.filter { item in
            let calendar = Calendar.current
            let month = calendar.component(.month, from: item.date)
            let year = calendar.component(.year, from: item.date)
            return month == selectedMonth && year == selectedYear
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMonthItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHistory", for: indexPath) as! HistoryViewCell
        
        let itemHistory = currentMonthItems[indexPath.row]
        cell.categoryNameLabel.text = itemHistory.category.name
        cell.categoryAmountLabel.text = String(itemHistory.name)
        cell.categoryImageView.image = itemHistory.category.image
        cell.categoryImageView.image = cell.categoryImageView.image?.withRenderingMode(.alwaysTemplate)
        cell.categoryImageView.tintColor = itemHistory.category.color
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"
        
        cell.transactionDateLabel.text = dateFormatter.string(from: itemHistory.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yyyy"
        
        let currentDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth))
        
        if let formattedDate = currentDate {
            label.text = dateFormatter.string(from: formattedDate)
        } else {
            label.text = "Неверный месяц"
        }
        
        label.textAlignment = .center
        label.textColor = .white
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "sectionHeader")
        headerView.addSubview(label)
        
        // Констрейнты для лейбла
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: headerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tapGesture)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let EditTransactionController = EditTransactionController(nibName: "EditTransactionController", bundle: nil)
        
        let selectedItem = currentMonthItems[indexPath.row]
        EditTransactionController.transactionID = selectedItem.id
        EditTransactionController.transactionItem = selectedItem
        EditTransactionController.monthlyDelegate = self
        EditTransactionController.transactionItems = allTransactions
        EditTransactionController.availableCategories = categories
        
        navigationController?.pushViewController(EditTransactionController, animated: true)
    }
    
    func generateUniqueMonthYearStrings() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy" // формат даты
        dateFormatter.locale = Locale(identifier: "ru_RU") // для русского языка
        
        for item in allTransactions {
            let result = dateFormatter.string(from: item.date)
            uniqueMonthYearStrings.append(result)
            
            for item in uniqueMonthYearStrings {
                if !distinctMonthYearStrings.contains(item) {
                    distinctMonthYearStrings.append(item)
                }
            }
            
            if let date = dateFormatter.date(from: result) {
                let month = Calendar.current.component(.month, from: date)
                monthNumbers.append(month)
            }
            yearNumbers = distinctMonthYearStrings.map { monthYear in
                return Int(monthYear.suffix(4)) ?? 0
            }
        }
    }
    
    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        let modalVC = DateSelectionViewController()
        modalVC.monthSelectionDelegate = self
        modalVC.dateTitles = distinctMonthYearStrings
        modalVC.modalPresentationStyle = .overFullScreen
        present(modalVC, animated: true, completion: nil)
    }
}

extension HistoryViewController: SelectedMonthDelegate {
    func updateTransactions(items: [Item]) {
        allTransactions = items
        filterItemsForCurrentMonth()
        tableView.reloadData()
    }
    
    func monthlySelect(month: Int, year: Int) {
        selectedMonth = month
        selectedYear = year
        filterItemsForCurrentMonth()
        tableView.reloadData()
    }
}
