//
//  HistoryViewController.swift
//  myNewApp
//
//  Created by Alexandr Kovalchuk on 19.05.2024.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [String]()
    
    var refreshControl = UIRefreshControl()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            navigationItem.title = "Новый текст"
            
            navigationController?.navigationBar.tintColor = .red
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
            
            refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            
            // Устанавливаем refreshControl для таблицы
            tableView.addSubview(refreshControl)
            
            tableView.dataSource = self
            
            tableView.register(CustomCellTableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = dataArray[indexPath.row]
            return cell
        }
    
    @objc func refreshData() {
        print("update")
            // Обновляем таблицу
            tableView.reloadData()
            
            // Завершаем обновление UIRefreshControl
            refreshControl.endRefreshing()
        }
    
}
