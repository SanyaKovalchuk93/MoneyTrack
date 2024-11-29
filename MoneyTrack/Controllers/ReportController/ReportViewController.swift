import UIKit
import DGCharts

protocol ReportDelegate{
    func dateSelection(date: String)
}

class ReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var labelDate: UILabel!
    
    var pieChartView = PieChartView()
    
    @IBOutlet var viewChart: UIView!
    
    @IBOutlet var totalSumma: UILabel!
    
    @IBOutlet var reportList: UITableView!
    
    var dataArray: [Item] = []
    
    var novemberItems: [(category: String, color: String, imageName: String, number: Double)]  = []
    
    var formattedDates: [String] = []
    var uniqueItems: [String] = []
    
    var selectedDate = String()
    var currentDate = Date()
    
    @IBOutlet var selectionDayMonthYear: UISegmentedControl!
    
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Отчет"
        self.navigationController?.navigationBar.barTintColor = .red
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        labelDate.isUserInteractionEnabled = true
        labelDate.addGestureRecognizer(tapGesture)
       
        dateFormatter.dateFormat = "d MMMM yyyy"
    
        updateDate(forSegmentIndex: selectionDayMonthYear.selectedSegmentIndex)
        
        reportList.delegate = self
        reportList.dataSource = self
        reportList.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "cellMain")
        
        reportList.reloadData()
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        
        updateDate(forSegmentIndex: sender.selectedSegmentIndex)
    }
    
    func chartValue() {
       
        pieChartView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300)
        self.viewChart.addSubview(pieChartView)
        
        let values = novemberItems.map { category in
            PieChartDataEntry(value: category.number, label: category.category)
        }
        
        let dataSet = PieChartDataSet(entries: values, label: "Colors")
          
        if novemberItems.isEmpty {
            print("novemberItems is empty")
        } else {
            let colors = novemberItems.map { colorFromString($0.color) }
            
            if colors.isEmpty {
                print("Ошибка: Массив цветов пуст!")
            } else {
                dataSet.colors = colors
            }
            dataSet.colors = colors
        }
        
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        
        pieChartView.drawHoleEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.rotationEnabled = false
        
        pieChartView.data?.setValueFont(UIFont.systemFont(ofSize: 14))
        pieChartView.data?.setValueTextColor(UIColor.black)
        
        pieChartView.entryLabelFont = UIFont.boldSystemFont(ofSize: 16)
        pieChartView.entryLabelColor = UIColor.blue
    }
    
    func colorFromString(_ colorString: String) -> UIColor {
        switch colorString.lowercased() {
        case "yellow":
            return UIColor(named: "yellow") ?? UIColor.gray
        case "red":
            return UIColor(named: "red") ?? UIColor.gray
        case "green":
            return UIColor(named: "green") ?? UIColor.gray
        case "fiolet":
            return UIColor(named: "fiolet") ?? UIColor.gray
        case "bluelight":
            return UIColor(named: "blueLight") ?? UIColor.gray
        case "blue":
            return UIColor(named: "blue") ?? UIColor.gray
        case "greenlight":
            return UIColor(named: "greenLight") ?? UIColor.gray
        case "greylight":
            return UIColor(named: "greyLight") ?? UIColor.gray
        case "pink":
            return UIColor(named: "pink") ?? UIColor.gray
        default:
            return UIColor.gray
        }
    }
    
    private func updateDate(forSegmentIndex index: Int) {
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        if let date = date(from: selectedDate)  {
            currentDate = date
        }
        
        switch index {
        case 0:
            updateForDayMonthYear()
        case 1:
            updateForMonthYear()
        case 2:
            updateForYear()
        default:
            return
        }
    }

    private func updateForDayMonthYear() {
        dateFormatter.dateFormat = "d MMMM yyyy"
        updateFormattedDates()
        novemberItems = filterItemsByDateAndSort(by: selectedDate, in: dataArray)
        updateUI()
    }

    private func updateForMonthYear() {
        dateFormatter.dateFormat = "LLLL yyyy"
        updateFormattedDates()
        novemberItems = filterItemsMonth(by: selectedDate, in: dataArray)
        updateUI()
    }

    private func updateForYear() {
        dateFormatter.dateFormat = "yyyy"
        updateFormattedDates()
        novemberItems = filterItemsYears(by: selectedDate, in: dataArray)
        updateUI()
    }

    private func updateFormattedDates() {
        formattedDates = dataArray.map { item -> String in
            return dateFormatter.string(from: item.date)
        }
        selectedDate = dateFormatter.string(from: currentDate)
        labelDate.text = selectedDate
    }

    private func updateUI() {
        combineCategoriesAndSum()
        uniqueItems = Array(Set(formattedDates))
        
        let totalSum = novemberItems.reduce(into: 0.0) { (sum, item) in
            sum += item.number
        }
        
        totalSumma.text = "Потрачено: " + String(totalSum)
        pieChartView.removeFromSuperview()
        chartValue()
        reportList.reloadData()
    }

    
    func combineCategoriesAndSum() {
        var combinedItems: [String: (category: String, color: String, imageName: String, number: Double)] = [:]
        
        for item in novemberItems {
            if let existingItem = combinedItems[item.category] {
               
                combinedItems[item.category] = (
                    category: existingItem.category,
                    color: existingItem.color,
                    imageName: existingItem.imageName,
                    number: existingItem.number + item.number
                )
            } else {
               
                combinedItems[item.category] = item
            }
        }
        
        novemberItems = Array(combinedItems.values)
        novemberItems.sort { $0.number > $1.number }
    }
    
    func filterItemsByDate(_ items: [Item], date: Date) -> [Item] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return items.filter { item in
            return item.date >= startOfDay && item.date < endOfDay
        }
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        let modalVC = DateSelectionViewController()
        modalVC.dateSelectionDelegate = self
        modalVC.dateTitles = uniqueItems
        modalVC.modalPresentationStyle = .overFullScreen
        present(modalVC, animated: true, completion: nil)
    }
    
    func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    func filterItems(by stringDate: String, in items: [Item], dateComponent: Calendar.Component) -> [(category: String, color: String, imageName: String, number: Double)] {
        guard let searchDate = date(from: stringDate) else {
            return []
        }
        
        let calendar = Calendar.current
        let filteredItems = items.filter { item in
            let itemDate = item.date
            let itemComponent = calendar.component(dateComponent, from: itemDate)
            let searchComponent = calendar.component(dateComponent, from: searchDate)
            return itemComponent == searchComponent
        }
        
        let sortedItems = filteredItems.sorted { $0.name > $1.name }
        
        return sortedItems.map { item in
            (category: item.category.name, color: item.category.colorName, imageName: item.category.imageName, number: item.name)
        }
    }

    func filterItemsByDateAndSort(by stringDate: String, in items: [Item]) -> [(category: String, color: String, imageName: String, number: Double)] {
        return filterItems(by: stringDate, in: items, dateComponent: .day)
    }

    func filterItemsMonth(by stringDate: String, in items: [Item]) -> [(category: String, color: String, imageName: String, number: Double)] {
        return filterItems(by: stringDate, in: items, dateComponent: .month)
    }

    func filterItemsYears(by stringDate: String, in items: [Item]) -> [(category: String, color: String, imageName: String, number: Double)] {
        return filterItems(by: stringDate, in: items, dateComponent: .year)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return novemberItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMain", for: indexPath) as! MainTableViewCell
        let colorName = novemberItems[indexPath.row].color
        cell.progressBar.backgroundColor = color(from: colorName)
        cell.nameCategory.text = novemberItems[indexPath.row].category
        cell.imageCategory.image = UIImage(named: novemberItems[indexPath.row].imageName)!.withRenderingMode(.alwaysTemplate)
        cell.imageCategory.tintColor = .white
        
        cell.numberCosts.text = String(novemberItems[indexPath.row].number)
        
        cell.isUserInteractionEnabled = false
        cell.selectionStyle = .none
        
        if let maxItem = novemberItems.max(by: { $0.number < $1.number }) {
            
            let maxNumber = maxItem.number
            
            let progressBarWidth = (novemberItems[indexPath.row].number / maxNumber) * tableView.bounds.width
           
            cell.progressBar.frame = CGRect(x: cell.progressBar.frame.origin.x,
                                            y: cell.progressBar.frame.origin.y,
                                            width: progressBarWidth,
                                            height: cell.progressBar.frame.height)
        } else {
           
            cell.progressBar.frame = CGRect(x: cell.progressBar.frame.origin.x,
                                            y: cell.progressBar.frame.origin.y,
                                            width: 0,
                                            height: cell.progressBar.frame.height)
        }

        return cell
    }
    
    
    func color(from colorName: String) -> UIColor {
        switch colorName {
        case "green":
            return UIColor(named: "green")!
        case "pink":
            return UIColor(named: "pink")!
        case "red":
            return UIColor(named: "red")!
        case "blueLight":
            return UIColor(named: "blueLight")!
        case "blue":
            return UIColor(named: "blue")!
        case "fiolet":
            return UIColor(named: "fiolet")!
        case "greenLight":
            return UIColor(named: "greenLight")!
        case "greyLight":
            return UIColor(named: "greyLight")!
        case "yellow":
            return UIColor(named: "yellow")!
        default:
            return UIColor.white
        }
    }
}

extension ReportViewController: ReportDelegate{
    func dateSelection(date: String) {
        selectedDate = date
        updateDate(forSegmentIndex: selectionDayMonthYear.selectedSegmentIndex)
        chartValue()
        reportList.reloadData()
    }
}
