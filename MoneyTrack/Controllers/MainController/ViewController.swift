import UIKit

protocol VCDelegate {
    func updateCategory(arrayCategory: [Category])
    func updateTransaction(itemTransaction: [Item])
    func history(history: [Item])
}

struct Item: Codable {
    var name: Double
    var date: Date
    var id: UUID
    var category: Category
}

struct Category: Codable {
    var name: String
    var imageName: String
    var colorName: String
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    
    var color: UIColor? {
        return UIColor(named: colorName)
    }
}
extension Item: Comparable {
    static func < (lhs: Item, rhs: Item) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.date == rhs.date
    }
}

class ViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var buttonsView: [UIButton]!
    
    var originalButtonBackgroundColor: UIColor?
    var originalLabelTextColor: UIColor?
    
    var isCurrentlyTyping = false
    var isDotPlaced = false
    var isZeroPlaced = false
    
    var allTransactions: [Item] = []
    var groupedTransactionItems: [[Item]] = [[]]
    
    var transactionCategories = [Category]()
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet var reportButtonImageView: UIImageView!
    
    let dateFormatter = DateFormatter()
    let date = Date()
    let calendar = Calendar.current
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTransactionTableView()
        setupCategoryCollectionView()
        originalLabelTextColor = UIColor(named: "mainColor")
        checkIfAmountLabelIsEmpty()
        
        for btn in buttonsView{
            originalButtonBackgroundColor = btn.backgroundColor
            btn.layer.cornerRadius = 35
            
            btn.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
            btn.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reportButtonTapped))
        reportButtonImageView.isUserInteractionEnabled = true
        reportButtonImageView.addGestureRecognizer(tapGesture)
        
        loadTransactionItems()
        loadCategories()
        updateGroupedTransactions()
        reloadTransactionTable()
    }
    
    @objc func reportButtonTapped() {
        let reportViewController = ReportViewController(nibName: "ReportViewController", bundle: nil)
        
        reportViewController.dataArray = allTransactions
        navigationController?.pushViewController(reportViewController, animated: true)
    }
    
    func saveTransactionItems() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(allTransactions)
            UserDefaults.standard.set(encoded, forKey: "groupedTransactionItems")
        } catch {
            print("Ошибка при сохранении данных: \(error)")
        }
    }
    
    func loadTransactionItems() {
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.data(forKey: "groupedTransactionItems") {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([Item].self, from: savedData)
                allTransactions = decodedData
            } catch {
                print("Ошибка при загрузке данных: \(error)")
            }
        }
    }
    
    private func saveCategories() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(transactionCategories) {
            UserDefaults.standard.set(encoded, forKey: "transactionCategories")
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "transactionCategories") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Category].self, from: data) {
                transactionCategories = decoded
            }
        }
    }
    
    func updateItemColorsBasedOnCategory(transactionCategories: [Category], allTransactions: inout [Item]) {
        
        for category in transactionCategories {
            
            for i in 0..<allTransactions.count {
                if allTransactions[i].category.name == category.name {
                    
                    allTransactions[i].category.colorName = category.colorName
                }
            }
        }
    }
    
    private func updateGroupedTransactions() {
        let calendar = Calendar.current
        var groupedDict = [String: [Item]]()
        
        
        for item in allTransactions {
            let components = calendar.dateComponents([.year, .month, .day], from: item.date)
            let key = "\(components.year!)-\(components.month!)-\(components.day!)"
            groupedDict[key, default: []].append(item)
        }
        
        
        groupedTransactionItems = []
        let startDate = calendar.date(byAdding: .day, value: -1, to: Date())!
        let endDate = Date()
        
        var currentDate = startDate
        while currentDate <= endDate {
            let key = calendar.dateComponents([.year, .month, .day], from: currentDate)
            let keyString = "\(key.year!)-\(key.month!)-\(key.day!)"
            if let items = groupedDict[keyString] {
                groupedTransactionItems.append(items)
            } else {
                groupedTransactionItems.append([])
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        for i in 0..<groupedTransactionItems.count {
            groupedTransactionItems[i].sort()
        }
        groupedTransactionItems = groupedTransactionItems.map { $0.reversed() }
        groupedTransactionItems.reverse()
        tableView.reloadData()
    }
    
    private func reloadTransactionTable(){
        tableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func isLabelFilledWithDigitsAndDot(label: UILabel) -> Bool {
        let text = label.text ?? ""
            let components = text.split(separator: ".")
            return components.count <= 2 && !text.contains("..")
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        
        sender.backgroundColor = UIColor(named: "mainColor")
        
        sender.setTitleColor(.white, for: .normal)
        
        switch sender.tag {
        case 1...9:
            appendNumberToAmount(String(sender.tag))
        case 10:
            appendDecimalToAmount()
        case 0:
            appendZeroToAmount()
        case 12:
            removeLastCharacterFromAmount()
        default:
            break
        }
    }
    
    @objc func buttonReleased(_ sender: UIButton) {
        sender.backgroundColor = originalButtonBackgroundColor
    }
    
    // MARK: - Setup
    
    private func setupTransactionTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = 70
        tableView.register(UINib(nibName: "EmptyCellTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
    }
    
    private func setupCategoryCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        transactionCategories = [
            Category(name: "Билеты на самолет", imageName: "icon_1", colorName: "greyLight"),
            Category(name: "Инвестиции", imageName: "icon_2", colorName: "blue"),
            Category(name: "Ремонт", imageName: "icon_3", colorName: "blueLight"),
            Category(name: "Путешествие", imageName: "icon_4", colorName: "fiolet"),
            Category(name: "Билеты на поезд", imageName: "icon_5", colorName: "green"),
            Category(name: "Подписка", imageName: "icon_7", colorName: "pink"),
            Category(name: "Шоппинг", imageName: "icon_8", colorName: "red"),
            Category(name: "Депозит", imageName: "icon_10", colorName: "yellow")
        ]
        
        transactionCategories.append(Category(name: "Все статьи", imageName: "icon_9", colorName: "greyLight"))
    }
    
    // MARK: - History
    
    @IBAction func historyButton(_ sender: UIButton) {
        let historyViewController = HistoryViewController(nibName: "HistoryViewController", bundle: nil)
        historyViewController.historyDelegate = self
        historyViewController.allTransactions = allTransactions
        historyViewController.categories = transactionCategories
        navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    private func addNewTransactionItem(data: Item){
        allTransactions.append(data)
        saveTransactionItems()
        updateGroupedTransactions()
        reloadTransactionTable()
    }
    
    // MARK: - Button Actions
    
    private func appendNumberToAmount(_ number: String) {
        checkIfAmountLabelIsEmpty()
        if isCurrentlyTyping && !isZeroPlaced{
            amountLabel.text = amountLabel.text! + number
        }
        
        else if isZeroPlaced{
            amountLabel.text = number
            isZeroPlaced = false
        }
        
        else {
            amountLabel.text = number
            isCurrentlyTyping = true
        }
    }
    
    
    private func appendDecimalToAmount() {
        checkIfAmountLabelIsEmpty()
        
        if isCurrentlyTyping && !isDotPlaced {
            amountLabel.text = amountLabel.text! + "."
            isDotPlaced = true
        }
        else if !isCurrentlyTyping && !isDotPlaced {
            amountLabel.text = "0."
            isCurrentlyTyping = true
            isDotPlaced = true
        }
    }
    
    private func appendZeroToAmount() {
        checkIfAmountLabelIsEmpty()
        if isCurrentlyTyping && !isZeroPlaced {
            amountLabel.text = amountLabel.text! + "0"
        }
        else if !isCurrentlyTyping && !isZeroPlaced {
            amountLabel.text = "0."
            isCurrentlyTyping = true
            isDotPlaced = true
        }
        
        else if isZeroPlaced && isDotPlaced {
            amountLabel.text = amountLabel.text! + "0"
        }
    }
    
    private func removeLastCharacterFromAmount() {
        
        if isCurrentlyTyping {
            amountLabel.text?.removeLast()
            
            if amountLabel.text?.contains(".") == false {
                isDotPlaced = false
                if let text = amountLabel.text, !text.isEmpty, text.first == "0"{
                    isZeroPlaced = true
                }
            }
            
            if amountLabel.text == "" {
                
                checkIfAmountLabelIsEmpty()
            }
        }
    }
    
    func checkIfAmountLabelIsEmpty() {
        if amountLabel.text == "" {
            amountLabel.text = "Ведите сумму"
            isCurrentlyTyping = false
            isDotPlaced = false
            isZeroPlaced = false
            amountLabel.textColor = originalLabelTextColor
            amountLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
        else if amountLabel.text != ""{
            amountLabel.textColor = .white
            amountLabel.font = UIFont.boldSystemFont(ofSize: 30)
        }
    }
}

// MARK: - Table Transaction

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return groupedTransactionItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupedTransactionItems[section].isEmpty {
            return 1
        } else {
            return groupedTransactionItems[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if groupedTransactionItems[indexPath.section].isEmpty {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCellTableViewCell
            emptyCell.isUserInteractionEnabled = false
            emptyCell.selectionStyle = .none
            return emptyCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionCell
            
            let item = groupedTransactionItems[indexPath.section][indexPath.row]
            
            cell.amountLabel.text = String(item.name)
            cell.categoryNameLabel.text = item.category.name
            cell.categoryImageView.image = item.category.image?.withRenderingMode(.alwaysTemplate)
            
            cell.categoryImageView.tintColor = item.category.color
            return cell
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editTransactionCell = EditTransactionController(nibName: "EditTransactionController", bundle: nil)
        
        let selectedItem = groupedTransactionItems[indexPath.section][indexPath.row]
        editTransactionCell.transactionID = selectedItem.id
        
        editTransactionCell.transactionItem = selectedItem
        
        editTransactionCell.transactionDelegate = self
        editTransactionCell.transactionItems = allTransactions
        editTransactionCell.availableCategories = transactionCategories
        
        navigationController?.pushViewController(editTransactionCell, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "sectionHeader")
        
        let currentDate = Date()
        
        if Calendar.current.date(byAdding: .day, value: -1, to: currentDate) != nil {
            dateFormatter.dateFormat = "d MMMM"
            
            
            let attributedString = NSMutableAttributedString()
            
            let sums = groupedTransactionItems.map { subArray in
                return subArray.reduce(0.0) { $0 + $1.name }
            }
            
            if section == 0 {
                
                let redAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(named: "mainColor")!
                ]
                let redText = NSAttributedString(string: "Потрачено сегодня: ", attributes: redAttributes)
                attributedString.append(redText)
                
                let greenAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white
                ]
                
                let sumString = String(sums.first ?? 0.0)
                
                let whiteText = NSAttributedString(string: sumString, attributes: greenAttributes)
                attributedString.append(whiteText)
                
                label.attributedText = attributedString
                
            } else if section == 1 {
                
                let redAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(named: "mainColor")!
                ]
                let redText = NSAttributedString(string: "Потрачено вчера: ", attributes: redAttributes)
                attributedString.append(redText)
                
                let greenAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white
                ]
                
                let sumString2 = String(sums.last ?? 0.0)
                
                let whiteText = NSAttributedString(string: sumString2, attributes: greenAttributes)
                attributedString.append(whiteText)
                
                label.attributedText = attributedString
            }
        }
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: headerView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -10)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let itemToDelete = groupedTransactionItems[indexPath.section][indexPath.row]
            
            groupedTransactionItems[indexPath.section].remove(at: indexPath.row)
            
            if groupedTransactionItems[indexPath.section].isEmpty {
                groupedTransactionItems.remove(at: indexPath.section)
                
                tableView.deleteSections([indexPath.section], with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let rawIndex = allTransactions.firstIndex(where: { $0.id == itemToDelete.id }) {
                allTransactions.remove(at: rawIndex)
            }
            
            updateGroupedTransactions()
            saveTransactionItems()
            tableView.reloadData()
        }
    }
}

// MARK: - Category Transaction

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactionCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colCell", for: indexPath) as! CategoryCell
        
        colCell.imageCategory.image = transactionCategories[indexPath.row].image?.withRenderingMode(.alwaysTemplate)
        colCell.nameCategory.text = transactionCategories[indexPath.row].name
        
        colCell.imageCategory.tintColor = transactionCategories[indexPath.row].color
        saveCategories()
        return colCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == transactionCategories.count - 1 {
            let categoryViewController = CategoryCollectionViewController(nibName: "CategoryCollectionViewController", bundle: nil)
            
            categoryViewController.collectionCategory = transactionCategories
            categoryViewController.checkController = false
            categoryViewController.delegateCategory = self
            
            navigationController?.pushViewController(categoryViewController, animated: true)
        }
        else{
            if isLabelFilledWithDigitsAndDot(label: amountLabel){
                
                let item = Item(name: Double(amountLabel.text!)!, date: Date(), id: UUID(), category: transactionCategories[indexPath.row])
                
                addNewTransactionItem(data: item)
            }
        }
    }
}

// MARK: - Delegate

extension ViewController: VCDelegate{
    func history(history: [Item]) {
        allTransactions = history
        updateGroupedTransactions()
        saveTransactionItems()
        reloadTransactionTable()
    }
    
    func updateTransaction(itemTransaction: [Item]) {
        allTransactions = itemTransaction
        updateGroupedTransactions()
        saveTransactionItems()
        reloadTransactionTable()
    }
    
    func updateCategory(arrayCategory: [Category]) {
        transactionCategories = arrayCategory
        updateItemColorsBasedOnCategory(transactionCategories: transactionCategories, allTransactions: &allTransactions)
        updateGroupedTransactions()
        tableView.reloadData()
        reloadTransactionTable()
        collectionView.reloadData()
        transactionCategories.append(Category(name: "Все статьи", imageName: "icon_9", colorName: "greyLight"))
    }
}
