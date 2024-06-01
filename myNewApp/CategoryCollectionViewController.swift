//
//  CategoryCollectionViewController.swift
//  myNewApp
//
//  Created by Alexandr Kovalchuk on 21.05.2024.
//

import UIKit



class CategoryCollectionViewController: UICollectionViewController{
    
    var categoryNameCell: String!
    
    
    
    let imageNameArray2 = ["Ресурс 1",
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
    
    let imageTitleArray2 = ["Категория 1",
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
    
    
    var delegateCategory: VCDelegateCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.register(UINib(nibName: "NewCategeryCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "catCell")
          
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageNameArray2.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let catCell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as! NewCategeryCellCollectionViewCell
    
        catCell.labelCateg.text = imageTitleArray2[indexPath.row]
        
        catCell.imageView2.image = UIImage(named: imageNameArray2[indexPath.row])
        
        if let index = imageTitleArray2.firstIndex(where: { $0 == categoryNameCell }) {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.backgroundColor = .gray
            }
            
        }
        
        return catCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
//        if let cell = collectionView.cellForItem(at: indexPath) {
//            print(imageTitleArray2[indexPath.item])
//            cell.backgroundColor = .gray
//            
//            
//            }
        
        delegateCategory.changeCategory(text: imageTitleArray2[indexPath.item])
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
                
                cell.backgroundColor = .clear
            }
    }
}
