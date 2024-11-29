import UIKit

class DateSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var dateTitles: [String] = []
    
    var monthNumbers: [Int] = []
    var yearNumbers: [Int] = []
    
    @IBOutlet var dateTableView: UITableView!
    
    var monthSelectionDelegate: SelectedMonthDelegate!
    var dateSelectionDelegate: ReportDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.rowHeight = 50
        dateTableView.register(UINib(nibName: "HistoryMonthCell", bundle: nil), forCellReuseIdentifier: "historyMonth")
        
        dateTableView.layer.cornerRadius = 10
        dateTableView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTable))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        sortDatesByDescendingOrder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        for dateString in dateTitles {
            if let date = dateFormatter.date(from: dateString) {
                let month = Calendar.current.component(.month, from: date)
                monthNumbers.append(month)
                
                if let year = Int(dateString.suffix(4)) {
                    yearNumbers.append(year)
                }
            } else {
                print("Ошибка преобразования строки \(dateString) в Date")
            }
        }
    }
    
    func areValidDateStrings(_ dateStrings: [String], format: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = format
        
        for dateString in dateStrings {
            if dateFormatter.date(from: dateString) == nil {
                return false
            }
        }
        return true
    }
    
    func sortDatesByDescendingOrder() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        if areValidDateStrings(dateTitles, format: "d MMMM yyyy") {
            dateFormatter.dateFormat = "d MMMM yyyy"
        } else if areValidDateStrings(dateTitles, format: "LLLL yyyy") {
            dateFormatter.dateFormat = "LLLL yyyy"
        } else if areValidDateStrings(dateTitles, format: "yyyy") {
            dateFormatter.dateFormat = "yyyy"
        }
        
        let sortedDates = dateTitles.compactMap { dateFormatter.date(from: $0) }
            .sorted(by: { $0 > $1 })
        
        dateTitles = sortedDates.compactMap { dateFormatter.string(from: $0) }
        
        dateTableView.reloadData()
    }
    
    @objc func handleTapOutsideTable(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !dateTableView.frame.contains(location) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyMonth", for: indexPath) as! HistoryMonthCell
        cell.monthDateLabel.text = dateTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dateDelegate = dateSelectionDelegate {
            dateDelegate.dateSelection(date: dateTitles[indexPath.row])
            print(dateTitles[indexPath.row])
        } else {
            print("Ошибка: делегат для выбора даты не инициализирован")
        }
        
        if let monthDelegate = monthSelectionDelegate {
            let selectedMonth = monthNumbers[indexPath.row]
            let selectedYear = yearNumbers[indexPath.row]
            monthDelegate.monthlySelect(month: selectedMonth, year: selectedYear)
            print(dateTitles[indexPath.row])
        } else {
            print("Ошибка: делегат для выбора месяца не инициализирован")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
