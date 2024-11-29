import UIKit

class ColorIconCollectionViewController: UICollectionViewController {
    
    var delegate: SelectIconCategoryDelegate!
    
    var myIcon: String!
    
    var currentColor: String!
    
    var colors: [(color: UIColor?, name: String)] = [
        (UIColor(named: "blue"), "blue"),
        (UIColor(named: "blueLight"), "blueLight"),
        (UIColor(named: "fiolet"), "fiolet"),
        (UIColor(named: "green"), "green"),
        (UIColor(named: "greenLight"), "greenLight"),
        (UIColor(named: "greyLight"), "greyLight"),
        (UIColor(named: "pink"), "pink"),
        (UIColor(named: "red"), "red"),
        (UIColor(named: "yellow"), "yellow")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "CellColorIconCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "iconColorCell")
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let iconColorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconColorCell", for: indexPath) as! CellColorIconCollectionViewCell
        
        iconColorCell.imageCellColor.image = UIImage(named: myIcon)?.withRenderingMode(.alwaysTemplate)
        
        let colorTuple = colors[indexPath.row]
        iconColorCell.imageCellColor.tintColor = colorTuple.color
        
        return iconColorCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colors[indexPath.row]
        
        delegate.didSelectIconColor(color: selectedColor.name) // Pass the color name
        
        navigationController?.popViewController(animated: true)
    }
}
