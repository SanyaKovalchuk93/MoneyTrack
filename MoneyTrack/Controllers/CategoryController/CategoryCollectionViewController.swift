import UIKit

protocol AddCategoryDelegate {
    func addNewCategory(nameCategory: String, iconImage: String, iconColor: String)
    func updateCategory(nameCategory: String, iconImage: String, iconColor: String)
}

class CategoryCollectionViewController: UICollectionViewController{
    
    var checkController: Bool!
    
    var delegateCategory: VCDelegate!
    
    var delegateName: CategoryNameSelectionDelegate!
    
    var collectionCategory = [Category]()
    
    var rowNumber: Int!
    
    var currentIcon: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addCategory))
        
        navigationItem.title = "Статьи"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(btnBack))
        
        collectionView.register(UINib(nibName: "NewCategeryCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "catCell")
        
        collectionCategory.removeLast()
        
    }
    
    @objc func addCategory() {
        
        let createNewCategoryCell = CreateCategoryViewController(nibName: "CreateCategoryViewController", bundle: nil)
        createNewCategoryCell.delegate = self
        createNewCategoryCell.navigationTitle = "Новая статья"
        createNewCategoryCell.checkController = false
        navigationController?.pushViewController(createNewCategoryCell, animated: true)
    }
    
    @objc func btnBack() {
        if checkController == false{
            delegateCategory.updateCategory(arrayCategory: collectionCategory)
        }
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionCategory.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let catCell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as! NewCategeryCellCollectionViewCell
        
        catCell.labelCateg.text = collectionCategory[indexPath.row].name
        catCell.imageView.image = collectionCategory[indexPath.row].image
        catCell.imageView.image = catCell.imageView.image?.withRenderingMode(.alwaysTemplate)
        catCell.imageView.tintColor = collectionCategory[indexPath.row].color
        
        if collectionCategory[indexPath.row].image == currentIcon {
            catCell.backgroundColor = UIColor(named: "changeColor")
        }
        
        return catCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let editCategoryCell = CreateCategoryViewController(nibName: "CreateCategoryViewController", bundle: nil)
        editCategoryCell.delegate = self
        
        if checkController == false{
            editCategoryCell.navigationTitle = "Статья"
            
            editCategoryCell.nameCategory = collectionCategory[indexPath.item].name
            editCategoryCell.newImage = collectionCategory[indexPath.item].imageName
            editCategoryCell.newColor = collectionCategory[indexPath.item].colorName
            
            editCategoryCell.checkController = true
            
            rowNumber = indexPath.row
            
            navigationController?.pushViewController(editCategoryCell, animated: true)
        }
        
        else{
            delegateName.didSelectIconName(nameCategory:  collectionCategory[indexPath.row].name, iconImage: collectionCategory[indexPath.row].imageName, iconColor: collectionCategory[indexPath.row].colorName)
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true)
        }
    }
    func replaceItem(at index: Int, with newItem: Category) {
        collectionCategory[index] = newItem
    }
}

extension CategoryCollectionViewController: AddCategoryDelegate{
    func updateCategory(nameCategory: String, iconImage: String, iconColor: String) {
        replaceItem(at: rowNumber, with: Category(name: nameCategory, imageName: iconImage, colorName: iconColor))
        collectionView.reloadData()
    }
    
    func addNewCategory(nameCategory: String, iconImage: String, iconColor: String){
        collectionCategory.append(Category(name: nameCategory, imageName: iconImage, colorName: iconColor))
        collectionView.reloadData()
    }
}
