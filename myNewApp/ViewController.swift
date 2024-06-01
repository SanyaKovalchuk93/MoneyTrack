//
//  ViewController.swift
//  myNewApp
//
//  Created by Alexandr Kovalchuk on 30.10.2023.
//

import UIKit

protocol VCDelegate {
    func update(text: String, catText: String!)
    func update1(text: String, catText: String!)
}

class ViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var UITableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var labelNumber: UILabel!
    
    
    
    //    // UserDefaults keys
    //    let stringArr1Key = "StringArr1"
    //    let stringArr2Key = "StringArr2"
    
    var rowNumber: Int = 0
    
    
    let imageNameArray = ["Ресурс 1",
                          "Ресурс 2",
                          "Ресурс 4",
                          "Ресурс 6",
                          "Ресурс 7",
                          "Ресурс 8",
                          "Ресурс 9",
                          "Ресурс 10",
                          "Ресурс 11",
                          "Ресурс 12",
                          "Ресурс 13",
                          "Ресурс 14",
                          "Ресурс 15",
                          "Ресурс 16",
                          "Ресурс 17",
                          "Ресурс 18"]
    
    let imageTitleArray = ["Категория 1",
                           "Категория 2",
                           "Категория 4",
                           "Категория 6",
                           "Категория 7",
                           "Категория 8",
                           "Категория 9",
                           "Категория 10",
                           "Категория 11",
                           "Категория 12",
                           "Категория 13",
                           "Категория 14",
                           "Категория 15",
                           "Категория 16",
                           "Категория 17",
                           "Категория 18"]
    
    @IBAction func btnHistory(_ sender: UIButton) {
        
        
        
//        let newViewController = HistoryViewController(nibName: "HistoryViewController", bundle: nil)
//
//        let combinedArray = stringArr1 + stringArr2
//        
//        newViewController.dataArray = combinedArray
//        
//        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    var dateHeader1: String!
    var dateHeader2: String!
    
    var today: String!
    var yesterday: String!
    
    var stillTyping = false //
    var dotIsPlaced = false // точка
    
    var zeroIsPlaced = false // ноль
    
    var stringArr1 = [String]()
    var stringArr2 = [String]()
    var stringArrImage1 = [String]() // название картинок
    var stringArrImage2 = [String]()
    var stringArrCategory1 = [String]() // название категорий
    var stringArrCategory2 = [String]()
    
    
    
    var timer: Timer?
    var headerTitle1: String = ""
    var headerTitle2: String = ""
    
    //var sectionHeaders: [String] = ["SECTION 1", "SECTION 2"]
    
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
        UITableView.dataSource = self
        UITableView.delegate = self
        UITableView.sectionHeaderTopPadding = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        UITableView.rowHeight = 70
        
        
        //formatter.dateFormat = "HH.mm.ss"
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateHeaderTitle), userInfo: nil, repeats: true)

        
        // Load data from UserDefaults
        //        if let savedStringArr1 = UserDefaults.standard.stringArray(forKey: stringArr1Key) {
        //            stringArr1 = savedStringArr1
        //        }
        //        if let savedStringArr2 = UserDefaults.standard.stringArray(forKey: stringArr2Key) {
        //            stringArr2 = savedStringArr2
        //        }
    }
    
    // Function to save data to UserDefaults
    //    func saveData() {
    //        UserDefaults.standard.set(stringArr1, forKey: stringArr1Key)
    //        UserDefaults.standard.set(stringArr2, forKey: stringArr2Key)
    //    }
    // нажатие цифры
    
    var numberSections = 2
    
    @IBAction func btnApp(_ sender: UIButton) {
        
        if stillTyping {
            labelNumber.text = labelNumber.text! + String(sender.tag)
        }
        
        else {
            labelNumber.text = String(sender.tag)
            stillTyping = true
        }
    }
    
    
    
    // нажатие "0"
    
    @IBAction func zeroBtn(_ sender: UIButton) {
        
        if stillTyping && !zeroIsPlaced {
            labelNumber.text = labelNumber.text! + "0"
        }
        
        else if !stillTyping && !zeroIsPlaced {
            labelNumber.text = "0."
            stillTyping = true
            dotIsPlaced = true
        }
    }
    
    // нажатие "удаление"
    
    @IBAction func removeLast(_ sender: UIButton) {
        
        if stillTyping {
            labelNumber.text?.removeLast()
            
            if ((labelNumber.text?.contains(".")) != nil){
                dotIsPlaced = false
            }
            
            if labelNumber.text == ""{
                stillTyping = false
                dotIsPlaced = false
                zeroIsPlaced = false
            }
        }
    }
    
    // нажатие "."
    
    @IBAction func pointButton(_ sender: UIButton) {
        
        if stillTyping && !dotIsPlaced{
            labelNumber.text = labelNumber.text! + "."
            dotIsPlaced = true
        }
        
        else if !stillTyping && !dotIsPlaced {
            labelNumber.text = "0."
            stillTyping = true
            dotIsPlaced = true
        }
    }
    
    
}



