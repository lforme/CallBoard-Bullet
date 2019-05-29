//
//  StyleCVDelegateViewModel.swift
//  CallBoard
//
//  Created by mugua on 2019/5/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class StyleCVDelegateViewModel: NSObject {
    
    typealias SingleSelection = (Set<SettingModel>) -> Void
    
    var didSelected: SingleSelection?
    
    private var items: [SettingModel]!
    private var collection: UICollectionView!
    private var set: Set<SettingModel> = Set()
    
    convenience init(items: [SettingModel], collection: UICollectionView) {
        self.init()
        self.items = items
        self.collection = collection
        self.collection.dataSource = self
        self.collection.delegate = self
    }
}


extension StyleCVDelegateViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCell
        cell.label.text = items[indexPath.item].itemName
        return cell
    }
}

extension StyleCVDelegateViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        set.insert(items[indexPath.item])
        didSelected?(set)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        set.remove(items[indexPath.item])
        didSelected?(set)
    }
}
