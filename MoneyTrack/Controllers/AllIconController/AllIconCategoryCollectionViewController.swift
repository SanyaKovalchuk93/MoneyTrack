import UIKit

class AllIconCategoryCollectionViewController: UICollectionViewController {
    
    var delegate: SelectIconCategoryDelegate!
    
    let iconCategory = [
        Category(name: "", imageName: "icon_1", colorName: "blueLight"),
        Category(name: "", imageName: "icon_2", colorName: "green"),
        Category(name: "", imageName: "icon_3", colorName: "greyLight"),
        Category(name: "", imageName: "icon_4", colorName: "greenLight"),
        Category(name: "", imageName: "icon_5", colorName: "greyLight"),
        Category(name: "", imageName: "icon_6", colorName: "fiolet"),
        Category(name: "", imageName: "icon_7", colorName: "yellow"),
        Category(name: "", imageName: "icon_8", colorName: "blueLight"),
        Category(name: "", imageName: "icon_10", colorName: "fiolet"),
        Category(name: "", imageName: "icon_11", colorName: "green"),
        Category(name: "", imageName: "icon_12", colorName: "pink"),
        Category(name: "", imageName: "icon_13", colorName: "red"),
        Category(name: "", imageName: "icon_14", colorName: "greyLight"),
        Category(name: "", imageName: "icon_15", colorName: "blue"),
        Category(name: "", imageName: "icon_16", colorName: "green"),
        Category(name: "", imageName: "icon_17", colorName: "greyLight"),
        Category(name: "", imageName: "icon_18", colorName: "pink"),
        Category(name: "", imageName: "icon_19", colorName: "pink"),
        Category(name: "", imageName: "icon_20", colorName: "fiolet"),
        Category(name: "", imageName: "icon_21", colorName: "yellow"),
        Category(name: "", imageName: "icon_22", colorName: "yellow"),
        Category(name: "", imageName: "icon_23", colorName: "red"),
        Category(name: "", imageName: "icon_24", colorName: "blue"),
        Category(name: "", imageName: "icon_25", colorName: "red"),
        Category(name: "", imageName: "icon_26", colorName: "yellow"),
        Category(name: "", imageName: "icon_27", colorName: "green"),
        Category(name: "", imageName: "icon_28", colorName: "greenLight"),
        Category(name: "", imageName: "icon_29", colorName: "blueLight"),
        Category(name: "", imageName: "icon_30", colorName: "red"),
        Category(name: "", imageName: "icon_31", colorName: "blue"),
        Category(name: "", imageName: "icon_32", colorName: "blue"),
        Category(name: "", imageName: "icon_33", colorName: "greenLight"),
        Category(name: "", imageName: "icon_34", colorName: "blueLight"),
        Category(name: "", imageName: "icon_35", colorName: "red")
    ]
    
    var currentIcon: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "IconCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "iconCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconCategory.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let iconCell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCategoryCollectionViewCell
        
        iconCell.iconCategoryImage.image = iconCategory[indexPath.row].image
        iconCell.iconCategoryImage.image = iconCell.iconCategoryImage.image?.withRenderingMode(.alwaysTemplate)
        iconCell.iconCategoryImage.tintColor = iconCategory[indexPath.row].color
        
        if iconCategory[indexPath.row].imageName == currentIcon {
            iconCell.backgroundColor = UIColor(named: "changeColor")
        }
        
        return iconCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is IconCategoryCollectionViewCell {
            
            delegate.didSelectIcon(iconImage: iconCategory[indexPath.row].imageName, color: iconCategory[indexPath.row].colorName )
            navigationController?.popViewController(animated: true)
            
        }
    }
}