// История расходов

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return stringArr1.count
            
        }
        else{
            return stringArr2.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.label.text = stringArr1[indexPath.row]
            cell.nameCategory.text = stringArrCategory1[indexPath.row]
            
            cell.imageCategory.image = UIImage(named: stringArrImage1[indexPath.row])
        case 1:
            cell.label.text = stringArr2[indexPath.row]
            cell.nameCategory.text = stringArrCategory2[indexPath.row]
            
            cell.imageCategory.image = UIImage(named: stringArrImage2[indexPath.row])
        default:
            break
        }

        return cell
    }
    
    // анимация клика на ячейку
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController
        
        navigationController?.pushViewController(vc!, animated: true)
        
        switch indexPath.section {
        case 0:
            vc?.textSumma = stringArr1[indexPath.row]
            vc?.sectionNumber = String( indexPath.section)
            vc?.categoryText = stringArrCategory1[indexPath.row]
            vc?.dateValue2 = today
        case 1:
            vc?.textSumma = stringArr2[indexPath.row]
            vc?.sectionNumber = String(indexPath.section)
            vc?.categoryText = stringArrCategory2[indexPath.row]
            vc?.dateValue2 = yesterday
        default:
            break
        }

        rowNumber = indexPath.row
        
        vc?.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberSections
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//            return headerTitle
//        }
    
    // Дата
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {




        //today = formatter.string(from: currentDate)

       // yesterday = formatter.string( for: Calendar.current.date(byAdding: .minute, value: -1, to: currentDate))

        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray



        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 10, y:3, width: tableView.frame.width - 20, height: 30)
        titleLabel.textColor = UIColor.black
       

        switch section {
        case 0:
            titleLabel.text = headerTitle1
            dateHeader1 = titleLabel.text!
        case 1:
            titleLabel.text = headerTitle2
            dateHeader2 = titleLabel.text!
        default:
            break
        }

        headerView.addSubview(titleLabel)


        return headerView
    }
    
    // Удаление ячейки свайпом
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove the item from the data model
            //stringArr.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        }
        else if editingStyle == .insert {
            //  no need to implement
        }
    }
    
    @objc func updateHeaderTitle() {
        let currentDate = Date()
        
           
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "mm:ss"
        
                headerTitle1 = dateFormatter.string(from: Date())
        //gena
        headerTitle2 = dateFormatter.string( for: Calendar.current.date(byAdding: .second, value: -1, to: currentDate))!
           
           // Перезагрузка заголовка секции
           UITableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        UITableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        
        UITableView.reloadData()
       // numberSections += 1
        
        UITableView.insertSections(IndexSet(integer: 0), with: .automatic)
        //UITableView.deleteSections(IndexSet(integer: 1), with: .automatic)
       // sectionHeaders.insert("Section 3", at: 0)
       // sectionHeaders.removeLast()
       }
    
    
    
}

// Категории

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colCell", for: indexPath) as! ArtCoverCell
        
        colCell.coverImageView.image = UIImage(named: imageNameArray[indexPath.row])
        
        colCell.nameImage.text = imageTitleArray[indexPath.row]
        
        return colCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if dateHeader1 == headerTitle1{
            stringArr1.insert(labelNumber.text!, at: 0)
            stringArrImage1.insert(imageNameArray[indexPath.row], at: 0)
            
            stringArrCategory1.insert(imageTitleArray[indexPath.row], at: 0)
            UITableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        else if dateHeader2 == headerTitle2{
            stringArr2.insert(labelNumber.text!, at: 0)
            stringArrImage2.insert(imageNameArray[indexPath.row], at: 0)
            
            stringArrCategory2.insert(imageTitleArray[indexPath.row], at: 0)
            UITableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
        
        
        
        //saveData()
        
    }
}


extension ViewController: VCDelegate{
    
    func update(text: String, catText: String!) {
        stringArr1[rowNumber] = text
        stringArrCategory1[rowNumber] = catText
        UITableView.reloadData()
    }
    
    func update1(text: String, catText: String!) {
        stringArr2[rowNumber] = text
        stringArrCategory2[rowNumber] = catText
        UITableView.reloadData()
    }
}
